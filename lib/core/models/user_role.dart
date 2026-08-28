enum UserRole {
  farmer,
  fpo;

  String get displayName {
    switch (this) {
      case UserRole.farmer:
        return 'Farmer';
      case UserRole.fpo:
        return 'FPO (Farmer Producer Org)';
    }
  }

  String get badgeName {
    switch (this) {
      case UserRole.farmer:
        return 'Verified Farmer';
      case UserRole.fpo:
        return 'Registered FPO';
    }
  }
}
