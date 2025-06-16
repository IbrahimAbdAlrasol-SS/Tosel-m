// import 'package:flutter/material.dart';
// import 'package:gif/gif.dart';
// import 'package:rampmanager/common_lib.dart';
// import 'package:rampmanager/data/models/operation_model.dart';
// import 'package:rampmanager/data/models/request_pickups_request_model.dart';
// import 'package:rampmanager/data/providers/complaints_provider.dart';
// import 'package:rampmanager/data/providers/operations_provider.dart';
// import 'package:rampmanager/data/services/clients/_clients.dart';
// import 'package:rampmanager/src/home/components/request_pickups_dialog.dart';
// import 'package:rampmanager/src/home/components/time_box.dart';
// import 'package:rampmanager/src/home/components/upload_complaint_dialog.dart';
// import 'package:rampmanager/utils/widgets/buttons/filled_loading_button.dart';
// import 'package:stop_watch_timer/stop_watch_timer.dart';

// class OperationCheckingWidget extends StatefulHookConsumerWidget {
//   const OperationCheckingWidget({super.key, required this.operation});

//   final OperationModel operation;

//   @override
//   ConsumerState<ConsumerStatefulWidget> createState() =>
//       _OperationCheckingWidgetState();
// }

// class _OperationCheckingWidgetState
//     extends ConsumerState<OperationCheckingWidget>
//     with TickerProviderStateMixin {
//   late final GifController _controller;
//   late final StopWatchTimer _stopWatchTimer;
//   int secondTime = 0;
//   int minuteTime = 0;

//   int getPresetMillisecond() {
//     final startDateTime = widget.operation.startDateTime ?? DateTime.now();
//     debugPrint("startDateTime: $startDateTime");

//     final now = DateTime.now();
//     debugPrint("now: $now");
//     final difference = now.difference(startDateTime);
//     debugPrint("difference: $difference");
//     return difference.inMilliseconds;
//   }

//   @override
//   void initState() {
//     super.initState();
//     _controller = GifController(vsync: this);

//     _stopWatchTimer = StopWatchTimer(
//         mode: StopWatchMode.countUp, presetMillisecond: getPresetMillisecond());
//     _stopWatchTimer.onStartTimer();

//     _stopWatchTimer.minuteTime.listen((value) {
//       if (mounted) {
//         setState(() {
//           minuteTime = value;
//         });
//       }
//     });

//     _stopWatchTimer.secondTime.listen((value) {
//       if (mounted) {
//         setState(() {
//           secondTime = value;
//         });
//       }
//     });
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     _stopWatchTimer.onStopTimer();
//     _stopWatchTimer.onResetTimer();
//     _stopWatchTimer.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final operationStartingState = ref.watch(startingProvider);
//     final uploadComplaintState = ref.watch(uploadComplaintProvider);
//     final requestPickupsState = ref.watch(requestPickupsProvider);
//     return RowPadded(gap: Insets.medium, children: [
//       Expanded(
//         flex: 2,
//         child: Container(
//           padding: Insets.mediumAll,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(24),
//             border: Border.all(
//               width: 1,
//               color: const Color(0xffEEF1F7),
//             ),
//           ),
//           child: CustomScrollView(
//             slivers: [
//               SliverToBoxAdapter(
//                 child: Text(
//                   "تفاصيل العملية",
//                   style: TextStyle(
//                     color: context.colorScheme.primaryText,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ),
//               SliverToBoxAdapter(
//                 child: Divider(
//                   thickness: 0.25,
//                   color: context.colorScheme.outline,
//                 ),
//               ),
//               SliverToBoxAdapter(
//                 child: ListTile(
//                   leading: SvgPicture.asset(Assets.assetsSvgServiceTypeRounded),
//                   title: Text(
//                     "نوع الخدمة",
//                     style: TextStyle(
//                       color: const Color(0xff87A0C4),
//                       fontSize: 14,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                   subtitle: Text(
//                     widget.operation.truckTrip?.dischargeType
//                             ?.getName(context) ??
//                         "",
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                 ),
//               ),
//               SliverToBoxAdapter(
//                 child: Divider(
//                   thickness: 0.25,
//                   color: context.colorScheme.outline,
//                 ),
//               ),
//               SliverToBoxAdapter(
//                 child: ListTile(
//                   leading: SvgPicture.asset(Assets.assetsSvgPickupRounded),
//                   title: Text(
//                     "عدد مركبات الحمل",
//                     style: TextStyle(
//                       color: const Color(0xff87A0C4),
//                       fontSize: 14,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                   subtitle: Text(
//                     widget.operation.pickupTrips?.length.toString() ?? "",
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.w400,
//                     ),
//                   ),
//                 ),
//               ),
//               const SliverGap(Insets.medium),
//               SliverToBoxAdapter(
//                 child: Text(
//                   "تفاصيل البضاعة",
//                   style: TextStyle(
//                     color: context.colorScheme.primaryText,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ),
//               SliverToBoxAdapter(
//                 child: Divider(
//                   thickness: 0.25,
//                   color: context.colorScheme.outline,
//                 ),
//               ),
//               if (widget.operation.cargoTypes != null &&
//                   widget.operation.cargoTypes!.isNotEmpty)
//                 SliverList.separated(
//                   itemCount: widget.operation.cargoTypes!.length,
//                   itemBuilder: (context, index) {
//                     final cargoType = widget.operation.cargoTypes![index];
//                     return RowPadded(children: [
//                       SvgPicture.asset(Assets.assetsSvgItemRounded),
//                       Expanded(
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: Center(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       "نوع البضاعة",
//                                       style: TextStyle(
//                                         color: const Color(0xff87A0C4),
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w700,
//                                       ),
//                                     ),
//                                     Text(
//                                       cargoType.cargoTypeName ?? "",
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w400,
//                                       ),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: Center(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       "العدد",
//                                       style: TextStyle(
//                                         color: const Color(0xff87A0C4),
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w700,
//                                       ),
//                                     ),
//                                     Text(
//                                       cargoType.quantity?.toString() ?? "",
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w400,
//                                       ),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             ),
//                             Expanded(
//                               child: Center(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       "الوزن",
//                                       style: TextStyle(
//                                         color: const Color(0xff87A0C4),
//                                         fontSize: 14,
//                                         fontWeight: FontWeight.w700,
//                                       ),
//                                     ),
//                                     Text(
//                                       "${cargoType.weight?.toString() ?? ""} كغم",
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         fontWeight: FontWeight.w400,
//                                       ),
//                                     )
//                                   ],
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ]);
//                   },
//                   separatorBuilder: (context, index) {
//                     return const Divider(
//                       thickness: 0.25,
//                       color: Color(0xffE5E5E5),
//                     );
//                   },
//                 ),
//               // SizedBox(
//               //   width: context.width,
//               //   child: OutlinedButton.icon(
//               //     onPressed: () async {
//               //       if (_stopWatchTimer.isRunning) {
//               //         _stopWatchTimer.onStopTimer();
//               //       } else {
//               //         _stopWatchTimer.onStartTimer();
//               //       }
//               //       setState(() {});
//               //     },
//               //     label: Text(_stopWatchTimer.isRunning
//               //         ? "ايقاف العملية"
//               //         : "استئناف العملية"),
//               //     icon: Icon(
//               //       _stopWatchTimer.isRunning
//               //           ? Icons.stop_circle_outlined
//               //           : Icons.play_circle_outline,
//               //       color: _stopWatchTimer.isRunning
//               //           ? const Color(0xffFF0000)
//               //           : const Color(0xff008636),
//               //     ),
//               //   ),
//               // ),
//             ],
//           ),
//         ),
//       ),
//       Expanded(
//         flex: 3,
//         child: Container(
//           padding: Insets.mediumAll,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(24),
//             border: Border.all(
//               width: 1,
//               color: const Color(0xffEEF1F7),
//             ),
//           ),
//           child: SingleChildScrollView(
//             child: ColumnPadded(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 SizedBox(
//                   height: 150,
//                   width: 150,
//                   child: Gif(
//                     image: AssetImage(Assets.assetsImagesChecking),
//                     controller:
//                         _controller, // if duration and fps is null, original gif fps will be used.
//                     //fps: 30,
//                     //duration: const Duration(seconds: 3),
//                     autostart: Autostart.loop,
//                     placeholder: (context) => const Text('Loading...'),
//                     onFetchCompleted: () {
//                       _controller.reset();
//                       _controller.forward();
//                     },
//                   ),
//                 ),
//                 Text(
//                   "جاري عملية الفحص",
//                   style: TextStyle(
//                     color: context.colorScheme.primaryText,
//                     fontSize: 24,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 RowPadded(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       TimeBox(
//                         time: secondTime.bitLength > 1
//                             ? "${secondTime % 60}"
//                             : "0${secondTime % 60}",
//                         label: "ثانية",
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.only(bottom: Insets.large),
//                         child: SvgPicture.asset(Assets.assetsSvgDots),
//                       ),
//                       TimeBox(
//                         time: minuteTime.bitLength > 1
//                             ? "${minuteTime % 60}"
//                             : "0${minuteTime % 60}",
//                         label: "دقيقة",
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.only(bottom: Insets.large),
//                         child: SvgPicture.asset(Assets.assetsSvgDots),
//                       ),
//                       TimeBox(
//                         time: "00",
//                         label: "ساعة",
//                       ),
//                     ]),
//                 SizedBox(
//                   width: context.width,
//                   child: FilledLoadingButton(
//                     isLoading: operationStartingState.isLoading,
//                     onPressed: () async {
//                       bool selected = false;
//                       if (widget.operation.pickupTrips != null) {
//                         selected = widget.operation.pickupTrips!
//                             .any((element) => element.selectExchange == true);
//                       }
//                       if (!selected) {
//                         context.showErrorSnackBar("No pickup trip selected");
//                         return;
//                       }
//                       final pickupTrip = widget.operation.pickupTrips
//                           ?.firstWhere(
//                               (element) => element.selectExchange == true);
//                       if (pickupTrip == null) {
//                         context.showErrorSnackBar("No pickup trip selected");
//                         return;
//                       }

//                       // final gateRequest = GateRequestModel(
//                       //   tripId: pickupTrip.id,
//                       //   vehicleType: VehicleType.pickup,
//                       // );
//                       // // todo: remove
//                       // final response = await ref
//                       //     .read(gatesClientProvider)
//                       //     .enterExchangeYard(gateRequest)
//                       //     .data;
//                       // debugPrint(
//                       //     "enter exchange yard response: ${response.toString()}");

//                       final state = await ref
//                           .read(startingProvider.notifier)
//                           .run(widget.operation.id);
//                       state.whenDataOrError(
//                         data: (data) {
//                           _stopWatchTimer.onStopTimer();
//                           _stopWatchTimer.onResetTimer();

//                           ref.refresh.call(getActiveOperationProvider(
//                               widget.operation.rampId!));
//                         },
//                         error: (error, stackTrace) {
//                           ref.refresh.call(getActiveOperationProvider(
//                               widget.operation.rampId!));
//                         },
//                       );
//                     },
//                     style: FilledButton.styleFrom(
//                       backgroundColor: const Color(0xff008636),
//                     ),
//                     child: RowPadded(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         SvgPicture.asset(Assets.assetsSvgLiftTruck),
//                         Text("اكمال الفحص وبدء بعملية التفريغ"),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   width: context.width,
//                   child: FilledLoadingButton(
//                     isLoading: uploadComplaintState.isLoading,
//                     onPressed: () async {
//                       final bool? isSuccess = await showDialog(
//                         context: context,
//                         builder: (context) {
//                           return UploadComplaintDialog(
//                             operationId: widget.operation.id,
//                           );
//                         },
//                       );
//                       if (isSuccess != null && isSuccess) {
//                         context.showSuccessSnackBar("تم ارسال الشكوى بنجاح");
//                       }
//                     },
//                     style: FilledButton.styleFrom(
//                       backgroundColor: const Color(0xffFFFDF5),
//                       side: BorderSide(
//                         color: const Color(0xffF5CE00),
//                         width: 1,
//                       ),
//                     ),
//                     child: RowPadded(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         SvgPicture.asset(Assets.assetsSvgInformationCircle),
//                         Text(
//                           "تبليغ عن مشكلة",
//                           style: TextStyle(
//                             color: const Color(0xff8F7800),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//       Expanded(
//         flex: 2,
//         child: Container(
//           padding: Insets.mediumAll,
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(24),
//             border: Border.all(
//               width: 1,
//               color: const Color(0xffEEF1F7),
//             ),
//           ),
//           child: CustomScrollView(
//             slivers: [
//               SliverToBoxAdapter(
//                 child: Text(
//                   "تفاصيل الشاحنة",
//                   style: TextStyle(
//                     color: context.colorScheme.primaryText,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ),
//               const SliverGap(Insets.medium),
//               SliverToBoxAdapter(
//                 child: Divider(
//                   thickness: 0.25,
//                   color: context.colorScheme.outline,
//                 ),
//               ),
//               const SliverGap(Insets.medium),
//               SliverToBoxAdapter(
//                 child: Container(
//                   decoration: BoxDecoration(
//                     border: Border.all(
//                       color: Color(0xffEEF1F7),
//                       width: 1,
//                     ),
//                     borderRadius: BorderRadius.circular(BorderSize.small),
//                   ),
//                   padding: Insets.extraSmallAll,
//                   child: ListTile(
//                     leading: Image.asset(Assets.assetsImagesTruckRounded),
//                     title: Text(
//                       "الرقم",
//                       style: TextStyle(
//                         fontSize: 14,
//                         fontWeight: FontWeight.w700,
//                         color: const Color(0xff87A0C4),
//                       ),
//                     ),
//                     subtitle: Text(
//                       "${widget.operation.truckTrip?.plateNumber} - ${widget.operation.truckTrip?.plateCharacter ?? ""} / ${widget.operation.truckTrip?.provinceName ?? ""}",
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w400,
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//               const SliverGap(Insets.medium),
//               SliverToBoxAdapter(
//                 child: Text(
//                   "مركبات الحمل",
//                   style: TextStyle(
//                     color: context.colorScheme.primaryText,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//               ),
//               SliverToBoxAdapter(
//                 child: Divider(
//                   thickness: 0.25,
//                   color: context.colorScheme.outline,
//                 ),
//               ),
//               if (widget.operation.pickupTrips != null &&
//                   widget.operation.pickupTrips!.isNotEmpty)
//                 SliverList.separated(
//                   itemBuilder: (context, index) {
//                     return Container(
//                       decoration: BoxDecoration(
//                         border: Border.all(
//                           color: widget
//                                   .operation.pickupTrips![index].selectExchange
//                               ? Colors.green
//                               : Color(0xffEEF1F7),
//                           width: 1,
//                         ),
//                         borderRadius: BorderRadius.circular(BorderSize.small),
//                       ),
//                       padding: Insets.mediumAll,
//                       child: RowPadded(
//                         children: [
//                           Image.asset(Assets.assetsImagesVan,
//                               width: 50, height: 50),
//                           Expanded(
//                             child: ColumnPadded(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               gap: Insets.small,
//                               children: [
//                                 Text(
//                                   "الرقم",
//                                   style: TextStyle(
//                                     fontSize: 14,
//                                     fontWeight: FontWeight.w700,
//                                     color: const Color(0xff87A0C4),
//                                   ),
//                                 ),
//                                 Text(
//                                   "${widget.operation.pickupTrips?[index].plateNumber} - ${widget.operation.pickupTrips?[index].plateCharacter ?? ""} / ${widget.operation.pickupTrips?[index].provinceName ?? ""}",
//                                   style: TextStyle(
//                                     fontSize: 16,
//                                     fontWeight: FontWeight.w400,
//                                   ),
//                                 ),
//                                 if (widget.operation.pickupTrips![index]
//                                             .cargoTypes !=
//                                         null &&
//                                     widget.operation.pickupTrips![index]
//                                         .cargoTypes!.isNotEmpty)
//                                   Text(
//                                       "نوع البضاعة: ${widget.operation.pickupTrips![index].cargoTypes?.map((cargoType) => cargoType.name ?? "").join(", ") ?? ""}"),
//                               ],
//                             ),
//                           ),
//                           widget.operation.pickupTrips![index].selectExchange
//                               ? Text(
//                                   "قيد التحميل",
//                                   style: TextStyle(color: Colors.green),
//                                 )
//                               : const SizedBox(),
//                         ],
//                       ),
//                     );
//                   },
//                   separatorBuilder: (context, index) {
//                     return const Gap(Insets.medium);
//                   },
//                   itemCount: widget.operation.pickupTrips!.length,
//                 ),
//               const SliverGap(Insets.medium),
//               SliverToBoxAdapter(
//                 child: SizedBox(
//                   width: context.width,
//                   child: FilledLoadingButton(
//                       isLoading: requestPickupsState.isLoading,
//                       onPressed: () async {
//                         final int? count = await showDialog(
//                           context: context,
//                           builder: (context) {
//                             return RequestPickupsDialog();
//                           },
//                         );
//                         if (count == null) return;
//                         final body = RequestPickupsRequestModel(
//                             truckTripId: widget.operation.truckTripId!,
//                             count: count);
//                         final state = await ref
//                             .read(requestPickupsProvider.notifier)
//                             .run(body);
//                         state.whenDataOrError(
//                           data: (data) {
//                             context.showSuccessSnackBar(
//                                 "تم تعيين مركبات جديدة بنجاح");
//                             ref.refresh.call(getActiveOperationProvider(
//                                 widget.operation.rampId!));
//                           },
//                           error: (error, stackTrace) {
//                             context.showSuccessSnackBar(
//                                 "تم تعيين مركبات جديدة بنجاح");
//                             ref.refresh.call(getActiveOperationProvider(
//                                 widget.operation.rampId!));
//                           },
//                         );
//                       },
//                       child: Text("طلب مركبات حمل")),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ]);
//   }
// }
