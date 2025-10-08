import 'package:flutter/material.dart';


// Was used for managing refreshed before i added the firebase watch functions
class RefreshReloadNotifier {
  // 1. Private constructor
  RefreshReloadNotifier ._privateConstructor();

  // 2. Static instance variable
  static final RefreshReloadNotifier  instance = RefreshReloadNotifier ._privateConstructor();

  // 3. Public getter for the instance
  factory RefreshReloadNotifier () {
    return instance;
  }

  // 4. List to hold registered callbacks
  final List<VoidCallback> _listeners = [];

  // 5. Register function to add a callback
  void register(VoidCallback callback) {
    if (!_listeners.contains(callback)) {
      _listeners.add(callback);
    }
  }

  // 6. Unregister function to remove a callback
  void unregister(VoidCallback callback) {
    _listeners.remove(callback);
  }

  // 7. Notify all registered callbacks
  Future <void> notifyAll() async {
    for (var callback in List<VoidCallback>.from(_listeners)) {
      callback();  // Call each registered function (like loadData)
    }
  }
}
