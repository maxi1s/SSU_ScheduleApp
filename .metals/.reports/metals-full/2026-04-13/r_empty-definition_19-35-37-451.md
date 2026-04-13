error id: file:///C:/schedule/ssu_schedule-main/android/app/src/main/java/com/ssu/ssu_schedule/ScheduleWidgetProvider.java:R/id#widget_title#
file:///C:/schedule/ssu_schedule-main/android/app/src/main/java/com/ssu/ssu_schedule/ScheduleWidgetProvider.java
empty definition using pc, found symbol in pc: R/id#widget_title#
empty definition using semanticdb
empty definition using fallback
non-local guesses:

offset: 822
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
            
            views.setTextViewText(R.id.@@widget_title, dayTitle);
            views.setTextViewText(R.id.widget_lessons, lessonsList);
            
            appWidgetManager.updateAppWidget(appWidgetId, views);
        }
    }
}

```


#### Short summary: 

empty definition using pc, found symbol in pc: R/id#widget_title#