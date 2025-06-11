import 'package:Tosell/Features/orders/models/OrderFilter.dart';
import 'package:Tosell/Features/orders/models/Shipment.dart';
import 'package:Tosell/Features/orders/models/order_enum.dart';
import 'package:Tosell/Features/orders/providers/orders_provider.dart';
import 'package:Tosell/Features/orders/providers/shipments_provider.dart';
import 'package:Tosell/Features/orders/screens/orders_filter_bottom_sheet.dart';
import 'package:Tosell/Features/orders/widgets/shipment_cart_Item.dart';
import 'package:gap/gap.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Tosell/core/constants/spaces.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:Tosell/core/widgets/FillButton.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Tosell/paging/generic_paged_list_view.dart';
import 'package:Tosell/core/widgets/CustomTextFormField.dart';

class shipmentInfoTab extends ConsumerStatefulWidget {
  final OrderFilter? filter;
  const shipmentInfoTab({super.key, this.filter});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _shipmentInfoTabState();
}

class _shipmentInfoTabState extends ConsumerState<shipmentInfoTab>
    with SingleTickerProviderStateMixin {
  final int _selectedIndex = 0;
  final _refreshKey = GlobalKey<RefreshIndicatorState>();

  // Helper to fetch page 1 with current filter
  Future<void> _refresh() async {
    await ref.read(ordersNotifierProvider.notifier).getAll(
          page: 1,
          queryParams: widget.filter?.toJson(),
        );
  }

  @override
  void didUpdateWidget(covariant shipmentInfoTab oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the filter changes, refetch & show the refresh spinner
    if (widget.filter != oldWidget.filter) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _refreshKey.currentState
            ?.show(); // triggers the pull‑to‑refresh animation
      });
      _refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final shipmentsState = ref.watch(shipmentsNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: AppSpaces.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Gap(10),
                  Expanded(
                    child: CustomTextFormField(
                      label: '',
                      showLabel: false,
                      hint: 'رقم الوصل',
                      prefixInner: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SvgPicture.asset(
                          'assets/svg/search.svg',
                          color: Theme.of(context).colorScheme.primary,
                          width: 3,
                          height: 3,
                        ),
                      ),
                    ),
                  ),
                  const Gap(AppSpaces.medium),
                  GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        isScrollControlled: true,
                        context: context,
                        builder: (_) => const OrdersFilterBottomSheet(),
                      );
                    },
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: widget.filter?.status == null
                                    ? Theme.of(context).colorScheme.outline
                                    : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SvgPicture.asset(
                                'assets/svg/Funnel.svg',
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        if (widget.filter != null)
                          Positioned(
                            top: 6,
                            right: 10,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(5),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.filter == null
                      ? ' جميع الوصولات'
                      : 'جميع الطلبات "${orderStatus[widget.filter?.status ?? 0].name}"',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              shipmentsState.when(
                data: _buildUi,
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text(err.toString())),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Wrap the paged list in a RefreshIndicator
  Expanded _buildUi(List<Shipment> data) {
    return Expanded(
      child: RefreshIndicator(
        key: _refreshKey,
        onRefresh: _refresh,
        child: GenericPagedListView(
          noItemsFoundIndicatorBuilder: _buildNoItemsFound(),
          fetchPage: (pageKey, _) async {
            return await ref.read(shipmentsNotifierProvider.notifier).getAll(
                  page: pageKey,
                  queryParams: widget.filter?.toJson(),
                );
          },
          itemBuilder: (context, shipment, index) => ShipmentCartItem(
            shipment: shipment,
            onTap: () => context.push(AppRoutes.orders,
                extra: OrderFilter(
                    shipmentId: shipment.id, shipmentCode: shipment.code)),
            // context.push(AppRoutes.orderDetails, extra: data[index].code),
          ),
        ),
      ),
    );
  }

  Widget _buildNoItemsFound() {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/svg/NoItemsFound.gif',
          width: 240,
          height: 240,
        ),
        const Gap(AppSpaces.medium),
        Text(
          'لاتوجد وصولات',
          style: context.textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.w700,
            color: context.colorScheme.primary,
            fontSize: 24,
          ),
        ),
      ],
    );
  }
}
