import 'package:gap/gap.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Tosell/core/constants/spaces.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Tosell/paging/generic_paged_list_view.dart';
import 'package:Tosell/Features/orders/models/Shipment.dart';
import 'package:Tosell/Features/orders/models/OrderFilter.dart';
import 'package:Tosell/Features/orders/widgets/shipment_cart_Item.dart';
import 'package:Tosell/Features/orders/providers/shipments_provider.dart';

// ✅ Import search provider from orders_screen.dart
final shipmentsSearchProvider = StateProvider<String>((ref) => '');

class shipmentInfoTab extends ConsumerStatefulWidget {
  final OrderFilter? filter;
  const shipmentInfoTab({super.key, this.filter});

  @override
  ConsumerState<shipmentInfoTab> createState() => _shipmentInfoTabState();
}

class _shipmentInfoTabState extends ConsumerState<shipmentInfoTab> {
  // ✅ Current filter - updated from parent screen
  late OrderFilter _currentFilter;

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.filter ?? OrderFilter();
  }

  @override
  void didUpdateWidget(covariant shipmentInfoTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // ✅ Update filter when parent changes it
    if (widget.filter != oldWidget.filter) {
      _currentFilter = widget.filter ?? OrderFilter();
    }
  }

  /// ✅ Handle shipment tap - navigate to shipment orders
  void _handleShipmentTap(Shipment shipment) {
    // Navigate to shipment orders screen
    context.push(
      '/shipment-orders', // Update this route as needed
      extra: {
        'shipmentId': shipment.id,
        'shipmentCode': shipment.code,
      },
    );
  }

  /// ✅ Get section title based on current filter
  String _getSectionTitle() {
    if (_currentFilter.status != null) {
      // Add status mapping for shipments if needed
      return 'الشحنات المفلترة';
    } else {
      return 'جميع الوصولات';
    }
  }

  @override
  Widget build(BuildContext context) {
    final shipmentsState = ref.watch(shipmentsNotifierProvider);
    final searchTerm = ref.watch(shipmentsSearchProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Section title with shipments count
            _buildSectionTitle(shipmentsState),
            
            const Gap(AppSpaces.small),
            
            // ✅ Shipments list
            Expanded(
              child: shipmentsState.when(
                data: (shipments) => _buildShipmentsList(shipments),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => _buildErrorState(err.toString()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ✅ Build section title with shipments count
  Widget _buildSectionTitle(AsyncValue<List<Shipment>> shipmentsState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: shipmentsState.when(
        data: (shipments) {
          final filteredCount = shipments.length;
          return Text(
            '${_getSectionTitle()} ($filteredCount)',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          );
        },
        loading: () => Text(
          '${_getSectionTitle()} (جاري التحميل...)',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        error: (_, __) => Text(
          _getSectionTitle(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// ✅ Build shipments list
  Widget _buildShipmentsList(List<Shipment> shipments) {
    if (shipments.isEmpty) {
      return _buildNoItemsFound();
    }

    return GenericPagedListView<Shipment>(
      key: ValueKey(_currentFilter.toJson()),
      fetchPage: (pageKey, _) async {
        return await ref.read(shipmentsNotifierProvider.notifier).getAll(
          page: pageKey,
          queryParams: _currentFilter.toJson(),
        );
      },
      itemBuilder: (context, shipment, index) => _buildShipmentItem(shipment),
      noItemsFoundIndicatorBuilder: _buildNoItemsFound(),
    );
  }

  /// ✅ Build individual shipment item
  Widget _buildShipmentItem(Shipment shipment) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ShipmentCartItem(
        shipment: shipment,
        onTap: () => _handleShipmentTap(shipment),
      ),
    );
  }

  /// ✅ Build error state
  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const Gap(AppSpaces.medium),
          Text(
            'حدث خطأ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const Gap(AppSpaces.small),
          Text(
            error,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const Gap(AppSpaces.medium),
          ElevatedButton(
            onPressed: () {
              // ✅ Retry loading via provider
              ref.read(shipmentsNotifierProvider.notifier).getAll(
                page: 1,
                queryParams: _currentFilter.toJson(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  /// ✅ Build no items found state
  Widget _buildNoItemsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/svg/NoItemsFound.gif',
            width: 240,
            height: 240,
          ),
          const Gap(AppSpaces.medium),
          Text(
            'لا توجد وصولات',
            style: context.textTheme.bodyLarge!.copyWith(
              fontWeight: FontWeight.w700,
              color: context.colorScheme.primary,
              fontSize: 24,
            ),
          ),
          const Gap(AppSpaces.small),
          Text(
            'لم يتم العثور على أي شحنات',
            textAlign: TextAlign.center,
            style: context.textTheme.bodySmall!.copyWith(
              fontWeight: FontWeight.w500,
              color: const Color(0xff698596),
              fontSize: 16,
            ),
          ),
          const Gap(AppSpaces.large),
          
          // ✅ Optional: Add action button for creating shipments
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to create shipment or show info
                // context.push(AppRoutes.createShipment);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.local_shipping),
              label: const Text('إنشاء شحنة جديدة'),
            ),
          ),
        ],
      ),
    );
  }
}