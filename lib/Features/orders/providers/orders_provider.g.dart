// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'orders_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$ordersNotifierHash() => r'b51867c61e70e7b3cefb6d9d4879465578c295de';

/// See also [OrdersNotifier].
@ProviderFor(OrdersNotifier)
final ordersNotifierProvider =
    AutoDisposeAsyncNotifierProvider<OrdersNotifier, List<Order>>.internal(
  OrdersNotifier.new,
  name: r'ordersNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$ordersNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$OrdersNotifier = AutoDisposeAsyncNotifier<List<Order>>;
String _$filteredOrdersNotifierHash() =>
    r'70dd496f2f104eaea7d3efea127c02726867ba07';

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

abstract class _$FilteredOrdersNotifier
    extends BuildlessAutoDisposeNotifier<List<Order>> {
  late final String searchTerm;

  List<Order> build(
    String searchTerm,
  );
}

/// See also [FilteredOrdersNotifier].
@ProviderFor(FilteredOrdersNotifier)
const filteredOrdersNotifierProvider = FilteredOrdersNotifierFamily();

/// See also [FilteredOrdersNotifier].
class FilteredOrdersNotifierFamily extends Family<List<Order>> {
  /// See also [FilteredOrdersNotifier].
  const FilteredOrdersNotifierFamily();

  /// See also [FilteredOrdersNotifier].
  FilteredOrdersNotifierProvider call(
    String searchTerm,
  ) {
    return FilteredOrdersNotifierProvider(
      searchTerm,
    );
  }

  @override
  FilteredOrdersNotifierProvider getProviderOverride(
    covariant FilteredOrdersNotifierProvider provider,
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
  String? get name => r'filteredOrdersNotifierProvider';
}

/// See also [FilteredOrdersNotifier].
class FilteredOrdersNotifierProvider extends AutoDisposeNotifierProviderImpl<
    FilteredOrdersNotifier, List<Order>> {
  /// See also [FilteredOrdersNotifier].
  FilteredOrdersNotifierProvider(
    String searchTerm,
  ) : this._internal(
          () => FilteredOrdersNotifier()..searchTerm = searchTerm,
          from: filteredOrdersNotifierProvider,
          name: r'filteredOrdersNotifierProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$filteredOrdersNotifierHash,
          dependencies: FilteredOrdersNotifierFamily._dependencies,
          allTransitiveDependencies:
              FilteredOrdersNotifierFamily._allTransitiveDependencies,
          searchTerm: searchTerm,
        );

  FilteredOrdersNotifierProvider._internal(
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
  List<Order> runNotifierBuild(
    covariant FilteredOrdersNotifier notifier,
  ) {
    return notifier.build(
      searchTerm,
    );
  }

  @override
  Override overrideWith(FilteredOrdersNotifier Function() create) {
    return ProviderOverride(
      origin: this,
      override: FilteredOrdersNotifierProvider._internal(
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
  AutoDisposeNotifierProviderElement<FilteredOrdersNotifier, List<Order>>
      createElement() {
    return _FilteredOrdersNotifierProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is FilteredOrdersNotifierProvider &&
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
mixin FilteredOrdersNotifierRef on AutoDisposeNotifierProviderRef<List<Order>> {
  /// The parameter `searchTerm` of this provider.
  String get searchTerm;
}

class _FilteredOrdersNotifierProviderElement
    extends AutoDisposeNotifierProviderElement<FilteredOrdersNotifier,
        List<Order>> with FilteredOrdersNotifierRef {
  _FilteredOrdersNotifierProviderElement(super.provider);

  @override
  String get searchTerm =>
      (origin as FilteredOrdersNotifierProvider).searchTerm;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
