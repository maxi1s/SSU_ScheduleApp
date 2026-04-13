package com.ssu.ssu_schedule

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

class SimpleWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences
    ) {
        for (appWidgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.simple_widget).apply {
                val title = widgetData.getString("widget_title", "Расписание")
                val content = widgetData.getString("widget_content", "Загрузка...")
                
                setTextViewText(R.id.widget_title, title)
                setTextViewText(R.id.widget_content, content)
            }
            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
