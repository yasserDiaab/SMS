import 'dart:convert';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;

class SupportersSyncService {
  static const String boxName = 'supporters';
  static const String phonesKey = 'phones';
  static const String lastSyncKey = 'last_sync';
  static const Duration syncInterval = Duration(hours: 48);

  final String apiUrl;
  final String bearerToken;

  SupportersSyncService({required this.apiUrl, required this.bearerToken});

  Future<void> syncSupportersPhones() async {
    print('[SupportersSyncService] Starting sync...');
    final box = Hive.box(boxName);
    final now = DateTime.now();
    final lastSync = box.get(lastSyncKey);
    if (lastSync != null) {
      final lastSyncTime = DateTime.tryParse(lastSync);
      print('[SupportersSyncService] Last sync: $lastSyncTime');
      if (lastSyncTime != null && now.difference(lastSyncTime) < syncInterval) {
        print(
            '[SupportersSyncService] Less than 48h since last sync. Skipping.');
        print('[SupportersSyncService] Local DB: ' +
            (box.get(phonesKey)?.toString() ?? '[]'));
        return;
      }
    }
    print('[SupportersSyncService] Fetching from API: $apiUrl');
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: {'Authorization': 'Bearer $bearerToken'},
    );
    print('[SupportersSyncService] API status: ${response.statusCode}');
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> newPhones = data['supportersPhones'] ?? [];
      final List<String> newPhonesList =
          newPhones.map((e) => e.toString()).toList();
      print('[SupportersSyncService] Phones from API: $newPhonesList');
      final List<String> oldPhones =
          List<String>.from(box.get(phonesKey) ?? []);
      print('[SupportersSyncService] Phones in local DB before: $oldPhones');
      if (!_listsEqual(newPhonesList, oldPhones)) {
        print('[SupportersSyncService] Phones changed. Updating local DB...');
        await box.put(phonesKey, newPhonesList);
      } else {
        print('[SupportersSyncService] Phones did not change.');
      }
      await box.put(lastSyncKey, now.toIso8601String());
      print('[SupportersSyncService] Sync complete. Local DB now: ' +
          (box.get(phonesKey)?.toString() ?? '[]'));
    } else {
      print(
          '[SupportersSyncService] Failed to fetch supporters phones: ${response.statusCode}');
      throw Exception(
          'Failed to fetch supporters phones: ${response.statusCode}');
    }
  }

  List<String> getSupportersPhones() {
    final box = Hive.box(boxName);
    return List<String>.from(box.get(phonesKey) ?? []);
  }

  bool shouldSync() {
    final box = Hive.box(boxName);
    final lastSync = box.get(lastSyncKey);
    if (lastSync == null) return true;
    final lastSyncTime = DateTime.tryParse(lastSync);
    if (lastSyncTime == null) return true;
    return DateTime.now().difference(lastSyncTime) >= syncInterval;
  }

  bool _listsEqual(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
