import 'dart:async';
import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:pro/cache/CacheHelper.dart';
import 'package:pro/core/API/ApiKey.dart';
import 'package:pro/cubit/sos/sos_state.dart';
import 'package:pro/models/SosNotificationModel.dart';
import 'package:pro/repo/SosRepository.dart';
import 'package:pro/services/notification_service.dart';

class SosCubit extends Cubit<SosState> {
  final SosRepository sosRepository;
  StreamSubscription? _sosNotificationSubscription;
  final Location _location = Location();
  final NotificationService _notificationService = NotificationService();
  BuildContext? _context;

  SosCubit({required this.sosRepository}) : super(SosInitial()) {
    // Listen for incoming SOS notifications
    _sosNotificationSubscription =
        sosRepository.signalRService.sosNotifications.listen((notification) {
      // Check if this notification should be shown to this user
      if (shouldShowNotification(notification)) {
        // Emit state
        emit(SosNotificationReceived(notification));

        // Show notification
        _notificationService.showSosNotification(notification);

        // Show dialog if context is available
        if (_context != null) {
          _notificationService.showSosDialog(_context!, notification);
        }

        log('Received SOS notification from ${notification.travelerName}');
      } else {
        log('Ignoring SOS notification: User is not a supporter or the traveler');
      }
    }, onError: (error) {
      log('Error in SOS notification stream: $error');
    });
  }

  // Set context for showing dialogs
  void setContext(BuildContext context) {
    _context = context;
  }

  // Check if this notification should be shown to this user
  bool shouldShowNotification(SosNotificationModel notification) {
    // Get the current user ID
    final currentUserId =
        CacheHelper.getData(key: ApiKey.userId)?.toString() ?? '';
    if (currentUserId.isEmpty) {
      log('WARNING: Current user ID not found in cache');
      return false;
    }

    // Always show notification to the traveler who sent it
    if (notification.travelerId == currentUserId) {
      log('Showing notification to traveler (self)');
      return true;
    }

    // Check if this user is in the supporters list
    final List<String> supporterIds = notification.supporterIds ?? [];
    final bool isSupporter = supporterIds.contains(currentUserId);

    if (isSupporter) {
      log('Showing notification to supporter: $currentUserId');
      return true;
    }

    log('Not showing notification to user: $currentUserId (not traveler or supporter)');
    return false;
  }

  // Initialize location service and SignalR connection
  Future<void> initialize() async {
    try {
      // Connect to SignalR hub
      await sosRepository.connectToSignalR();
      emit(const SosConnectionState(true));
    } catch (e) {
      log('Error initializing SOS service: $e');
      emit(const SosConnectionState(false));
    }
  }

  // Send SOS notification with current location
  Future<void> sendSosNotification(
      {String message = "SOS! I need help!"}) async {
    emit(SosLoading());

    try {
      // Check and request location permissions
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) {
          emit(const SosFailure('Location services are disabled'));
          return;
        }
      }

      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          emit(const SosFailure('Location permission denied'));
          return;
        }
      }

      // Get current location
      final locationData = await _location.getLocation();

      if (locationData.latitude == null || locationData.longitude == null) {
        emit(const SosFailure('Could not get current location'));
        return;
      }

      // Send SOS notification
      final result = await sosRepository.sendSosNotification(
        latitude: locationData.latitude!,
        longitude: locationData.longitude!,
        message: message,
      );

      result.fold(
        (error) => emit(SosFailure(error)),
        (response) {
          // Create a notification for the traveler who sent the SOS
          final sosNotification = SosNotificationModel(
            latitude: locationData.latitude!,
            longitude: locationData.longitude!,
            message: message,
            travelerId: sosRepository.getUserId() ?? '',
            travelerName: sosRepository.getUserName() ?? 'You',
            timestamp: DateTime.now(),
            // Include the same supporter IDs that were sent to the server
            supporterIds: result
                .getOrElse(() => SosResponse(success: false, message: ''))
                .supporterIds,
          );

          // Add notification to the traveler's notification list
          _notificationService.addInAppNotification(sosNotification);

          // Emit success state
          emit(SosSuccess(response));
        },
      );
    } catch (e) {
      log('Error sending SOS notification: $e');
      emit(SosFailure('Failed to send SOS notification: $e'));
    }
  }

  @override
  Future<void> close() {
    _sosNotificationSubscription?.cancel();
    sosRepository.dispose();
    return super.close();
  }
}
