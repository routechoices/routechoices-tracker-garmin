using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Communications;
using Toybox.Lang;

class RoutechoicesTrackerView extends WatchUi.View {

    var posnInfo = null;
    var deviceId = "";

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
        if( posnInfo != null ) {
            dc.setColor( Graphics.COLOR_TRANSPARENT, Graphics.COLOR_BLACK );
        } else {
            dc.setColor( Graphics.COLOR_TRANSPARENT, Graphics.COLOR_RED );
        }
        dc.clear();
        dc.setColor( Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT );
        dc.drawText( (dc.getWidth() / 2), (dc.getHeight() / 2), Graphics.FONT_SMALL, deviceId, Graphics.TEXT_JUSTIFY_CENTER );
    }

    function setPosition(info) {
        posnInfo = info;
        sendPosition();
        WatchUi.requestUpdate();
    }

    function setDeviceId(devId) {
        deviceId = devId;
    }

    function sendPosition() {
        if( posnInfo != null ) {
            var url = "https://www.routechoices.com/api/traccar/";
            var data = {
                "id" => deviceId,
                "lat" => posnInfo.position.toDegrees()[0].toString(),
                "lon" => posnInfo.position.toDegrees()[0].toString(),
                "timestamp" => posnInfo.when.value
            };
            var options = {
                :method => Communications.HTTP_REQUEST_METHOD_POST,
                :headers => {
                    "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED
                },
                :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_URL_ENCODED
            };
            var responseCallback = method(:onDataSent);
            Communications.makeWebRequest(url, data, options, responseCallback);
        }
    }

    function onDataSent(code, data) {
        // Do something
    }
}
