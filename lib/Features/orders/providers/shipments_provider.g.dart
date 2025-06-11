// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shipments_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$shipmentsNotifierHash() => r'607d2d4fa6bf6c0cdf29fb4a3f32ce6192814e07';

/// 🎯 Provider Layer - إدارة حالة الشحنات
/// ✅ المسؤوليات:
/// - ربط الـ ShipmentsService بالـ UI بطريقة reactive
/// - إدارة حالة البيانات (loading, success, error)
/// - تخزين البيانات مؤقتاً في الذاكرة
/// - توفير واجهة موحدة للـ UI للتفاعل مع بيانات الشحنات
///
/// ❌ ما لا يحتويه:
/// - HTTP requests مباشرة - يمر عبر ShipmentsService
/// - معالجة UI أو widgets
/// - منطق العرض أو التصميم
/// - تفاصيل الـ API endpoints
///
/// Copied from [ShipmentsNotifier].
@ProviderFor(ShipmentsNotifier)
final shipmentsNotifierProvider = AutoDisposeAsyncNotifierProvider<
    ShipmentsNotifier, List<Shipment>>.internal(
  ShipmentsNotifier.new,
  name: r'shipmentsNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$shipmentsNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ShipmentsNotifier = AutoDisposeAsyncNotifier<List<Shipment>>;
String _$filteredShipmentsNotifierHash() =>
    r'97d2f7812d2cd898f8c6e6003b6749f1825f2445';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$FilteredShipmentsNotifier
    extends BuildlessAutoDisposeNotifier<List<Shipment>> {
  late final String searchTerm;

  List<Shipment> build(
    String searchTerm,
  );
}

/// See also [FilteredShipmentsNotifier].
@ProviderFor(FilteredShipmentsNotifier)
const filteredShipmentsNotifierProvider = FilteredShipmentsNotifierFamily();

/// See also [FilteredShipmentsNotifier].
class FilteredShipmentsNotifierFamily extends Family<List<Shipment>> {
  /// See also [FilteredShipmentsNotifier].
  const FilteredShipmentsNotifierFamily();

  /// See also [FilteredShipmentsNotifier].
  FilteredShipmentsNotifierProvider call(
    String searchTerm,
  ) {
    return FilteredShipmentsNotifierProvider(
      searchTerm,
    );
  }

  @override
  FilteredShipmentsNotifierProvider getProviderOverride(
    covariant FilteredShipmentsNotifierProvider provider,
  ) {
    return call(
      provider.searchTerm,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'filteredShipmentsNotifierProvider';
}

/// See also [FilteredShipmentsNotifier].
class FilteredShipmentsNotifierProvider extends AutoDisposeNotifierProviderImpl<
    FilteredShipmentsNotifier, List<Shipment>> {
  /// See also [FilteredShipmentsNotifier].
  FilteredShipmentsNotifierProvider(
    String searchTerm,
  ) : this._internal(
          () => FilteredShipmentsNotifier()..searchTerm = searchTerm,
          from: filteredShipmentsNotifierProvider,
          name: r'filteredShipmentsNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$filteredShipmentsNotifierHash,
          dependencies: FilteredShipmentsNotifierFamily._dependencies,
          allTransitiveDependencies:
              FilteredShipmentsNotifierFamily._allTransitiveDependencies,
          searchTerm: searchTerm,
        );

  FilteredShipmentsNotifierProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.searchTerm,
  }) : super.internal();

  final String searchTerm;

  @override
  List<Shipment> runNotifierBuild(
    covariant FilteredShipmentsNotifier notifier,
  ) {
    return notifier.build(
      searchTerm,
    );
  }

  @override
  Override overrideWith(FilteredShipmentsNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: FilteredShipmentsNotifierProvider._internal(
        () => create()..searchTerm = searchTerm,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        searchTerm: searchTerm,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<FilteredShipmentsNotifier, List<Shipment>>
      createElement() {
    return _FilteredShipmentsNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredShipmentsNotifierProvider &&
        other.searchTerm == searchTerm;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, searchTerm.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin FilteredShipmentsNotifierRef
    on AutoDisposeNotifierProviderRef<List<Shipment>> {
  /// The parameter `searchTerm` of this provider.
  String get searchTerm;
}

class _FilteredShipmentsNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<FilteredShipmentsNotifier,
        List<Shipment>> with FilteredShipmentsNotifierRef {
  _FilteredShipmentsNotifierProviderElement(super.provider);

  @override
  String get searchTerm =>
      (origin as FilteredShipmentsNotifierProvider).searchTerm;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
