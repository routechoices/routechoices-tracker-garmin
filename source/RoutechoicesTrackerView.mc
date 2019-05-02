using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Communications;
using Toybox.Application;
using Toybox.Time;

class RoutechoicesTrackerView extends WatchUi.View {

    var posnInfo = null;
    var deviceId = null;
	var requestingId = false;
    function initialize() {
        View.initialize();
        // deviceId = Application.Storage.getValue("deviceId");
        if (deviceId == null) {
            requestDeviceId();
        }
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
            dc.setColor( Graphics.COLOR_TRANSPARENT, Graphics.COLOR_GREEN );
        } else {
            dc.setColor( Graphics.COLOR_TRANSPARENT, Graphics.COLOR_RED );
        }
        dc.clear();
        dc.setColor( Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT );
        if (deviceId == null) {
            dc.drawText( (dc.getWidth() / 2), (dc.getHeight() / 2), Graphics.FONT_MEDIUM, "No Device ID", Graphics.TEXT_JUSTIFY_CENTER );
            requestDeviceId();
        } else {
	        dc.drawText( (dc.getWidth() / 2), (dc.getHeight() / 2), Graphics.FONT_LARGE, deviceId, Graphics.TEXT_JUSTIFY_CENTER );
        }
    }

    function setPosition(info) {
        posnInfo = info;
        if(deviceId != null) {
            sendPosition();
        }
        WatchUi.requestUpdate();
    }

    function setDeviceId(id) {
        deviceId = id;
        // Application.Storage.setValue("deviceId", id);
        WatchUi.requestUpdate();
    }

    function sendPosition() {
        if( posnInfo != null ) {
            var timestamp = Time.now().value();
            System.println("Sending Position " + timestamp.toString());
            var url = "https://www.routechoices.com/api/traccar/?id=" + deviceId +
                "&lat=" + posnInfo.position.toDegrees()[0].toString() +
                "&lon=" + posnInfo.position.toDegrees()[1].toString() +
                "&timestamp=" + timestamp.toString();
            var data = {};
            var options = {
                :method => Communications.HTTP_REQUEST_METHOD_POST,
                :headers => {
                    "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED
                },
                :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
            };
            var responseCallback = method(:onDataSent);
            Communications.makeWebRequest(url, data, options, responseCallback);
        }
    }

    function onDataSent(code, data) {}

    function requestDeviceId () {
        if(requestingId) {
            return ;
        }
        requestingId = true;
        var url = "https://www.routechoices.com/api/device_id/";
        var params = {};
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_POST,
            :headers => {
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED
            },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };
        var responseCallback = method(:onDeviceId);
        Communications.makeWebRequest(url, params, options, responseCallback);
    }

    function onDeviceId (code, data) {
        requestingId = false;
        if (code == 200) {
            System.println("Device ID Request Successful");
            setDeviceId(data["device_id"]);
        } else {
            System.println("Device ID Request Failed" + code.toString());
        }
    }
}
