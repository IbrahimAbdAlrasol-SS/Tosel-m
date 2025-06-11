import 'package:Tosell/Features/orders/screens/orders_list_tab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MultiSelectManager {
  static void clearMultiSelectMode(WidgetRef ref) {
    ref.read(selectedOrdersProvider.notifier).state = <String>{};
    ref.read(isMultiSelectModeProvider.notifier).state = false;
  }
  
  static void toggleMultiSelectMode(WidgetRef ref) {
    final isCurrentlyActive = ref.read(isMultiSelectModeProvider);
    if (isCurrentlyActive) {
      clearMultiSelectMode(ref);
    } else {
      ref.read(isMultiSelectModeProvider.notifier).state = true;
      ref.read(selectedOrdersProvider.notifier).state = <String>{};
    }
  }
}