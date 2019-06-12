using Toybox.Application;
using Toybox.Graphics;
using Toybox.Lang;
using Toybox.Math;
using Toybox.Time;
using Toybox.WatchUi;


class TrackerView extends WatchUi.View {
    var model = null;

    function initialize(mdl) {
        View.initialize();
        model = mdl;
    }
    //! Load your resources here
    function onLayout(dc) {
    }

    function onHide() {
    }

    //! Restore the state of the app and prepare the view to be shown
    function onShow() {
    }

    //! Update the view
    function onUpdate(dc) {
        var deviceIdText = "";
        var hrText = "--";
        var timeText = "00:00";
        // Set background color
        if( model.isConnected == true ) {
            dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_GREEN);
        } else {
            dc.setColor(Graphics.COLOR_TRANSPARENT, Graphics.COLOR_RED);
        }
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        if (model.deviceId == null) {
            deviceIdText = "No Device ID";
        } else {
            deviceIdText = model.deviceId;
        }
        if (model.heartRate) {
            hrText = model.heartRate.toString();
        }
        if(model.activityStartTime) {
            var prefix = "  ";
            var timeSpent = model.accumulatedTime;
            var lapTime = model.accumulatedLapTime;
            if(model.session.isRecording()) {
                prefix = "• ";
                timeSpent += Time.now().value() - model.activityStartTime;
                if (model.lapStartTime) {
                    lapTime += Time.now().value() - model.lapStartTime;
                }
            }
            timeText = prefix + getTimeString(timeSpent);
            if(model.lapStartTime) {
                timeText += "  " + getTimeString(lapTime);
            }
        }
        var sizeText = dc.getFontHeight(Graphics.FONT_LARGE);
        dc.drawText(
            (dc.getWidth() / 2),
            (dc.getHeight() / 4) - sizeText / 2,
            Graphics.FONT_LARGE,
            deviceIdText,
            Graphics.TEXT_JUSTIFY_CENTER
        );
        dc.drawText((
            dc.getWidth() / 2),
            (dc.getHeight() / 2) - sizeText / 2,
            Graphics.FONT_LARGE,
            timeText,
            Graphics.TEXT_JUSTIFY_CENTER
        );
        dc.drawText((
            dc.getWidth() / 2),
            (3 * dc.getHeight() / 4) - sizeText / 2,
            Graphics.FONT_LARGE,
            hrText,
            Graphics.TEXT_JUSTIFY_CENTER
        );
    }

    function getTimeString(time) {
        var hours = Math.floor(time / 3600);
        var min = Math.floor((time % 3600) / 60);
        var sec = Math.floor(time % 60);
        var s = "";
        if(hours > 0){
            s = Lang.format(
                "$1$:$2$",
                [hours.format("%02d"), min.format("%02d")]
            );
        } else {
            s = Lang.format(
                "$1$:$2$",
                [min.format("%02d"), sec.format("%02d")]
            );
        }
        return s;
    }
}

