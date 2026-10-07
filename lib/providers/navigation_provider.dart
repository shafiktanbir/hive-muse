import 'package:flutter/material.dart';

class NavigationProvider extends ChangeNotifier {
  int _currentIndex = 0;
  bool _hasCompletedOnboarding = false;
  bool _isPlayerExpanded = false;

  int get currentIndex => _currentIndex;
  bool get hasCompletedOnboarding => _hasCompletedOnboarding;
  bool get isPlayerExpanded => _isPlayerExpanded;

  void setIndex(int index) {
    _currentIndex = index;
    _isPlayerExpanded = false;
    notifyListeners();
  }

  void completeOnboarding() {
    _hasCompletedOnboarding = true;
    notifyListeners();
  }

  void expandPlayer() {
    _isPlayerExpanded = true;
    notifyListeners();
  }

  void collapsePlayer() {
    _isPlayerExpanded = false;
    notifyListeners();
  }

  void togglePlayerExpansion() {
    _isPlayerExpanded = !_isPlayerExpanded;
    notifyListeners();
  }
}
