package com.example.ictis_schedule;

import android.appwidget.AppWidgetManager;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "widget_service";
    private static final String PREFS_NAME = "widget_prefs";
    private static final String GROUP_NAME_KEY = "group_name";

    @Override
    public void configureFlutterEngine(FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
            .setMethodCallHandler((call, result) -> {
                if (call.method.equals("updateWidgetGroup")) {
                    String groupName = call.argument("groupName");
                    updateWidgetGroup(groupName);
                    result.success(null);
                } else {
                    result.notImplemented();
                }
            });
    }

    private void updateWidgetGroup(String groupName) {
        // Сохраняем имя группы в SharedPreferences
        SharedPreferences prefs = getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
        prefs.edit().putString(GROUP_NAME_KEY, groupName).apply();

        // Обновляем виджет
        AppWidgetManager appWidgetManager = AppWidgetManager.getInstance(this);
        ComponentName thisAppWidget = new ComponentName(this, HelloWidgetProvider.class);
        int[] appWidgetIds = appWidgetManager.getAppWidgetIds(thisAppWidget);
        
        if (appWidgetIds.length > 0) {
            Intent intent = new Intent(this, HelloWidgetProvider.class);
            intent.setAction("com.example.ictis_schedule.MANUAL_UPDATE_SCHEDULE");
            intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, appWidgetIds);
            sendBroadcast(intent);
        }
    }

    public static String getGroupName(Context context) {
        SharedPreferences prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE);
        return prefs.getString(GROUP_NAME_KEY, "КТбо2-8"); // значение по умолчанию
    }
}
