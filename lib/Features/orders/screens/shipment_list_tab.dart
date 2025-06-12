import 'package:Tosell/Features/orders/models/Order.dart';
import 'package:Tosell/Features/orders/models/OrderFilter.dart';
import 'package:Tosell/Features/orders/models/Shipment.dart';
import 'package:Tosell/Features/orders/providers/orders_provider.dart';
import 'package:Tosell/Features/orders/providers/shipments_provider.dart';
import 'package:Tosell/Features/orders/widgets/shipment_cart_Item.dart';
import 'package:Tosell/paging/generic_paged_grid_view.dart';
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
  final FetchPage<Shipment> fetchPage;
  final OrderFilter? filter;
  const shipmentInfoTab({super.key, this.filter, required this.fetchPage});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _shipmentInfoTabState();
}

class _shipmentInfoTabState extends ConsumerState<shipmentInfoTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context); 

    return GenericPagedListView<Shipment>(
      itemBuilder: (context, shipment, index) =>
          ShipmentCartItem(shipment: shipment),
      fetchPage: (page, filter) async {
        return await widget.fetchPage(page);
      },
    );
  }
}
