using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Application;


class RoutechoicesTrackerView extends WatchUi.View {

    var posnInfo = null;
    var deviceId = null;
    var isConnected = false;
    
    function initialize() {
        View.initialize();
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
        var string;

        // Set background color
        if( isConnected == true ) {
            dc.setColor( Graphics.COLOR_TRANSPARENT, Graphics.COLOR_GREEN );
        } else {
            dc.setColor( Graphics.COLOR_TRANSPARENT, Graphics.COLOR_RED );
        }
        dc.clear();
        dc.setColor( Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT );
        if (deviceId == null) {
            dc.drawText( (dc.getWidth() / 2), (dc.getHeight() / 2), Graphics.FONT_MEDIUM, "No Device ID", Graphics.TEXT_JUSTIFY_CENTER );
        } else {
            dc.drawText( (dc.getWidth() / 2), (dc.getHeight() / 2), Graphics.FONT_LARGE, deviceId, Graphics.TEXT_JUSTIFY_CENTER );
        }
    }

    function setPosition(info) {
        posnInfo = info;
        WatchUi.requestUpdate();
    }

    function setDeviceId(id) {
        deviceId = id;
        WatchUi.requestUpdate();
    }
    
    function setConnectedState(c) {
        isConnected = c;
    }
}
