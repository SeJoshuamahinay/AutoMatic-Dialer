import 'package:flutter/material.dart';
import 'package:lenderly_dialer/commons/utils/database_seeder.dart';
import 'package:lenderly_dialer/commons/services/shared_prefs_storage_service.dart';

/// Simple test app to run the database seeder
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 Starting Database Seeder...');

  try {
    // Initialize shared preferences
    await SharedPrefsStorageService.initialize();

    // Get user session to use real user data if available
    final userSession = await SharedPrefsStorageService.getUserSession();
    final userId = userSession?.userId ?? 1;
    final agentName = userSession?.fullName ?? 'Test Agent';

    print('👤 Using User ID: $userId, Agent: $agentName');

    // Clear existing data first (optional - comment out if you want to keep existing data)
    print('\n🗑️ Clearing existing data...');
    await DatabaseSeeder.clearAllData();

    // Seed the database
    print('\n🌱 Seeding database with test data...');
    await DatabaseSeeder.seedDatabase(
      userId: userId,
      agentName: agentName,
      daysOfHistory: 7, // 7 days of history
      callsPerDay: 20, // 20 calls per day
    );

    print('\n✅ Database seeding completed successfully!');
    print('🎯 You can now view the dashboard to see the test data.');
  } catch (e) {
    print('❌ Error during seeding: $e');
  }
}

/// Alternative quick seeder for development
void quickSeed() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 Quick Seed Started...');

  try {
    await SharedPrefsStorageService.initialize();
    final userSession = await SharedPrefsStorageService.getUserSession();

    await DatabaseSeeder.quickSeed(
      userId: userSession?.userId ?? 1,
      agentName: userSession?.fullName ?? 'Dev User',
    );

    print('✅ Quick seed completed!');
  } catch (e) {
    print('❌ Error: $e');
  }
}

/// Full seeder for comprehensive testing
void fullSeed() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 Full Seed Started...');

  try {
    await SharedPrefsStorageService.initialize();
    final userSession = await SharedPrefsStorageService.getUserSession();

    await DatabaseSeeder.fullSeed(
      userId: userSession?.userId ?? 1,
      agentName: userSession?.fullName ?? 'Test User',
    );

    print('✅ Full seed completed!');
  } catch (e) {
    print('❌ Error: $e');
  }
}
