import 'package:flutter/services.dart';

class WidgetService {
  static const MethodChannel _channel = MethodChannel('widget_service');

  static Future<void> updateWidgetGroup(String groupName) async {
    try {
      await _channel
          .invokeMethod('updateWidgetGroup', {'groupName': groupName});
    } catch (e) {
      print('Error updating widget group: $e');
    }
  }
}
