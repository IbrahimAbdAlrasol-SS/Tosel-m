import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:Tosell/core/constants/spaces.dart';
import 'package:Tosell/core/utils/extensions.dart';

class RegistrationSearchDropDown<T> extends StatefulWidget {
  final String label;
  final String hint;
  final T? selectedValue;
  final String Function(T) itemAsString;
  final void Function(T?) onChanged;
  final String? Function(String?)? validator;
  final Future<List<T>> Function(String query) asyncItems;
  final Widget Function(BuildContext, T)? itemBuilder;
  final String emptyText;
  final String errorText;
  final bool enableRefresh;
  const RegistrationSearchDropDown({
    super.key,
    required this.label,
    required this.hint,
    this.selectedValue,
    required this.itemAsString,
    required this.onChanged,
    this.validator,
    required this.asyncItems,
    this.itemBuilder,
    this.emptyText = "لا توجد نتائج",
    this.errorText = "حدث خطأ أثناء البحث",
    this.enableRefresh = true,
  });
  @override
  State<RegistrationSearchDropDown<T>> createState() =>
      _RegistrationSearchDropDownState<T>();
}

class _RegistrationSearchDropDownState<T>
    extends State<RegistrationSearchDropDown<T>>
    with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<T> _suggestions = [];
  bool _isLoading = false;
  bool _showDropdown = false;
  bool _hasError = false;
  T? _selectedItem;
  Timer? _debounceTimer;
  String _lastQuery = '';
  bool _hasLoadedInitial = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  @override
  void initState() {
    super.initState();
    _selectedItem = widget.selectedValue;
    if (_selectedItem != null) {
      _controller.text = widget.itemAsString(_selectedItem!);
    }
    _setupAnimations();
    _focusNode.addListener(_onFocusChanged);
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _animationController.dispose();
    _debounceTimer?.cancel();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _showSuggestions();

      // ريفرش عند الضغط على الـ TextField
      if (!_hasLoadedInitial) {
        _loadInitialData();
      } else {
        // ريفرش البيانات في كل مرة يتم الضغط
        _manualRefresh();
      }

      final currentText = _controller.text.trim();
      if (currentText.isNotEmpty && currentText != _lastQuery) {
        _searchItems(currentText, immediate: true);
      }
    } else {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (!_focusNode.hasFocus) {
          _hideSuggestions();
        }
      });
    }
  }

  Future<void> _loadInitialData() async {
    if (_hasLoadedInitial) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });
    try {
      final results = await widget.asyncItems('');
      if (mounted) {
        setState(() {
          _suggestions = results.take(10).toList();
          _isLoading = false;
          _hasError = false;
          _hasLoadedInitial = true;
        });
        _updateOverlay();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _suggestions = [];
          _isLoading = false;
          _hasError = true;
        });
        _updateOverlay();
      }
    }
  }

  void _onTextChanged(String value) {
    final trimmedValue = value.trim();

    if (trimmedValue != _lastQuery) {
      setState(() {
        _suggestions = [];
        _hasError = false;
      });
      _updateOverlay();
    }

    _debounceTimer?.cancel();

    if (trimmedValue.isNotEmpty) {
      setState(() => _isLoading = true);
      // بحث فوري مع تأخير قصير
      _debounceTimer = Timer(const Duration(milliseconds: 100), () {
        _searchItems(trimmedValue);
      });
    } else {
      setState(() {
        _isLoading = false;
        _hasError = false;
      });
      if (_hasLoadedInitial) {
        _loadInitialData();
      }
    }
    _lastQuery = trimmedValue;
  }

  Future<void> _searchItems(String query, {bool immediate = false}) async {
    if (!mounted) return;

    if (!immediate) {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });
    }
    try {
      print('🔍 بحث: "$query"');
      final results = await widget.asyncItems(query);
      if (mounted && (query.isEmpty || query == _controller.text.trim())) {
        setState(() {
          _suggestions = results;
          _isLoading = false;
          _hasError = false;
        });
        _updateOverlay();
      }
    } catch (e) {
      if (mounted && (query.isEmpty || query == _controller.text.trim())) {
        setState(() {
          _suggestions = [];
          _isLoading = false;
          _hasError = true;
        });
        _updateOverlay();
      }
    }
  }

  void _showSuggestions() {
    if (!_showDropdown) {
      setState(() => _showDropdown = true);
      _createOverlay();
      _animationController.forward();
    }
  }

  void _hideSuggestions() {
    if (_showDropdown) {
      _animationController.reverse().then((_) {
        if (mounted) {
          setState(() => _showDropdown = false);
          _removeOverlay();
        }
      });
    }
  }

  void _createOverlay() {
    _removeOverlay();
    _overlayEntry = OverlayEntry(builder: _buildOverlay);
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _updateOverlay() {
    _overlayEntry?.markNeedsBuild();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _selectItem(T item) {
    setState(() {
      _selectedItem = item;
      _controller.text = widget.itemAsString(item);
      _suggestions = [];
    });
    widget.onChanged(item);
    _focusNode.unfocus();
    _hideSuggestions();
  }

  void _clearSelection() {
    setState(() {
      _selectedItem = null;
      _controller.clear();
      _suggestions = [];
      _lastQuery = '';
      _hasLoadedInitial = false;
    });
    widget.onChanged(null);
    _focusNode.requestFocus();
  }

  Future<void> _manualRefresh() async {
    _hasLoadedInitial = false;
    if (_controller.text.trim().isNotEmpty) {
      await _searchItems(_controller.text.trim(), immediate: true);
    } else {
      await _loadInitialData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const Gap(AppSpaces.small),
          TextFormField(
            controller: _controller,
            focusNode: _focusNode,
            validator: widget.validator,
            onChanged: _onTextChanged,
            onTap: () {
              // ريفرش عند الضغط على الحقل
              if (!_focusNode.hasFocus) {
                _focusNode.requestFocus();
              }
              _manualRefresh();
            },
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: widget.hint,
              hintStyle: const TextStyle(
                color: Color(0xFF698596),
                fontWeight: FontWeight.w400,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide(color: context.colorScheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide(color: context.colorScheme.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: BorderSide(
                  color: context.colorScheme.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(28),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              suffixIcon: _buildSuffixIcon(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuffixIcon() {
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.all(12.0),
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(
              context.colorScheme.primary,
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (_selectedItem != null)
          IconButton(
            onPressed: _clearSelection,
            icon: Icon(
              Icons.clear,
              color: context.colorScheme.secondary,
              size: 20,
            ),
            tooltip: 'مسح الاختيار',
          )
        else
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Icon(
              Icons.search,
              color: context.colorScheme.primary,
              size: 20,
            ),
          ),
      ],
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return Positioned(
      width: MediaQuery.of(context).size.width - 32,
      child: CompositedTransformFollower(
        link: _layerLink,
        showWhenUnlinked: false,
        offset: const Offset(0, 70),
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(16),
          shadowColor: Colors.black26,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 200),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.colorScheme.outline.withOpacity(0.3),
                ),
              ),
              child: _buildContent(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  context.colorScheme.primary,
                ),
              ),
            ),
            const Gap(12),
            Text(
              'جاري التحميل...',
              style: TextStyle(
                color: context.colorScheme.secondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }
    if (_hasError) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 28,
            ),
            const Gap(8),
            Text(
              widget.errorText,
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(8),
            TextButton.icon(
              onPressed: _manualRefresh,
              icon: Icon(Icons.refresh, size: 16),
              label: Text('إعادة المحاولة'),
              style: TextButton.styleFrom(
                foregroundColor: context.colorScheme.primary,
              ),
            ),
          ],
        ),
      );
    }
    if (_suggestions.isEmpty) {
      return const SizedBox.shrink();
    }
    return _buildSuggestionsListView();
  }

  Widget _buildSuggestionsListView() {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      shrinkWrap: true,
      itemCount: _suggestions.length,
      separatorBuilder: (context, index) => Divider(
        height: 1,
        color: context.colorScheme.outline.withOpacity(0.2),
      ),
      itemBuilder: (context, index) {
        final item = _suggestions[index];
        return InkWell(
          onTap: () => _selectItem(item),
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: widget.itemBuilder != null
                ? widget.itemBuilder!(context, item)
                : Text(
                    widget.itemAsString(item),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
          ),
        );
      },
    );
  }
}
