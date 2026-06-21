// lib/viewmodels/profile_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../viewmodels/auth_viewmodel.dart';

class ProfileViewModel with ChangeNotifier {
  final AuthViewModel authViewModel;

  ProfileViewModel(this.authViewModel);

  String? get userEmail => authViewModel.currentUser?.email;

  void logout() {
    authViewModel.logout();
  }
}