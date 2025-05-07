import 'package:flutter/material.dart';

///
/// The new State-Manager for Chewie!
/// Has to be an instance of Singleton to survive
/// over all State-Changes inside chewie
///
class PlayerNotifier extends ChangeNotifier {
  PlayerNotifier._(
    bool hideStuff,
    bool hasPlayedOnce,
  )   : _hideStuff = hideStuff,
        _hasPlayedOnce = hasPlayedOnce;

  bool _hideStuff;
  bool _hasPlayedOnce;

  bool get hideStuff => _hideStuff;
  bool get hasPlayedOnce => _hasPlayedOnce;

  set hideStuff(bool value) {
    _hideStuff = value;
    notifyListeners();
  }

  set hasPlayedOnce(bool value) {
    _hasPlayedOnce = value;
    notifyListeners();
  }

  // ignore: prefer_constructors_over_static_methods
  static PlayerNotifier init() {
    return PlayerNotifier._(
      true,
      false,
    );
  }
}
