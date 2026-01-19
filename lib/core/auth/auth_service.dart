import 'dart:async';

class AuthUser {
  final String id;
  final String email;

  const AuthUser({required this.id, required this.email});
}

abstract class AuthService {
  Stream<AuthUser?> get user;
  Future<void> signIn();
  Future<void> signOut();
}

class MockAuthService implements AuthService {
  final _controller = StreamController<AuthUser?>.broadcast();
  AuthUser? _currentUser;

  MockAuthService() {
    // Simulate initial delayed login or just start unauthenticated
    // For MVP, let's start authenticated for convenience or easy login
    _controller.add(null);
  }

  @override
  Stream<AuthUser?> get user => _controller.stream;

  @override
  Future<void> signIn() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = const AuthUser(id: 'user_1', email: 'test@example.com');
    _controller.add(_currentUser);
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = null;
    _controller.add(null);
  }
}
