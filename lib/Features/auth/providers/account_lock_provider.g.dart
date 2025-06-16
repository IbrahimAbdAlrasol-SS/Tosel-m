// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account_lock_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$shouldShowLockScreenHash() =>
    r'fa46a6838d5e8a711c74e7d00a0701301006452e';

/// See also [shouldShowLockScreen].
@ProviderFor(shouldShowLockScreen)
final shouldShowLockScreenProvider = AutoDisposeFutureProvider<bool>.internal(
  shouldShowLockScreen,
  name: r'shouldShowLockScreenProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$shouldShowLockScreenHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ShouldShowLockScreenRef = AutoDisposeFutureProviderRef<bool>;
String _$accountLockNotifierHash() =>
    r'a6bc8f23e4de2d187454fb7001cad60042f48075';

/// See also [AccountLockNotifier].
@ProviderFor(AccountLockNotifier)
final accountLockNotifierProvider = AutoDisposeAsyncNotifierProvider<
    AccountLockNotifier, AccountLockStatus?>.internal(
  AccountLockNotifier.new,
  name: r'accountLockNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$accountLockNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$AccountLockNotifier = AutoDisposeAsyncNotifier<AccountLockStatus?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
