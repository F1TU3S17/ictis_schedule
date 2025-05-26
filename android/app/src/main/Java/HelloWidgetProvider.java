package com.example.ictis_schedule;

import android.app.AlarmManager;
import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.ComponentName;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Handler;
import android.os.Looper;
import android.util.Log;
import android.widget.RemoteViews;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Locale;
import java.util.TimeZone;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class HelloWidgetProvider extends AppWidgetProvider {    private static final String TAG = "HelloWidgetProvider";
    private static final String ACTION_UPDATE_SCHEDULE = "com.example.ictis_schedule.ACTION_UPDATE_SCHEDULE";
    private static final String ACTION_MANUAL_UPDATE_SCHEDULE = "com.example.ictis_schedule.MANUAL_UPDATE_SCHEDULE";
    private static final String API_BASE_URL = "https://shedule.rdcenter.ru/schedule-api/?query=";

    private static final ExecutorService executorService = Executors.newSingleThreadExecutor();
    private static final Handler mainThreadHandler = new Handler(Looper.getMainLooper());

    // Request codes for PendingIntents
    private static final int REQUEST_CODE_DAILY_MIDNIGHT_UPDATE = 0;
    private static final int REQUEST_CODE_LESSON_ALARM_BASE = 100; // For lessons 0-6 -> 100-106

    static class Lesson {
        String time;
        String name;
        boolean isCurrent;

        Lesson(String time, String name) {
            this.time = time;
            this.name = name;
            this.isCurrent = false; // Initialize as not current
        }
    }

    // @Override
    // public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
    //     Log.d(TAG, "onUpdate called for " + appWidgetIds.length + " widgets.");
    //     for (int appWidgetId : appWidgetIds) {
    //         updateAppWidget(context, appWidgetManager, appWidgetId, false); // false для isManualUpdate
    //     }
    //     // Schedule next update only if there are active widgets.
    //     // onEnabled also calls onUpdate, which will schedule.
    //     // If all widgets are removed and one is re-added, onUpdate is called.
    //     if (appWidgetIds.length > 0) {
    //         scheduleDailyMidnightUpdate(context); // Changed from scheduleNextUpdate
    //     }
    // }    @Override
    public void onReceive(Context context, Intent intent) {
        super.onReceive(context, intent);
        String action = intent.getAction();
        SimpleDateFormat logTimeFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault());
        Log.d(TAG, "*** onReceive вызван с действием: " + action + ", Время: " + logTimeFormat.format(new Date()) + " ***");
        
        AppWidgetManager appWidgetManager = AppWidgetManager.getInstance(context);
        ComponentName thisAppWidget = new ComponentName(context.getPackageName(), HelloWidgetProvider.class.getName());
        int[] appWidgetIds = appWidgetManager.getAppWidgetIds(thisAppWidget);

        if (ACTION_UPDATE_SCHEDULE.equals(action) || ACTION_MANUAL_UPDATE_SCHEDULE.equals(action)) {
            boolean isManual = ACTION_MANUAL_UPDATE_SCHEDULE.equals(action);
            if (isManual) {
                Log.d(TAG, "Manual update triggered for all widgets.");
            } else {
                Log.d(TAG, "Scheduled update triggered for all widgets.");
            }
            if (appWidgetIds != null && appWidgetIds.length > 0) {
                for (int appWidgetId : appWidgetIds) {
                    updateAppWidget(context, appWidgetManager, appWidgetId, isManual);
                }
            } else {
                Log.d(TAG, "No active widgets to update for action: " + action);
            }
        } else if (Intent.ACTION_BOOT_COMPLETED.equals(action)) {
            Log.d(TAG, "Boot completed. Triggering update for all widgets.");
            if (appWidgetIds != null && appWidgetIds.length > 0) {
                for (int appWidgetId : appWidgetIds) {
                    updateAppWidget(context, appWidgetManager, appWidgetId, false);
                }
            } else {
                Log.d(TAG, "No active widgets found after boot.");
            }
        } else if (AppWidgetManager.ACTION_APPWIDGET_DELETED.equals(action)) {
            // Handled by onDisabled if it's the last widget
            Log.d(TAG, "Widget deleted.");
        }
    }
    
    private void cancelLessonSpecificAlarms(Context context) {
        AlarmManager alarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
        if (alarmManager == null) {
            Log.e(TAG, "AlarmManager not available for cancelling lesson alarms.");
            return;
        }
        Log.d(TAG, "Cancelling all current day lesson-specific alarms.");
        for (int i = 0; i < 7; i++) { // Assuming max 7 lessons
            Intent intent = new Intent(context, HelloWidgetProvider.class);
            intent.setAction(ACTION_UPDATE_SCHEDULE);
            PendingIntent pendingIntent = PendingIntent.getBroadcast(context,
                    REQUEST_CODE_LESSON_ALARM_BASE + i,
                    intent,
                    PendingIntent.FLAG_NO_CREATE | PendingIntent.FLAG_IMMUTABLE);
            if (pendingIntent != null) {
                alarmManager.cancel(pendingIntent);
                pendingIntent.cancel();
                // Log.d(TAG, "Cancelled lesson alarm with request code: " + (REQUEST_CODE_LESSON_ALARM_BASE + i));
            }
        }
    }

    // Эта версия onUpdate должна быть единственной.
    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        Log.d(TAG, "onUpdate called for " + appWidgetIds.length + " widgets.");
        for (int appWidgetId : appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId, false); 
        }
        // Scheduling is now handled within updateAppWidget after data fetch
    }

    // Метод для получения динамического API URL
    private String getApiUrl(Context context) {
        String groupName = MainActivity.getGroupName(context);
        return API_BASE_URL + groupName;
    }

    // Добавляем параметр isManualUpdate
    private void updateAppWidget(Context context, AppWidgetManager appWidgetManager, int appWidgetId, boolean isManualUpdate) {
        Log.d(TAG, "Attempting to update widget ID: " + appWidgetId + (isManualUpdate ? " (Manual Update)" : " (Scheduled/Initial Update)"));
        RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.hello_widget);

        // Настройка PendingIntent для клика по всему виджету
        Intent clickIntent = new Intent(context, HelloWidgetProvider.class);
        clickIntent.setAction(ACTION_MANUAL_UPDATE_SCHEDULE); 
        PendingIntent clickPendingIntent = PendingIntent.getBroadcast(context, appWidgetId, clickIntent, PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE);
        views.setOnClickPendingIntent(R.id.widget_container, clickPendingIntent); 

        SimpleDateFormat dateFormat = new SimpleDateFormat("EEE, dd MMM yyyy", new Locale("ru"));
        String currentDateStr = dateFormat.format(new Date());
        views.setTextViewText(R.id.tv_current_date, currentDateStr);
        Log.d(TAG, "Set current date: " + currentDateStr);

        for (int i = 1; i <= 7; i++) {
            int timeId = context.getResources().getIdentifier("tv_lesson" + i + "_time", "id", context.getPackageName());
            int nameId = context.getResources().getIdentifier("tv_lesson" + i + "_name", "id", context.getPackageName());
            if (timeId != 0) views.setTextViewText(timeId, ""); 
            if (nameId != 0) views.setTextViewText(nameId, (i == 1) ? "Загрузка..." : ""); 
        }
        appWidgetManager.updateAppWidget(appWidgetId, views);        executorService.execute(() -> {
            try {
                String jsonResponse = fetchScheduleData(context);
                if (jsonResponse != null) {
                    Log.d(TAG, "Successfully fetched data." + (isManualUpdate ? " (Manual)" : ""));
                    String currentDayKey = getCurrentDayKeyForAPI();
                    List<Lesson> lessons = parseSchedule(jsonResponse, currentDayKey);
                    markCurrentLesson(lessons); 

                    mainThreadHandler.post(() -> {
                        RemoteViews updatedViews = new RemoteViews(context.getPackageName(), R.layout.hello_widget);
                        updatedViews.setOnClickPendingIntent(R.id.widget_container, clickPendingIntent);
                        updatedViews.setTextViewText(R.id.tv_current_date, currentDateStr);

                        if (lessons.isEmpty()) {
                            Log.d(TAG, "No lessons found for " + currentDayKey);
                            updatedViews.setTextViewText(R.id.tv_lesson1_name, "Нет занятий на сегодня");
                            for (int i = 1; i <= 7; i++) { 
                                int timeId = context.getResources().getIdentifier("tv_lesson" + i + "_time", "id", context.getPackageName());
                                int nameId = context.getResources().getIdentifier("tv_lesson" + i + "_name", "id", context.getPackageName());
                                int lessonLayoutId = context.getResources().getIdentifier("ll_lesson" + i, "id", context.getPackageName());

                                if (timeId != 0) updatedViews.setTextViewText(timeId, "");
                                if (nameId != 0 && i > 1) updatedViews.setTextViewText(nameId, "");
                                if (lessonLayoutId != 0) {
                                    updatedViews.setInt(lessonLayoutId, "setBackgroundResource", R.drawable.rounded_corner_border);
                                }
                                if (timeId != 0) updatedViews.setTextColor(timeId, context.getColor(R.color.default_text_color));
                                if (nameId != 0) updatedViews.setTextColor(nameId, context.getColor(R.color.default_text_color));
                            }
                        } else {
                            Log.d(TAG, "Lessons found for " + currentDayKey + ": " + lessons.size());
                            for (int i = 0; i < 7; i++) { 
                                int timeId = context.getResources().getIdentifier("tv_lesson" + (i + 1) + "_time", "id", context.getPackageName());
                                int nameId = context.getResources().getIdentifier("tv_lesson" + (i + 1) + "_name", "id", context.getPackageName());
                                int lessonLayoutId = context.getResources().getIdentifier("ll_lesson" + (i + 1), "id", context.getPackageName());

                                if (i < lessons.size()) {
                                    Lesson lesson = lessons.get(i);
                                    if (timeId != 0) updatedViews.setTextViewText(timeId, lesson.time);
                                    if (nameId != 0) updatedViews.setTextViewText(nameId, lesson.name.isEmpty() ? "---" : lesson.name);
                                    Log.d(TAG, "Displaying lesson " + (i+1) + ": " + lesson.time + " - " + lesson.name + " (Current: " + lesson.isCurrent + ")");

                                    if (lessonLayoutId != 0) {
                                        if (lesson.isCurrent) {
                                            updatedViews.setInt(lessonLayoutId, "setBackgroundResource", R.drawable.rounded_corner_border_green);
                                            if (timeId != 0) updatedViews.setTextColor(timeId, context.getColor(R.color.green_text_color));
                                            if (nameId != 0) updatedViews.setTextColor(nameId, context.getColor(R.color.green_text_color));
                                        } else {
                                            updatedViews.setInt(lessonLayoutId, "setBackgroundResource", R.drawable.rounded_corner_border);
                                            if (timeId != 0) updatedViews.setTextColor(timeId, context.getColor(R.color.default_text_color));
                                            if (nameId != 0) updatedViews.setTextColor(nameId, context.getColor(R.color.default_text_color));
                                        }
                                    }
                                } else {
                                    if (timeId != 0) updatedViews.setTextViewText(timeId, "");
                                    if (nameId != 0) updatedViews.setTextViewText(nameId, "");
                                    if (lessonLayoutId != 0) {
                                        updatedViews.setInt(lessonLayoutId, "setBackgroundResource", R.drawable.rounded_corner_border);
                                    }
                                    if (timeId != 0) updatedViews.setTextColor(timeId, context.getColor(R.color.default_text_color));
                                    if (nameId != 0) updatedViews.setTextColor(nameId, context.getColor(R.color.default_text_color));
                                }
                            }
                        }
                        appWidgetManager.updateAppWidget(appWidgetId, updatedViews);
                        Log.d(TAG, "Widget " + appWidgetId + " updated with schedule for " + currentDayKey + (isManualUpdate ? " (Manual)" : ""));                        // SCHEDULING LOGIC MOVED HERE
                        // Use getApplicationContext() for alarms
                        cancelLessonSpecificAlarms(context.getApplicationContext()); // Cancel old lesson alarms for the day
                        scheduleLessonSpecificAlarms(context.getApplicationContext(), lessons); // Schedule new ones for today's future lessons
                        scheduleDailyMidnightUpdate(context.getApplicationContext()); // Ensure midnight update for next day is set
                    });
                } else {
                    Log.e(TAG, "Failed to fetch schedule data or data was null." + (isManualUpdate ? " (Manual)" : ""));
                    mainThreadHandler.post(() -> {
                        RemoteViews errorViews = new RemoteViews(context.getPackageName(), R.layout.hello_widget);
                        errorViews.setOnClickPendingIntent(R.id.widget_container, clickPendingIntent);
                        errorViews.setTextViewText(R.id.tv_current_date, currentDateStr); 
                        errorViews.setTextViewText(R.id.tv_lesson1_name, "Ошибка загрузки");
                         for (int i = 1; i <= 7; i++) { 
                            int timeId = context.getResources().getIdentifier("tv_lesson" + i + "_time", "id", context.getPackageName());
                             if (timeId != 0) errorViews.setTextViewText(timeId, "");
                             if (i > 1) {
                                 int nameId = context.getResources().getIdentifier("tv_lesson" + i + "_name", "id", context.getPackageName());
                                 if (nameId != 0) errorViews.setTextViewText(nameId, "");
                             }
                        }
                        appWidgetManager.updateAppWidget(appWidgetId, errorViews);
                        // Even on error, ensure the daily update is scheduled to try again
                        scheduleDailyMidnightUpdate(context.getApplicationContext()); // Use application context
                    });
                }
            } catch (Exception e) {
                Log.e(TAG, "Error in updateAppWidget background task" + (isManualUpdate ? " (Manual)" : ""), e);
                mainThreadHandler.post(() -> {
                     RemoteViews errorViews = new RemoteViews(context.getPackageName(), R.layout.hello_widget);
                     errorViews.setOnClickPendingIntent(R.id.widget_container, clickPendingIntent);
                     errorViews.setTextViewText(R.id.tv_current_date, currentDateStr); 
                     String errorMessage = "Ошибка: ";
                     if (e.getMessage() != null) {
                        errorMessage += e.getMessage().substring(0, Math.min(e.getMessage().length(), 30));
                     } else {
                        errorMessage += "Неизвестная ошибка";
                     }
                     errorViews.setTextViewText(R.id.tv_lesson1_name, errorMessage);
                     for (int i = 1; i <= 7; i++) { 
                        int timeId = context.getResources().getIdentifier("tv_lesson" + i + "_time", "id", context.getPackageName());
                         if (timeId != 0) errorViews.setTextViewText(timeId, "");
                         if (i > 1) {
                             int nameId = context.getResources().getIdentifier("tv_lesson" + i + "_name", "id", context.getPackageName());
                             if (nameId != 0) errorViews.setTextViewText(nameId, "");
                         }
                    }
                     appWidgetManager.updateAppWidget(appWidgetId, errorViews);
                    // Even on error, ensure the daily update is scheduled to try again
                    scheduleDailyMidnightUpdate(context.getApplicationContext()); // Use application context
                });
            }
        });
    }    private String fetchScheduleData(Context context) throws IOException {
        String apiUrl = getApiUrl(context);
        Log.d(TAG, "Fetching schedule data from: " + apiUrl);
        URL url = new URL(apiUrl);
        HttpURLConnection connection = (HttpURLConnection) url.openConnection();
        connection.setRequestMethod("GET");
        connection.setConnectTimeout(10000); // 10 seconds
        connection.setReadTimeout(15000);    // 15 seconds

        try (InputStream inputStream = connection.getInputStream();
             BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream))) {
            StringBuilder stringBuilder = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                stringBuilder.append(line);
            }
            // Log only a part of the response if it's too long to avoid spamming Logcat
            String responseStr = stringBuilder.toString();
            Log.d(TAG, "Raw JSON response (first 1000 chars): " + responseStr.substring(0, Math.min(responseStr.length(), 1000)));
            return responseStr;
        } finally {
            connection.disconnect();
        }
    }

    // Generates the day key string (e.g., "Пнд,19  мая") based on the current date in Moscow Time Zone
    private String getCurrentDayKeyForAPI() {
        // Use Moscow TimeZone to generate the key, as per requirement "00:00 Moscow time" for updates
        // and the API data seems to be based on Russian locale.
        Calendar calendar = Calendar.getInstance(TimeZone.getTimeZone("Europe/Moscow"));
        
        // These arrays map Calendar constants (which are 1-indexed for DAY_OF_WEEK, 0-indexed for MONTH)
        // to the specific Russian abbreviations seen in the API ("Пнд", "мая")
        // Calendar.SUNDAY = 1, MONDAY = 2, ..., SATURDAY = 7
        String[] daysOfWeekRU = {"Вск", "Пнд", "Втр", "Срд", "Чтв", "Птн", "Сбт"}; // Sunday is index 0 for this array
        // Calendar.JANUARY = 0, FEBRUARY = 1, ..., DECEMBER = 11
        String[] monthsRU = {"янв", "фев", "мар", "апр", "мая", "июн", "июл", "авг", "сен", "окт", "ноя", "дек"};

        int dayOfWeekCal = calendar.get(Calendar.DAY_OF_WEEK); // 1-7 (Sunday to Saturday)
        String dayName = daysOfWeekRU[dayOfWeekCal - 1];       // Adjust to 0-indexed array

        int dayOfMonth = calendar.get(Calendar.DAY_OF_MONTH);

        int monthCal = calendar.get(Calendar.MONTH);           // 0-11 (January to December)
        String monthName = monthsRU[monthCal];

        // API format example: "Пнд,19  мая" (DayOfWeek,DayOfMonth  Month with two spaces)
        // String.format with Locale.US ensures numbers are formatted plainly without locale-specific chars.
        String formattedKey = String.format(Locale.US, "%s,%d  %s", dayName, dayOfMonth, monthName);
        Log.d(TAG, "Generated key for API comparison: \'" + formattedKey + "\' (using Moscow Time)");
        return formattedKey;
    }

    private List<Lesson> parseSchedule(String jsonResponse, String targetDayKey) {
        List<Lesson> dailySchedule = new ArrayList<>();
        Log.d(TAG, "Parsing schedule. Target day key: '" + targetDayKey + "'");
        try {
            JSONObject responseObject = new JSONObject(jsonResponse);
            JSONObject tableObject = responseObject.getJSONObject("table");
            JSONArray scheduleTable = tableObject.getJSONArray("table");

            // Basic validation of table structure
            if (scheduleTable.length() < 2) { // Need at least header and times row
                Log.e(TAG, "Schedule table is too short to parse. Length: " + scheduleTable.length());
                return dailySchedule;
            }

            JSONArray timesArray = scheduleTable.getJSONArray(1); // Times are in the second array (index 1)
                                                                  // e.g., ["Время", "9:00-10:30", "10:40-12:10", ...]

            // Daily schedules start from the third array (index 2)
            for (int i = 2; i < scheduleTable.length(); i++) {
                JSONArray dayScheduleArray = scheduleTable.getJSONArray(i);
                if (dayScheduleArray.length() > 0) {
                    // The first element is the day string, e.g., "Пнд,19  мая"
                    String dayStringFromJson = dayScheduleArray.getString(0).trim(); 
                      // Robust comparison: normalize both strings by removing all spaces and converting to lowercase (Russian locale)
                    // This handles potential inconsistencies like "Пнд,19  мая" vs "Пнд,19 мая"
                    String normalizedApiDay = dayStringFromJson.replaceAll("\\s+", "").toLowerCase(new Locale("ru"));
                    String normalizedTargetDay = targetDayKey.replaceAll("\\s+", "").toLowerCase(new Locale("ru"));
                    
                    Log.d(TAG, "Comparing API day (raw): '" + dayStringFromJson + "' (normalized: '" + normalizedApiDay + "') with target (normalized: '" + normalizedTargetDay + "')");

                    if (normalizedApiDay.equals(normalizedTargetDay)) {
                        Log.i(TAG, "Match found for day: " + dayStringFromJson);
                        // Iterate through lessons for this day, starting from index 1 (after day string)
                        // And also ensure we don't go beyond the number of time slots available
                        for (int j = 1; j < dayScheduleArray.length() && j < timesArray.length(); j++) {
                            if (dailySchedule.size() >= 7) { // Max 7 lessons
                                Log.d(TAG, "Reached max 7 lessons for the day.");
                                break; 
                            }

                            String time = timesArray.optString(j, "").trim(); // Get time from timesArray
                            String name = dayScheduleArray.optString(j, "").trim(); // Get lesson name
                            
                            // Only add if time is not empty, otherwise it's likely not a valid lesson slot
                            if (!time.isEmpty()) {
                                
                                dailySchedule.add(new Lesson(time, name));
                                Log.d(TAG, "Added lesson: " + time + " - " + (name.isEmpty() ? "---" : name));
                            } else {
                                Log.d(TAG, "Skipping lesson slot " + j + " due to empty time.");
                            }
                        }
                        Log.d(TAG, "Parsed " + dailySchedule.size() + " lessons for the day: " + dayStringFromJson);
                        return dailySchedule; // Found and parsed schedule for the target day
                    }
                }
            }
            Log.w(TAG, "No schedule found for targetDayKey: '" + targetDayKey + "' after checking all entries.");
        } catch (JSONException e) {
            Log.e(TAG, "Error parsing JSON schedule", e);
            // Optionally, could inform the user via the widget itself if parsing fails critically
        }
        return dailySchedule; // Return empty list if no match found or error occurred
    }

    private void markCurrentLesson(List<Lesson> lessons) {
        if (lessons == null || lessons.isEmpty()) return;

        Calendar now = Calendar.getInstance(TimeZone.getTimeZone("Europe/Moscow"));
        int currentHour = now.get(Calendar.HOUR_OF_DAY);
        int currentMinute = now.get(Calendar.MINUTE);
        long currentTimeInMinutes = currentHour * 60 + currentMinute;

        Lesson lastEndedLesson = null;
        long lastEndedLessonEndTime = -1;

        for (Lesson lesson : lessons) {
            if (lesson.time == null || !lesson.time.matches("\\d{1,2}:\\d{2}-\\d{1,2}:\\d{2}")) {
                lesson.isCurrent = false;
                continue;
            }

            String[] times = lesson.time.split("-");
            String[] startTimeParts = times[0].split(":");
            String[] endTimeParts = times[1].split(":");

            try {
                int startHour = Integer.parseInt(startTimeParts[0]);
                int startMinute = Integer.parseInt(startTimeParts[1]);
                int endHour = Integer.parseInt(endTimeParts[0]);
                int endMinute = Integer.parseInt(endTimeParts[1]);

                long lessonStartTimeInMinutes = startHour * 60 + startMinute;
                long lessonEndTimeInMinutes = endHour * 60 + endMinute;

                if (currentTimeInMinutes >= lessonStartTimeInMinutes && currentTimeInMinutes < lessonEndTimeInMinutes) {
                    // Current time is within this lesson's interval
                    for (Lesson l : lessons) l.isCurrent = false; // Reset others
                    lesson.isCurrent = true;
                    return; // Found the currently active lesson
                }

                if (currentTimeInMinutes >= lessonEndTimeInMinutes) {
                    // This lesson has ended
                    if (lessonEndTimeInMinutes > lastEndedLessonEndTime) {
                        lastEndedLesson = lesson;
                        lastEndedLessonEndTime = lessonEndTimeInMinutes;
                    }
                }
                lesson.isCurrent = false; // Default to not current

            } catch (NumberFormatException e) {
                Log.e(TAG, "Error parsing lesson time: " + lesson.time, e);
                lesson.isCurrent = false;
            }
        }

        // If no lesson is currently active, mark the last ended lesson as "current" for highlighting
        // until the next lesson starts or the day ends.
        if (lastEndedLesson != null) {
            boolean anActiveLessonWasFound = false;
            for (Lesson l : lessons) {
                if (l.isCurrent) {
                    anActiveLessonWasFound = true;
                    break;
                }
            }
            if (!anActiveLessonWasFound) {
                 // Check if there's a future lesson today. If so, don't highlight last ended.
                boolean futureLessonExists = false;
                for (Lesson lesson : lessons) {
                    if (lesson.time == null || !lesson.time.matches("\\d{1,2}:\\d{2}-\\d{1,2}:\\d{2}")) continue;
                    String[] times = lesson.time.split("-");
                    String[] startTimeParts = times[0].split(":");
                     try {
                        int startHour = Integer.parseInt(startTimeParts[0]);
                        int startMinute = Integer.parseInt(startTimeParts[1]);
                        long lessonStartTimeInMinutes = startHour * 60 + startMinute;
                        if (lessonStartTimeInMinutes > currentTimeInMinutes) {
                            futureLessonExists = true;
                            break;
                        }
                    } catch (NumberFormatException e) { /* ignore */ }
                }

                if (!futureLessonExists) {
                    lastEndedLesson.isCurrent = true;
                }
            }
        }
    }

    @Override
    public void onEnabled(Context context) {
        super.onEnabled(context);
        Log.i(TAG, "onEnabled: First widget instance placed. Initializing schedule and alarms.");
        AppWidgetManager appWidgetManager = AppWidgetManager.getInstance(context);
        ComponentName thisAppWidget = new ComponentName(context.getPackageName(), HelloWidgetProvider.class.getName());
        int[] appWidgetIds = appWidgetManager.getAppWidgetIds(thisAppWidget);        if (appWidgetIds != null && appWidgetIds.length > 0) {
            Log.d(TAG, "onEnabled: Triggering update for " + appWidgetIds.length + " widget(s).");
            for (int appWidgetId : appWidgetIds) {
                updateAppWidget(context.getApplicationContext(), appWidgetManager, appWidgetId, false);
            }
        } else {
            Log.w(TAG, "onEnabled: No appWidgetIds found, attempting to schedule only daily midnight update.");
            scheduleDailyMidnightUpdate(context.getApplicationContext());
        }
        
        // ВРЕМЕННАЯ ДИАГНОСТИКА: добавляем тестовый полуночный будильник на 5 минут
        Log.i(TAG, "ДИАГНОСТИКА: Планируем тестовый полуночный будильник на 5 минут для проверки исправлений");
        scheduleTestMidnightAlarm(context.getApplicationContext());
    }

    @Override
    public void onDisabled(Context context) {
        super.onDisabled(context);
        Log.i(TAG, "onDisabled: Last widget instance removed. Cancelling all scheduled alarms.");
        AlarmManager alarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
        if (alarmManager == null) {
            Log.e(TAG, "AlarmManager not available in onDisabled.");
            return;
        }

        Context appContext = context.getApplicationContext();

        // Cancel daily midnight update
        Intent dailyIntent = new Intent(appContext, HelloWidgetProvider.class);
        dailyIntent.setAction(ACTION_UPDATE_SCHEDULE);
        PendingIntent dailyPendingIntent = PendingIntent.getBroadcast(
                appContext,
                REQUEST_CODE_DAILY_MIDNIGHT_UPDATE,
                dailyIntent,
                PendingIntent.FLAG_NO_CREATE | PendingIntent.FLAG_IMMUTABLE
        );
        if (dailyPendingIntent != null) {
            alarmManager.cancel(dailyPendingIntent);
            dailyPendingIntent.cancel();
            Log.d(TAG, "Cancelled daily midnight update alarm (RequestCode: " + REQUEST_CODE_DAILY_MIDNIGHT_UPDATE + ").");
        } else {
            Log.d(TAG, "No pending daily midnight update alarm found to cancel (RequestCode: " + REQUEST_CODE_DAILY_MIDNIGHT_UPDATE + ").");
        }

        cancelLessonSpecificAlarms(appContext);
        
        Log.d(TAG, "All alarms should now be cancelled after onDisabled.");
    }    // Renamed from scheduleNextUpdate - Refined version
    public void scheduleDailyMidnightUpdate(Context context) { // context here should be ApplicationContext
        AlarmManager alarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
        if (alarmManager == null) {
            Log.e(TAG, "AlarmManager not available for daily midnight update.");
            return;
        }
        
        Intent intent = new Intent(context, HelloWidgetProvider.class);
        intent.setAction(ACTION_UPDATE_SCHEDULE); 

        PendingIntent pendingIntent = PendingIntent.getBroadcast(
                context,
                REQUEST_CODE_DAILY_MIDNIGHT_UPDATE, 
                intent, 
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
        );

        // Используем только московское время для всех операций
        Calendar moscowNow = Calendar.getInstance(TimeZone.getTimeZone("Europe/Moscow"));
        Calendar midnightCalendar = Calendar.getInstance(TimeZone.getTimeZone("Europe/Moscow"));
        
        // Установим полночь следующего дня
        midnightCalendar.add(Calendar.DAY_OF_YEAR, 1);
        midnightCalendar.set(Calendar.HOUR_OF_DAY, 0);
        midnightCalendar.set(Calendar.MINUTE, 0);
        midnightCalendar.set(Calendar.SECOND, 0);
        midnightCalendar.set(Calendar.MILLISECOND, 0);

        Log.d(TAG, "ДИАГНОСТИКА ВРЕМЕНИ ПОЛУНОЧНОГО ОБНОВЛЕНИЯ:");
        Log.d(TAG, "Текущее московское время: " + moscowNow.getTime().toString());
        Log.d(TAG, "Планируемое время полуночи: " + midnightCalendar.getTime().toString());
        
        long timeUntilMidnight = (midnightCalendar.getTimeInMillis() - moscowNow.getTimeInMillis()) / 1000 / 60; // в минутах
        Log.d(TAG, "Время до следующей полуночи: " + timeUntilMidnight + " минут");
        
        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                if (alarmManager.canScheduleExactAlarms()) {
                    alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, midnightCalendar.getTimeInMillis(), pendingIntent);
                    Log.i(TAG, "✓ Запланировано точное ежедневное обновление на: " + midnightCalendar.getTime().toString() + " (ReqCode: " + REQUEST_CODE_DAILY_MIDNIGHT_UPDATE + ")");
                } else {
                    alarmManager.set(AlarmManager.RTC_WAKEUP, midnightCalendar.getTimeInMillis(), pendingIntent);
                    Log.w(TAG, "⚠ Нет разрешения на точные будильники. Запланировано неточное обновление. Пользователь должен дать разрешение 'Будильники и напоминания'.");
                }
            } else {
                alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, midnightCalendar.getTimeInMillis(), pendingIntent);
                Log.i(TAG, "✓ Запланировано точное обновление (pre-S) на: " + midnightCalendar.getTime().toString() + " (ReqCode: " + REQUEST_CODE_DAILY_MIDNIGHT_UPDATE + ")");
            }
        } catch (SecurityException se) {
            Log.e(TAG, "SecurityException при планировании ежедневного обновления. Отсутствует SCHEDULE_EXACT_ALARM или USE_EXACT_ALARM?", se);
        }
    }    // Refined version of scheduleLessonSpecificAlarms
    private void scheduleLessonSpecificAlarms(Context context, List<Lesson> lessons) { // context here should be ApplicationContext
        AlarmManager alarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
        if (alarmManager == null) {
            Log.e(TAG, "AlarmManager not available for scheduling lesson alarms.");
            return;
        }
        if (lessons == null || lessons.isEmpty()) {
            Log.d(TAG, "No lessons provided to schedule alarms for.");
            return;
        }        
        
        Log.d(TAG, "Attempting to schedule lesson-specific alarms for " + lessons.size() + " lessons.");
        Calendar moscowNow = Calendar.getInstance(TimeZone.getTimeZone("Europe/Moscow"));
        int scheduledCount = 0;
        
        Log.d(TAG, "ДИАГНОСТИКА ВРЕМЕНИ УРОЧНЫХ БУДИЛЬНИКОВ:");
        Log.d(TAG, "Текущее московское время: " + moscowNow.getTime().toString());
        
        for (int i = 0; i < lessons.size() && i < 7; i++) { // Max 7 lessons
            Lesson lesson = lessons.get(i);
            if (lesson.time == null || !lesson.time.matches("\\d{1,2}:\\d{2}-\\d{1,2}:\\d{2}")) {
                Log.w(TAG, "Invalid time format for lesson: " + lesson.name + " (" + lesson.time + "). Skipping alarm scheduling.");
                continue;
            }

            String[] times = lesson.time.split("-");
            String[] startTimeParts = times[0].split(":");

            try {
                int startHour = Integer.parseInt(startTimeParts[0]);
                int startMinute = Integer.parseInt(startTimeParts[1]);

                // КРИТИЧЕСКИ ВАЖНО: Устанавливаем дату урока правильно!
                Calendar lessonCalendar = Calendar.getInstance(TimeZone.getTimeZone("Europe/Moscow"));
                // Копируем ТЕКУЩУЮ дату и устанавливаем время урока
                lessonCalendar.set(Calendar.YEAR, moscowNow.get(Calendar.YEAR));
                lessonCalendar.set(Calendar.MONTH, moscowNow.get(Calendar.MONTH));
                lessonCalendar.set(Calendar.DAY_OF_MONTH, moscowNow.get(Calendar.DAY_OF_MONTH));
                lessonCalendar.set(Calendar.HOUR_OF_DAY, startHour);
                lessonCalendar.set(Calendar.MINUTE, startMinute);
                lessonCalendar.set(Calendar.SECOND, 0);
                lessonCalendar.set(Calendar.MILLISECOND, 0);

                Log.d(TAG, "Урок " + (i+1) + " '" + lesson.name + "' время: " + lessonCalendar.getTime().toString());
                long minutesUntilLesson = (lessonCalendar.getTimeInMillis() - moscowNow.getTimeInMillis()) / 1000 / 60;
                Log.d(TAG, "Минут до начала урока: " + minutesUntilLesson);

                if (lessonCalendar.getTimeInMillis() > moscowNow.getTimeInMillis()) {
                    Intent intent = new Intent(context, HelloWidgetProvider.class);
                    intent.setAction(ACTION_UPDATE_SCHEDULE);
                    
                    PendingIntent pendingIntent = PendingIntent.getBroadcast(
                            context,
                            REQUEST_CODE_LESSON_ALARM_BASE + i,
                            intent,
                            PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
                    );
                    
                    try {
                        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                            if (alarmManager.canScheduleExactAlarms()) {
                                alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, lessonCalendar.getTimeInMillis(), pendingIntent);
                                Log.i(TAG, "✓ Запланирован точный будильник для урока: " + lesson.name + " на " + lessonCalendar.getTime().toString() + " (ReqCode: " + (REQUEST_CODE_LESSON_ALARM_BASE + i) + ")");
                                scheduledCount++;
                            } else {
                                alarmManager.set(AlarmManager.RTC_WAKEUP, lessonCalendar.getTimeInMillis(), pendingIntent);
                                Log.w(TAG, "⚠ Нет разрешения на точные будильники. Запланирован неточный будильник для урока: " + lesson.name + " на " + lessonCalendar.getTime().toString() + " (ReqCode: " + (REQUEST_CODE_LESSON_ALARM_BASE + i) + ")");
                                scheduledCount++;
                            }
                        } else {
                            alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, lessonCalendar.getTimeInMillis(), pendingIntent);
                            Log.i(TAG, "✓ Запланирован точный будильник (pre-S) для урока: " + lesson.name + " на " + lessonCalendar.getTime().toString() + " (ReqCode: " + (REQUEST_CODE_LESSON_ALARM_BASE + i) + ")");
                            scheduledCount++;
                        }
                    } catch (SecurityException se) {
                         Log.e(TAG, "SecurityException при планировании будильника для урока " + lesson.name + ". Отсутствует SCHEDULE_EXACT_ALARM или USE_EXACT_ALARM?", se);
                    }
                } else {
                    Log.d(TAG, "Пропускаем прошедший или текущий урок для планирования будильника: " + lesson.name + " в " + lesson.time + " (прошло " + (-minutesUntilLesson) + " минут назад)");
                }
            } catch (NumberFormatException e) {
                Log.e(TAG, "Ошибка парсинга времени начала урока для планирования будильника: " + lesson.time, e);
            }
        }
        Log.d(TAG, "Завершено планирование будильников для уроков. Всего запланировано: " + scheduledCount);
    }    // ВРЕМЕННЫЙ МЕТОД ДЛЯ ДИАГНОСТИКИ - добавим тестовый будильник на ближайшие 2 минуты
    private void scheduleTestAlarm(Context context) {
        AlarmManager alarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
        if (alarmManager == null) {
            Log.e(TAG, "AlarmManager not available for test alarm.");
            return;
        }
        
        Intent intent = new Intent(context, HelloWidgetProvider.class);
        intent.setAction(ACTION_UPDATE_SCHEDULE);
        
        PendingIntent pendingIntent = PendingIntent.getBroadcast(
                context,
                999, // Тестовый request code
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
        );
        
        Calendar testTime = Calendar.getInstance();
        testTime.add(Calendar.MINUTE, 2); // Через 2 минуты

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                if (alarmManager.canScheduleExactAlarms()) {
                    alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, testTime.getTimeInMillis(), pendingIntent);
                    Log.i(TAG, "ТЕСТ: Запланирован тестовый будильник на " + testTime.getTime().toString());
                } else {
                    Log.w(TAG, "ТЕСТ: Нет разрешения на точные будильники!");
                }
            } else {
                alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, testTime.getTimeInMillis(), pendingIntent);
                Log.i(TAG, "ТЕСТ: Запланирован тестовый будильник (pre-S) на " + testTime.getTime().toString());
            }
        } catch (SecurityException se) {
            Log.e(TAG, "ТЕСТ: SecurityException при планировании тестового будильника", se);
        }
    }

    // НОВЫЙ ТЕСТОВЫЙ МЕТОД для проверки полуночного будильника на ближайшие 5 минут
    private void scheduleTestMidnightAlarm(Context context) {
        AlarmManager alarmManager = (AlarmManager) context.getSystemService(Context.ALARM_SERVICE);
        if (alarmManager == null) {
            Log.e(TAG, "AlarmManager not available for test midnight alarm.");
            return;
        }
        
        Intent intent = new Intent(context, HelloWidgetProvider.class);
        intent.setAction(ACTION_UPDATE_SCHEDULE);
        
        PendingIntent pendingIntent = PendingIntent.getBroadcast(
                context,
                998, // Тестовый request code для полуночного будильника
                intent,
                PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
        );
        
        Calendar testTime = Calendar.getInstance();
        testTime.add(Calendar.MINUTE, 5); // Через 5 минут

        try {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                if (alarmManager.canScheduleExactAlarms()) {
                    alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, testTime.getTimeInMillis(), pendingIntent);
                    Log.i(TAG, "ТЕСТ ПОЛНОЧЬ: Запланирован тестовый полуночный будильник на " + testTime.getTime().toString());
                } else {
                    Log.w(TAG, "ТЕСТ ПОЛНОЧЬ: Нет разрешения на точные будильники!");
                }
            } else {
                alarmManager.setExactAndAllowWhileIdle(AlarmManager.RTC_WAKEUP, testTime.getTimeInMillis(), pendingIntent);
                Log.i(TAG, "ТЕСТ ПОЛНОЧЬ: Запланирован тестовый полуночный будильник (pre-S) на " + testTime.getTime().toString());
            }
        } catch (SecurityException se) {
            Log.e(TAG, "ТЕСТ ПОЛНОЧЬ: SecurityException при планировании тестового полуночного будильника", se);
        }
    }
}
