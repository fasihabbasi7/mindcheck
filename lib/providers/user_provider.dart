import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'storage_provider.dart';

/// The user's optional first name, used only for the Home greeting.
/// An empty string means no name was given.
class UserNameNotifier extends Notifier<String> {
  @override
  String build() => ref.read(storageServiceProvider).userName;

  Future<void> setName(String name) async {
    final String cleaned = name.trim();
    state = cleaned;
    await ref.read(storageServiceProvider).setUserName(cleaned);
  }
}

final NotifierProvider<UserNameNotifier, String> userNameProvider =
    NotifierProvider<UserNameNotifier, String>(UserNameNotifier.new);
