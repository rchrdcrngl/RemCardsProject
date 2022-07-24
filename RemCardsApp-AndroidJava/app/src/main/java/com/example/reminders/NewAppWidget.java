package com.example.reminders;

import android.app.PendingIntent;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.Intent;
import android.widget.RemoteViews;
import android.widget.Toast;

import io.paperdb.Paper;

/**
 * Implementation of App Widget functionality.
 */
public class NewAppWidget extends AppWidgetProvider {



    static void updateAppWidget(Context context, AppWidgetManager appWidgetManager,
                                int appWidgetId) {

        //Read data

        Paper.init(context);
        int tskcount = Paper.book().read("task_count");
        final String desc;

        if (tskcount == 0){
            desc = "Nice! There are no tasks in the meantime.";
        } else if (tskcount >=1 && tskcount <= 5) {
            desc = "Yes! You can do it!";
        } else if (tskcount > 5 && tskcount <=10) {
            desc = "Let's get it started! You can finish it!";
        } else {
            desc = "Ooh... I think you need to start doing your tasks.";
        }


        // Construct the RemoteViews object
        RemoteViews views = new RemoteViews(context.getPackageName(), R.layout.new_app_widget);
        views.setTextViewText(R.id.task_counter, Integer.toString(tskcount));
        views.setTextViewText(R.id.widget_desc, desc);

        // Update widget
        Intent intentUpdate = new Intent(context, NewAppWidget.class);
        intentUpdate.setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE);
        int[] idArray = new int[]{appWidgetId};
        intentUpdate.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, idArray);

        PendingIntent pendingUpdate = PendingIntent.getBroadcast(context, appWidgetId, intentUpdate, PendingIntent.FLAG_UPDATE_CURRENT);
        views.setOnClickPendingIntent(R.id.task_counter, pendingUpdate);

        //Go To Main
        Intent gotoApp = new Intent(context, SplashScreen.class);
        PendingIntent homepending = PendingIntent.getActivity(context, 0, gotoApp, 0);
        views.setOnClickPendingIntent(R.id.widgetbody, homepending);

        // Instruct the widget manager to update the widget
        appWidgetManager.updateAppWidget(appWidgetId, views);
    }

    @Override
    public void onUpdate(Context context, AppWidgetManager appWidgetManager, int[] appWidgetIds) {
        // There may be multiple widgets active, so update all of them
        for (int appWidgetId : appWidgetIds) {
            updateAppWidget(context, appWidgetManager, appWidgetId);
            Toast.makeText(context, "You are up-to-date!", Toast.LENGTH_SHORT).show();
        }
    }

    @Override
    public void onEnabled(Context context) {
        // Enter relevant functionality for when the first widget is created
    }

    @Override
    public void onDisabled(Context context) {
        // Enter relevant functionality for when the last widget is disabled
    }

    @Override
    public void onReceive(Context context, Intent intent) {
        super.onReceive(context, intent);
    }
}

