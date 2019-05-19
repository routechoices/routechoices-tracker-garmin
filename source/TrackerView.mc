using Toybox.Application;
using Toybox.Graphics;
using Toybox.Math;
using Toybox.Time;
using Toybox.WatchUi;


class TrackerView extends WatchUi.View {
    var model = null;

    function initialize(mdl) {
        View.initialize();
        model = mdl
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
        var topText = "";
        var bottomText = "";

        // Set background color
        if( model.isConnected == true ) {
            dc.setColor( Graphics.COLOR_TRANSPARENT, Graphics.COLOR_GREEN );
        } else {
            dc.setColor( Graphics.COLOR_TRANSPARENT, Graphics.COLOR_RED );
        }
        dc.clear();
        dc.setColor( Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT );
        if (model.deviceId == null) {
            topText = "No Device ID";
        } else {
            topText = model.deviceId
        }
        if(model.activityStartTime) {
            bottomText = getTimeString(Time.now().value() - model.activityStartTime);
        }
        var sizeText = getTextDimensions(topText, Graphics.FONT_LARGE);
        dc.drawText( (dc.getWidth() / 2), (dc.getHeight() / 3) - (sizeText[1] / 2), Graphics.FONT_LARGE, , Graphics.TEXT_JUSTIFY_CENTER );
        dc.drawText( (dc.getWidth() / 2), (2 * dc.getHeight() / 3) - (sizeText[1] / 2), Graphics.FONT_LARGE, bottomText, Graphics.TEXT_JUSTIFY_CENTER );
    }

    function getTimeString(t) {
        var time =  - t;
        var s = "";
        s += Math.floor(time / 3600).toString() + ":";
        s += Math.floor((time % 3600) / 60).toString() + ":";
        s += Math.floor(time % 60).toString();
        return s;
    }
}
