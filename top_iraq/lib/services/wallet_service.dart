class WalletService {
  WalletService({int initialBalance = 0}) : _balance = initialBalance;

  int _balance;

  int get balance => _balance;

  bool spend(int amount) {
    if (amount < 0 || amount > _balance) return false;
    _balance -= amount;
    return true;
  }

  void deposit(int amount) {
    if (amount > 0) _balance += amount;
  }
}