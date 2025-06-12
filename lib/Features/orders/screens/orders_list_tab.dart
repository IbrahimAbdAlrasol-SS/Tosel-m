import 'package:gap/gap.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Tosell/core/constants/spaces.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:Tosell/core/widgets/FillButton.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Tosell/Features/orders/models/Order.dart';
import 'package:Tosell/paging/generic_paged_list_view.dart';
import 'package:Tosell/Features/orders/models/order_enum.dart';
import 'package:Tosell/Features/orders/models/OrderFilter.dart';
import 'package:Tosell/Features/orders/widgets/order_card_item.dart';
import 'package:Tosell/Features/orders/providers/orders_provider.dart';
import 'package:Tosell/Features/orders/screens/orders_screen.dart';

class OrdersListTab extends ConsumerStatefulWidget {
  final OrderFilter? filter;
  const OrdersListTab({super.key, this.filter});

  @override
  ConsumerState<OrdersListTab> createState() => _OrdersListTabState();
}

class _OrdersListTabState extends ConsumerState<OrdersListTab> {
  late OrderFilter _currentFilter;
  Widget build(BuildContext context) {
    final ordersState = ref.watch(ordersNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: AppSpaces.large),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.filter == null
                      ? ' جميع الطلبات'
                      : 'جميع الطلبات "${orderStatus[widget.filter?.status ?? 0].name}"',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              ordersState.when(
                data: (data) => _buildUi(data),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text(err.toString())),
              ),
            ],
          ),
        ),
      ),
    );
  }
  Expanded _buildUi(List<Order> data) {
    return Expanded(
      child: GenericPagedListView(
         key: ValueKey(widget.filter?.toJson()),
        noItemsFoundIndicatorBuilder: _buildNoItemsFound(),
        fetchPage: (pageKey, _) async {
          return await ref.read(ordersNotifierProvider.notifier).getAll(
            page: pageKey,
            queryParams: _currentFilter?.toJson(),
          );
        },
        itemBuilder: (context, order, index) => OrderCardItem(
          order: order,
          onTap: () => context.push(AppRoutes.orderDetails, extra: order.code),
        ),
      ),
    );
  }
  Widget _buildNoItemsFound() {
    return Column(
      children: [
        Image.asset('assets/svg/NoItemsFound.gif', width: 240, height: 240),
        Text(
          'لا توجد طلبات مضافة',
          style: context.textTheme.bodyLarge!.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xffE96363),
            fontSize: 24,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          'اضغط على زر “جديد” لإضافة طلب جديد و ارساله الى زبونك',
          style: context.textTheme.bodySmall!.copyWith(
            fontWeight: FontWeight.w500,
            color: const Color(0xff698596),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: FillButton(
            label: 'إضافة اول طلب',
            onPressed: () => context.push(AppRoutes.addOrder),
            icon: SvgPicture.asset('assets/svg/navigation_add.svg',
                color: const Color(0xffFAFEFD)),
            reverse: true,
          ),
        )
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _currentFilter = widget.filter ?? OrderFilter();
  }

}


