import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

typedef AsyncItemsCallback<T> = Future<List<T>> Function(String query);
typedef ItemAsStringCallback<T> = String Function(T item);
typedef ItemBuilderCallback<T> = Widget Function(BuildContext context, T item);

class RegistrationSearchDropDown<T> extends StatefulWidget {
  final String label;
  final String hint;
  final T? selectedValue;
  final AsyncItemsCallback<T> asyncItems;
  final ItemAsStringCallback<T> itemAsString;
  final ValueChanged<T?>? onChanged;
  final ItemBuilderCallback<T>? itemBuilder;
  final String emptyText;
  final String errorText;
  final bool enableRefresh; // ✅ مازال موجود لكن لن نستخدمه

  const RegistrationSearchDropDown({
    super.key,
    required this.label,
    required this.hint,
    this.selectedValue,
    required this.asyncItems,
    required this.itemAsString,
    this.onChanged,
    this.itemBuilder,
    this.emptyText = 'لا توجد نتائج',
    this.errorText = 'خطأ في تحميل البيانات',
    this.enableRefresh = false, // ✅ افتراضياً false
  });

  @override
  State<RegistrationSearchDropDown<T>> createState() => _RegistrationSearchDropDownState<T>();
}

class _RegistrationSearchDropDownState<T> extends State<RegistrationSearchDropDown<T>> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  List<T> _items = [];
  bool _isLoading = false;
  bool _hasError = false;
  bool _isDropdownOpen = false;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.selectedValue != null) {
      _controller.text = widget.itemAsString(widget.selectedValue!);
    }
    
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ✅ دالة جديدة للتعامل مع تغيير التركيز
  void _onFocusChanged() {
    if (_focusNode.hasFocus && !_isDropdownOpen) {
      setState(() {
        _isDropdownOpen = true;
      });
      // ✅ تحديث تلقائي عند فتح الـ dropdown
      _loadItems('');
    } else if (!_focusNode.hasFocus) {
      setState(() {
        _isDropdownOpen = false;
      });
    }
  }

  Future<void> _loadItems(String query) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final items = await widget.asyncItems(query);
      setState(() {
        _items = items;
        _isLoading = false;
        _lastQuery = query;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
        _items = [];
      });
    }
  }

  void _onItemSelected(T item) {
    setState(() {
      _controller.text = widget.itemAsString(item);
      _isDropdownOpen = false;
    });
    _focusNode.unfocus();
    widget.onChanged?.call(item);
  }

  void _onSearchChanged(String query) {
    if (query != _lastQuery) {
      _loadItems(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label.isNotEmpty) ...[
          Text(
            widget.label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
          const Gap(5),
        ],

        // Search Field
        TextFormField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(
              color: Color(0xFF9CA3AF),
              fontSize: 16,
              fontFamily: "Tajawal",
            ),
            filled: true,
            fillColor: const Color(0xFFF9FAFB),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(27.5),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(27.5),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(27.5),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.primary,
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            suffixIcon: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : Icon(
                    _isDropdownOpen ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFF6B7280),
                  ),
          ),
        ),

        // Dropdown Results
        if (_isDropdownOpen) ...[
          const Gap(4),
          Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFD1D5DB)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: _buildDropdownContent(),
          ),
        ],
      ],
    );
  }

  Widget _buildDropdownContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_hasError) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.errorText,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            // ✅ إزالة زر الـ refresh واستبداله بإعادة تحديث تلقائي
            TextButton(
              onPressed: () => _loadItems(_controller.text),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (_items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          widget.emptyText.isEmpty ? 'لا توجد نتائج' : widget.emptyText,
          style: const TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _items.length,
      itemBuilder: (context, index) {
        final item = _items[index];
        return InkWell(
          onTap: () => _onItemSelected(item),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: index < _items.length - 1
                  ? const Border(bottom: BorderSide(color: Color(0xFFE5E7EB)))
                  : null,
            ),
            child: widget.itemBuilder?.call(context, item) ??
                Text(
                  widget.itemAsString(item),
                  style: const TextStyle(
                    fontSize: 16,
                    fontFamily: "Tajawal",
                  ),
                ),
          ),
        );
      },
    );
  }
}