using Toybox.Application;
using Toybox.Position;
using Toybox.Communication;
using Toybox.System;

class RoutechoicesTrackerApp extends Application.AppBase {

    var mainView;
    var deviceId;
    function initialize() {
        AppBase.initialize();
        try {
            deviceId = Application.Properties.getValue("deviceId");
        catch(ex instanceof InvalidKeyException) {
            requestDeviceId();
        }
    }

    function requestDeviceId () {
        var url = "https://www.routechoices.com/api/device_id/";
        var params = {};

        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_POST,
            :headers => {
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED
            },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_URL_ENCODED
        };
        var responseCallback = method(:onDeviceId);
        Communications.makeWebRequest(url, params, options, responseCallBack);
    }

    function onDeviceId (code, data) {
        if (code == 200) {
            System.println("Device ID Request Successful");
            deviceId = data["id"];
            Application.Properties.setValue("deviceId", mySetting);

        } else {
            System.println("Device ID Request Failed")
            requestDeviceId ()
        }
    }

    //! onStart() is called on application start up
    function onStart(state) {
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
    }

    //! onStop() is called when your application is exiting
    function onStop(state) {
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
    }

    function onPosition(info) {
        mainView.setPosition(info);
    }

    //! Return the initial view of your application here
    function getInitialView() {
        mainView = new RoutechoicesTrackerView();
        mainView.setDeviceId(deviceId);
        return [ positionView ];
    }

}
