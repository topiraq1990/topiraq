class AuthService {
  String? _username;

  bool get isAuthenticated => _username != null;
  String get username => _username ?? 'ضيف';

  bool login(String username) {
    final value = username.trim();
    if (value.isEmpty) return false;
    _username = value;
    return true;
  }

  void logout() {
    _username = null;
  }
}