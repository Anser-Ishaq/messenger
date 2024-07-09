import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:messanger_ui/firebase_options.dart';
import 'package:messanger_ui/services/alert_service.dart';
import 'package:messanger_ui/services/auth_service.dart';
import 'package:messanger_ui/services/database_service.dart';
import 'package:messanger_ui/services/media_service.dart';
import 'package:messanger_ui/services/navigation_service.dart';
import 'package:messanger_ui/services/storage_service.dart';
import 'package:messanger_ui/services/updateprofile_service.dart';

Future<void> setupFirebase() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

Future<void> registerServices() async {
  final GetIt getIt = GetIt.instance;
  getIt.registerSingleton<NavigationService>(
    NavigationService(),
  );
  getIt.registerSingleton<AlertService>(
    AlertService(),
  );
  getIt.registerSingleton<AuthService>(
    AuthService(),
  );
  getIt.registerSingleton<DatabaseService>(
    DatabaseService(),
  );
  getIt.registerSingleton<MediaService>(
    MediaService(),
  );
  getIt.registerSingleton<StorageService>(
    StorageService(),
  );
  getIt.registerSingleton<UpdateprofileService>(
    UpdateprofileService(),
  );
}

String generateChatID({required String uid1, required String uid2}) {
  List uids = [uid1, uid2];
  uids.sort();
  String chatID = uids.fold("", (id, uid) => "$id$uid");
  return chatID;
}

String formatDateTime(Timestamp dateTime) {
  final now = DateTime.now();
  final messageDate = dateTime.toDate();

  final isSameDay = now.year == messageDate.year &&
      now.month == messageDate.month &&
      now.day == messageDate.day;

  if (isSameDay) {
    return DateFormat('hh:mm a').format(messageDate);
  } else {
    return DateFormat('EEE, MMM d').format(messageDate);
  }
}
