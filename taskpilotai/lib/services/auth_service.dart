import 'dart:async';
import '../models/user.dart';
import 'storage_service.dart';

class AuthService {
  final StorageService _storageService;
  final _authController = StreamController<AppUser?>.broadcast();

  AuthService(this._storageService);

  Stream<AppUser?> get authStateChanges => _authController.stream;
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;

  Future<void> init() async {
    try {
      _currentUser = await _storageService.loadUser();
      _authController.add(_currentUser);
    } catch (e) {
      _currentUser = null;
      _authController.add(null);
    }
  }

  Future<AppUser?> signInWithEmail(String email) async {
    // Simulate email magic link authentication
    // In production, this would send a magic link via Firebase
    await Future.delayed(const Duration(seconds: 1));
    
    final user = AppUser(
      id: email.hashCode.toString(),
      email: email,
      displayName: email.split('@').first,
      createdAt: DateTime.now(),
    );

    _currentUser = user;
    await _storageService.saveUser(user);
    _authController.add(user);
    return user;
  }

  Future<void> signOut() async {
    _currentUser = null;
    await _storageService.clearUser();
    _authController.add(null);
  }

  void dispose() {
    _authController.close();
  }
}

