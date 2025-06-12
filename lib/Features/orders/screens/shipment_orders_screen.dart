import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:Tosell/core/constants/spaces.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:Tosell/core/widgets/CustomTextFormField.dart';
import 'package:Tosell/core/widgets/FillButton.dart';
import 'package:Tosell/Features/orders/models/Order.dart';
import 'package:Tosell/Features/orders/models/OrderFilter.dart';
import 'package:Tosell/Features/orders/widgets/order_card_item.dart';
import 'package:Tosell/Features/orders/providers/orders_provider.dart';
import 'package:Tosell/paging/generic_paged_list_view.dart';

class ShipmentOrdersScreen extends ConsumerStatefulWidget {
  final String shipmentId;
  final String? shipmentCode;

  const ShipmentOrdersScreen({
    super.key,
    required this.shipmentId,
    this.shipmentCode,
  });

  @override
  ConsumerState<ShipmentOrdersScreen> createState() => _ShipmentOrdersScreenState();
}

class _ShipmentOrdersScreenState extends ConsumerState<ShipmentOrdersScreen> {
  final TextEditingController _searchController = TextEditingController();
  late OrderFilter _currentFilter;

  @override
  void initState() {
    super.initState();
    // ✅ إنشاء فلتر للشحنة المحددة
    _currentFilter = OrderFilter(shipmentId: widget.shipmentId);

    // ✅ استدعاء البيانات عبر Provider بدلاً من Service مباشرة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(ordersNotifierProvider.notifier).getAll(
        page: 1,
        queryParams: _currentFilter.toJson(),
      );
    });
  }

  // ✅ دالة البحث عبر Provider
  void _performSearch(String searchTerm) {
    final searchFilter = OrderFilter(
      shipmentId: widget.shipmentId,
      code: searchTerm.isNotEmpty ? searchTerm : null,
    );

    ref.read(ordersNotifierProvider.notifier).getAll(
      page: 1,
      queryParams: searchFilter.toJson(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ✅ مراقبة حالة البيانات عبر Provider
    final ordersState = ref.watch(ordersNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: AppSpaces.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Header - منطق UI فقط
              _buildHeader(context),
              const Gap(AppSpaces.medium),

              // ✅ Search bar - منطق UI فقط
              _buildSearchBar(context),
              const Gap(AppSpaces.medium),

              // ✅ Title - منطق UI فقط
              _buildTitle(ordersState),
              const Gap(AppSpaces.small),

              // ✅ Orders list - استهلاك البيانات من Provider
              Expanded(
                child: ordersState.when(
                  data: (orders) => _buildOrdersList(orders),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (error, _) => _buildErrorState(error.toString()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ UI Methods - فصل منطق UI في دوال منفصلة
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: Icon(
              Icons.arrow_back_ios,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'طلبات الشحنة',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (widget.shipmentCode != null)
                  Text(
                    'رقم الشحنة: ${widget.shipmentCode}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: CustomTextFormField(
        controller: _searchController,
        label: '',
        showLabel: false,
        hint: 'رقم الطلب',
        prefixInner: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SvgPicture.asset(
            'assets/svg/search.svg',
            color: Theme.of(context).colorScheme.primary,
            width: 24,
            height: 24,
          ),
        ),
        onChanged: _performSearch,
      ),
    );
  }

  Widget _buildTitle(AsyncValue<List<Order>> ordersState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ordersState.when(
        data: (orders) => Text(
          'جميع طلبات الشحنة (${orders.length})',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        loading: () => const Text(
          'جميع طلبات الشحنة (جاري التحميل...)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        error: (_, __) => const Text(
          'جميع طلبات الشحنة',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersList(List<Order> orders) {
    if (orders.isEmpty) {
      return _buildNoOrdersFound();
    }

    return GenericPagedListView<Order>(
      key: ValueKey(_currentFilter.toJson()),
      fetchPage: (pageKey, _) async {
        return await ref.read(ordersNotifierProvider.notifier).getAll(
          page: pageKey,
          queryParams: _currentFilter.toJson(),
        );
      },
      itemBuilder: (context, order, index) => OrderCardItem(
        order: order,
        onTap: () => context.push(AppRoutes.orderDetails, extra: order.id),
      ),
      noItemsFoundIndicatorBuilder: _buildNoOrdersFound(),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'حدث خطأ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          const Gap(AppSpaces.small),
          Text(error),
          const Gap(AppSpaces.medium),
          FillButton(
            label: 'إعادة المحاولة',
            onPressed: () {
              // ✅ إعادة المحاولة عبر Provider
              ref.read(ordersNotifierProvider.notifier).getAll(
                page: 1,
                queryParams: _currentFilter.toJson(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNoOrdersFound() {
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
            'لا توجد طلبات في هذه الشحنة',
            style: context.textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.bold,
              color: const Color(0xffE96363),
            ),
          ),
          const Gap(AppSpaces.small),
          Text(
            'يبدو أن هذه الشحنة فارغة',
            style: context.textTheme.bodyLarge!.copyWith(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          const Gap(AppSpaces.large),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: FillButton(
              label: 'العودة',
              onPressed: () => context.pop(),
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}