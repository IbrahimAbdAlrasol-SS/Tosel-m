// import 'package:gap/gap.dart';
// import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
// import 'package:Tosell/core/constants/spaces.dart';
// import 'package:Tosell/core/utils/extensions.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:Tosell/Features/orders/models/Shipment.dart';
// import 'package:Tosell/Features/orders/models/OrderFilter.dart';
// import 'package:Tosell/Features/orders/widgets/shipment_cart_Item.dart';
// import 'package:Tosell/Features/orders/providers/shipments_provider.dart';

// class shipmentInfoTab extends ConsumerStatefulWidget {
//   final OrderFilter? filter;
//   const shipmentInfoTab({super.key, this.filter});

//   @override
//   ConsumerState<shipmentInfoTab> createState() => _shipmentInfoTabState();
// }

// class _shipmentInfoTabState extends ConsumerState<shipmentInfoTab> {
//   late OrderFilter _currentFilter;

//   @override
//   void initState() {
//     super.initState();
//     _currentFilter = widget.filter ?? OrderFilter();
//   }

//   @override
//   void didUpdateWidget(covariant shipmentInfoTab oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (widget.filter != oldWidget.filter) {
//       _currentFilter = widget.filter ?? OrderFilter();
//     }
//   }

//   void _handleShipmentTap(Shipment shipment) {
//     context.push(
//       '/shipment-orders', 
//       extra: {
//         'shipmentId': shipment.id,
//         'shipmentCode': shipment.code,
//       },
//     );
//   }

//   String _getSectionTitle() {
//     if (_currentFilter.status != null) {
//       return 'الشحنات المفلترة';
//     } else {
//       return 'جميع الوصولات';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final shipmentsState = ref.watch(shipmentsNotifierProvider);

//     return Scaffold(
//       backgroundColor: Colors.transparent,
//       body: SafeArea(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Section title
//             _buildSectionTitle(shipmentsState),
            
//             const Gap(AppSpaces.small),
            
//             // Shipments list
//             Expanded(
//               child: shipmentsState.when(
//                 data: (shipments) => _buildShipmentsList(shipments),
//                 loading: () => const Center(child: CircularProgressIndicator()),
//                 error: (err, _) => _buildErrorState(err.toString()),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildSectionTitle(AsyncValue<List<Shipment>> shipmentsState) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 16),
//       child: shipmentsState.when(
//         data: (shipments) {
//           final filteredCount = shipments.length;
//           return Text(
//             '${_getSectionTitle()} ($filteredCount)',
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//           );
//         },
//         loading: () => Text(
//           '${_getSectionTitle()} (جاري التحميل...)',
//           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//         error: (_, __) => Text(
//           _getSectionTitle(),
//           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//         ),
//       ),
//     );
//   }

//   Widget _buildShipmentsList(List<Shipment> shipments) {
//     if (shipments.isEmpty) return _buildNoItemsFound();

//     return ListView.builder(
//       itemCount: shipments.length,
//       itemBuilder: (context, index) => _buildShipmentItem(shipments[index]),
//     );
//   }

//   Widget _buildShipmentItem(Shipment shipment) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 200),
//       margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//       child: ShipmentCartItem(
//         shipment: shipment,
//         onTap: () => _handleShipmentTap(shipment),
//       ),
//     );
//   }

//   Widget _buildErrorState(String error) {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.error_outline, size: 64, color: Theme.of(context).colorScheme.error),
//           const Gap(AppSpaces.medium),
//           Text('حدث خطأ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.error)),
//           const Gap(AppSpaces.small),
//           Text(error, textAlign: TextAlign.center, style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
//           const Gap(AppSpaces.medium),
//           ElevatedButton(
//             onPressed: () => ref.read(shipmentsNotifierProvider.notifier).refresh(),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Theme.of(context).colorScheme.primary,
//               foregroundColor: Colors.white,
//               padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//             ),
//             child: const Text('إعادة المحاولة'),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildNoItemsFound() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Image.asset('assets/svg/NoItemsFound.gif', width: 240, height: 240),
//           const Gap(AppSpaces.medium),
//           Text(
//             'لا توجد وصولات',
//             style: context.textTheme.bodyLarge!.copyWith(
//               fontWeight: FontWeight.w700,
//               color: context.colorScheme.primary,
//               fontSize: 24,
//             ),
//           ),
//           const Gap(AppSpaces.small),
//           Text(
//             'لم يتم العثور على أي شحنات',
//             textAlign: TextAlign.center,
//             style: context.textTheme.bodySmall!.copyWith(
//               fontWeight: FontWeight.w500,
//               color: const Color(0xff698596),
//               fontSize: 16,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }