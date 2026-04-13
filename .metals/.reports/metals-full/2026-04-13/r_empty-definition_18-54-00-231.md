error id: file:///C:/schedule/ssu_schedule-main/android/app/src/main/java/com/ssu/ssu_schedule/ScheduleWidgetProvider.java:R/id#
file:///C:/schedule/ssu_schedule-main/android/app/src/main/java/com/ssu/ssu_schedule/ScheduleWidgetProvider.java
empty definition using pc, found symbol in pc: R/id#
empty definition using semanticdb
empty definition using fallback
non-local guesses:

offset: 964
uri: file:///C:/schedule/ssu_schedule-main/android/app/src/main/java/com/ssu/ssu_schedule/ScheduleWidgetProvider.java
text:
```scala
package com.ssu.ssu_schedule;

import android.appwidget.AppWidgetManager;
import android.content.Context;
import android.content.SharedPreferences;
import android.widget.RemoteViews;
import es.antonborri.home_widget.HomeWidgetProvider;

public class ScheduleWidgetProvider extends HomeWidgetProvider {
    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds, SharedPreferences widgetData) {
        for (int appWidgetId : appWidgetIds) {
            RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.schedule_widget);
            
            String dayTitle = widgetData.getString("day_title", "Расписание");
            String lessonsList = widgetData.getString("lessons_list", "Нет данных");
            
            // Просто объединяем заголовок и уроки в один TextView для надежности
            String fullText = dayTitle + "\n\n" + lessonsList;
            views.setTextViewText(R.@@id.widget_lessons, fullText);
            
            appWidgetManager.updateAppWidget(appWidgetId, views);
        }
    }
}

```


#### Short summary: 

empty definition using pc, found symbol in pc: R/id#