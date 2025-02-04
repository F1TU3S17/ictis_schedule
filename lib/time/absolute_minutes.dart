import 'package:flutter/material.dart';

int absoluteMinutes(TimeOfDay time) {
    return time.hour * 60 + time.minute;
}
