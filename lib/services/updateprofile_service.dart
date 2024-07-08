import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:messanger_ui/services/auth_service.dart';
import 'package:messanger_ui/services/database_service.dart';
import 'package:messanger_ui/services/storage_service.dart';

class UpdateprofileService {
  final GetIt _getIt = GetIt.instance;
  late StorageService _storageService;
  late DatabaseService _databaseService;
  late AuthService _authService;

  UpdateprofileService() {
    _storageService = _getIt.get<StorageService>();
    _databaseService = _getIt.get<DatabaseService>();
    _authService = _getIt.get<AuthService>();
  }

  Future<void> updateProfile({
    String? newUsername,
    File? newPfp,
  }) async {
    String uid = _authService.user!.uid;
    String? currentPfpURL = _databaseService.userModel.pfpURL;
    String? newPfpURL;

    if (newPfp != null) {
      if (currentPfpURL != null) {
        await _storageService.deleteUserPfp(currentPfpURL);
      }
      newPfpURL = await _storageService.uploadUserPfp(file: newPfp, uid: uid);
    }

    await _databaseService.updateUserProfile(
      uid: uid,
      newUsername: newUsername,
      newPfpURL: newPfpURL,
    );
  }

}