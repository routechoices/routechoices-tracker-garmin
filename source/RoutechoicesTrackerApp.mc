using Toybox.Application;
using Toybox.Communications;
using Toybox.Position;
using Toybox.System;
using Toybox.Time;

class RoutechoicesTrackerApp extends Application.AppBase {

    var mainView;
    var deviceId = null;
    var session = null;
    var isRequestingId = false;

    function initialize() {
        AppBase.initialize();
        deviceId = Application.getApp().getProperty("deviceId");
        if (deviceId == null || deviceId == "") {
            requestDeviceId();
        }
    }

    //! onStart() is called on application start up
    function onStart(state) {
        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
        session = ActivityRecording.createSession({
            :name=>"Live Tracking",
            :sport=>ActivityRecording.SPORT_RUNNING,
            :subSport=>ActivityRecording.SUB_SPORT_TRAIL
        });
        session.start();
    }

    //! onStop() is called when your application is exiting
    function onStop(state) {
        Position.enableLocationEvents(Position.LOCATION_DISABLE, method(:onPosition));
        session.stop();
        session.save();
        session = null;
    }

    function onPosition(info) {
        mainView.setPosition(info);
        if(deviceId != null && deviceId != "") {
            sendPosition(info);
        }
    }

    //! Return the initial view of your application here
    function getInitialView() {
        mainView = new RoutechoicesTrackerView();
        if (deviceId != null && deviceId != "") {
            mainView.setDeviceId(deviceId);
        }
        return [ mainView ];
    }

    function sendPosition(positionInfo) {
        if (positionInfo != null) {
            var timestamp = Time.now().value();
            System.println("Sending Position " + timestamp.toString());
            var url = "https://www.routechoices.com/api/traccar/?id=" + deviceId +
                "&lat=" + positionInfo.position.toDegrees()[0].toString() +
                "&lon=" + positionInfo.position.toDegrees()[1].toString() +
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

    function onDataSent(code, data) {
        if(code==200) {
            mainView.setConnectedState(true);
        } else {
            mainView.setConnectedState(false);
        }
    }

    function requestDeviceId() {
        if(isRequestingId) {
            return ;
        }
        isRequestingId = true;
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

    function onDeviceId(code, data) {
        isRequestingId = false;
        if (code == 200) {
            System.println("Device ID Request Successful");
            setDeviceId(data["device_id"]);
        } else {
            System.println("Device ID Request Failed" + code.toString());
            requestDeviceId();
        }
    }

    function setDeviceId(id) {
        deviceId = id;
        Application.getApp().setProperty("deviceId", id);
        mainView.setDeviceId(id);
    }

}
