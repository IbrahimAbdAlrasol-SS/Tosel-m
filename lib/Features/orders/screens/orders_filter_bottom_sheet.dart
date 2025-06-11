import 'package:Tosell/Features/orders/models/OrderFilter.dart';
import 'package:Tosell/Features/orders/models/order_enum.dart';
import 'package:Tosell/core/constants/spaces.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:Tosell/core/widgets/CustomTextFormField.dart';
import 'package:Tosell/core/widgets/DatePickerTextField%20.dart';
import 'package:Tosell/core/widgets/FillButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class OrdersFilterBottomSheet extends ConsumerStatefulWidget {
  final bool isForShipments; // ✅ Add flag to distinguish between orders and shipments
  
  const OrdersFilterBottomSheet({
    super.key,
    this.isForShipments = false,
  });

  @override
  ConsumerState<OrdersFilterBottomSheet> createState() =>
      _OrdersFilterBottomSheetState();
}

class _OrdersFilterBottomSheetState
    extends ConsumerState<OrdersFilterBottomSheet> {
  // ✅ Form controllers
  final TextEditingController orderStateController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final TextEditingController provinceController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController priorityController = TextEditingController();
  
  // ✅ State variables
  String? selectedState;
  bool _anyFilter = false;

  @override
  void initState() {
    super.initState();
    _initializeListeners();
    _setDefaultValues();
  }

  /// ✅ Initialize form listeners
  void _initializeListeners() {
    orderStateController.addListener(_checkFilters);
    dateController.addListener(_checkFilters);
    provinceController.addListener(_checkFilters);
    areaController.addListener(_checkFilters);
    priorityController.addListener(_checkFilters);
  }

  /// ✅ Set default values
  void _setDefaultValues() {
    selectedState = orderStatus.isNotEmpty ? orderStatus[0].name : null;
  }

  /// ✅ Check if any filters are applied
  void _checkFilters() {
    setState(() {
      _anyFilter = orderStateController.text.isNotEmpty ||
          dateController.text.isNotEmpty ||
          provinceController.text.isNotEmpty ||
          areaController.text.isNotEmpty ||
          priorityController.text.isNotEmpty;
    });
  }

  /// ✅ Clear all filters
  void _clearFilters() {
    setState(() {
      orderStateController.clear();
      dateController.clear();
      provinceController.clear();
      areaController.clear();
      priorityController.clear();
      _anyFilter = false;
    });
  }

  /// ✅ Apply filters and return result
  void _applyFilters() {
    final filter = OrderFilter(
      status: orderStateController.text.isNotEmpty 
          ? int.tryParse(orderStateController.text) 
          : null,
      // ✅ Add more filter properties as needed
      zoneId: provinceController.text.isNotEmpty 
          ? provinceController.text 
          : null,
    );

    context.pop(filter);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7, // ✅ Increased height
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(23),
          topRight: Radius.circular(23),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ Header with title and clear button
          _buildHeader(),
          
          // ✅ Scrollable filter content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpaces.medium),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Gap(AppSpaces.medium),
                  
                  // ✅ Status filter
                  _buildStatusFilter(),
                  
                  const Gap(AppSpaces.large),
                  
                  // ✅ Date filter
                  _buildDateFilter(),
                  
                  const Gap(AppSpaces.large),
                  
                  // ✅ Location filter
                  _buildLocationFilter(),
                  
                  // ✅ Additional filters for shipments
                  if (widget.isForShipments) ...[
                    const Gap(AppSpaces.large),
                    _buildShipmentSpecificFilters(),
                  ],
                  
                   Gap(AppSpaces.large),
                ],
              ),
            ),
          ),
          
          // ✅ Action buttons
          _buildActionButtons(),
        ],
      ),
    );
  }

  /// ✅ Build header with title and clear button
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(AppSpaces.medium),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.isForShipments ? 'تصفية الشحنات' : 'تصفية الطلبات',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          GestureDetector(
            onTap: _clearFilters,
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/svg/FunnelX.svg',
                  color: _anyFilter
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.secondary,
                ),
                const Gap(AppSpaces.exSmall),
                Text(
                  'حذف التصفية',
                  style: TextStyle(
                    color: _anyFilter
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ Build status filter
  Widget _buildStatusFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.isForShipments ? 'حالة الشحنة' : 'حالة الطلب',
          style: context.textTheme.bodyLarge!.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Gap(AppSpaces.small),
        CustomTextFormField<String>(
          controller: orderStateController,
          label: '',
          showLabel: false,
          hint: widget.isForShipments ? 'اختر حالة الشحنة' : 'اختر حالة الطلب',
          dropdownItems: [
            ...orderStatus.map(
              (state) => DropdownMenuItem<String>(
                value: state.value.toString(),
                child: Text(state.name ?? ''),
              ),
            ),
          ],
          suffixInner: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SvgPicture.asset(
              "assets/svg/CaretDown.svg",
              width: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          selectedValue: orderStateController.text.isNotEmpty
              ? orderStateController.text
              : null,
          onDropdownChanged: (value) {
            if (value != null) {
              setState(() {
                selectedState = orderStatus[int.parse(value)].name;
                orderStateController.text = value;
              });
            }
          },
        ),
      ],
    );
  }

  /// ✅ Build date filter
  Widget _buildDateFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التاريخ',
          style: context.textTheme.bodyLarge!.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Gap(AppSpaces.small),
        DatePickerTextField(
          controller: dateController,
          readOnly: true,
          hint: 'اختر التاريخ',
          hintStyle: const TextStyle(color: Color(0xFF698596)),
          onChanged: (value) {},
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'يرجى اختيار تاريخ صالح';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// ✅ Build location filter
  Widget _buildLocationFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الموقع',
          style: context.textTheme.bodyLarge!.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Gap(AppSpaces.small),
        
        // Province dropdown
        CustomTextFormField<String>(
          controller: provinceController,
          hint: 'المحافظة',
          dropdownItems: const [
            DropdownMenuItem(value: "1", child: Text("بغداد")),
            DropdownMenuItem(value: "2", child: Text("الحلة")),
            DropdownMenuItem(value: "3", child: Text("البصرة")),
            DropdownMenuItem(value: "4", child: Text("أربيل")),
            DropdownMenuItem(value: "5", child: Text("النجف")),
          ],
          onDropdownChanged: (value) {
            if (value != null) {
              setState(() {
                provinceController.text = value;
              });
            }
          },
          label: '',
          showLabel: false,
          suffixInner: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SvgPicture.asset(
              "assets/svg/CaretDown.svg",
              width: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        
        const Gap(AppSpaces.small),
        
        // Area dropdown
        CustomTextFormField<String>(
          controller: areaController,
          hint: 'المنطقة',
          dropdownItems: const [
            DropdownMenuItem(value: "1", child: Text("المنصور")),
            DropdownMenuItem(value: "2", child: Text("الكرادة")),
            DropdownMenuItem(value: "3", child: Text("الجادرية")),
            DropdownMenuItem(value: "4", child: Text("الكاظمية")),
            DropdownMenuItem(value: "5", child: Text("الشعب")),
          ],
          onDropdownChanged: (value) {
            if (value != null) {
              setState(() {
                areaController.text = value;
              });
            }
          },
          label: '',
          showLabel: false,
          suffixInner: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SvgPicture.asset(
              "assets/svg/CaretDown.svg",
              width: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  /// ✅ Build shipment-specific filters
  Widget _buildShipmentSpecificFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الأولوية',
          style: context.textTheme.bodyLarge!.copyWith(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const Gap(AppSpaces.small),
        CustomTextFormField<String>(
          controller: priorityController,
          hint: 'اختر الأولوية',
          dropdownItems: const [
            DropdownMenuItem(value: "0", child: Text("عادية")),
            DropdownMenuItem(value: "1", child: Text("مرتفعة")),
            DropdownMenuItem(value: "2", child: Text("عاجلة")),
          ],
          onDropdownChanged: (value) {
            if (value != null) {
              setState(() {
                priorityController.text = value;
              });
            }
          },
          label: '',
          showLabel: false,
          suffixInner: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SvgPicture.asset(
              "assets/svg/CaretDown.svg",
              width: 24,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  /// ✅ Build action buttons
  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(AppSpaces.medium),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          // ✅ Cancel button
          Expanded(
            child: OutlinedButton(
              onPressed: () => context.pop(),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('إلغاء'),
            ),
          ),
          
          const Gap(AppSpaces.medium),
          
          // ✅ Apply button
          Expanded(
            flex: 2,
            child: FillButton(
              label: "تطبيق الفلتر",
              onPressed: _applyFilters,
              icon: SvgPicture.asset(
                'assets/svg/Funnel.svg',
                color: Colors.white,
                width: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // ✅ Clean up controllers
    orderStateController.removeListener(_checkFilters);
    dateController.removeListener(_checkFilters);
    provinceController.removeListener(_checkFilters);
    areaController.removeListener(_checkFilters);
    priorityController.removeListener(_checkFilters);

    orderStateController.dispose();
    dateController.dispose();
    provinceController.dispose();
    areaController.dispose();
    priorityController.dispose();

    super.dispose();
  }
}