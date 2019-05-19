using Toybox.Communications;
using Toybox.Position;
using Toybox.System;
using Toybox.Time;


var SERVER_URL = "https://www.routechoices.com";


class TrackerModel{
    var deviceId = null;
    var isRequestingDeviceId = false;
    var activityStartTime = null;
    var lastPosition = null;
    var isConnected = false;
    var session = ActivityRecording.createSession({
        :name=>"Live Tracking",
        :sport=>ActivityRecording.SPORT_RUNNING,
        :subSport=>ActivityRecording.SUB_SPORT_TRAIL
    });

    function initialize(settings){
        Position.enableLocationEvents(
            Position.LOCATION_CONTINUOUS,
            method(:onPosition)
        );
        deviceId = Application.getApp().getProperty("deviceId");
        if (deviceId == null || deviceId == "") {
            requestDeviceId();
        }
    }

    function requestDeviceId() {
        if(isRequestingDeviceId) {
            return ;
        }
        isRequestingDeviceId = true;
        var url = SERVER_URL + "/api/device_id/";
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
        isRequestingDeviceId = false;
        if (code == 200) {
            System.println("Device ID Request Successful.");
            setDeviceId(data["device_id"]);
        } else {
            System.println("Device ID Request Failed " + code.toString());
            requestDeviceId();
        }
    }

    function setDeviceId(id) {
        deviceId = id;
        Application.getApp().setProperty("deviceId", id);
        mainView.setDeviceId(id);
    }

    function startActivity() {
        session.start();
        activityStartTime = Time.now().value()
        Ui.requestUpdate();
    }

    function stopActivity() {
        if (session.isRecording()) {
            session.stop();
            session.save();
            session = null;
        }
        Position.enableLocationEvents(
            Position.LOCATION_DISABLE,
            method(:onPosition)
        );
    }

    function onPosition(info) {
        lastPosition = info;
        if(deviceId != null && deviceId != "") {
            sendPosition(info);
        }
        Ui.requestUpdate();
    }

    function sendPosition(positionInfo) {
        if (positionInfo != null) {
            var timestamp = Time.now().value();
            System.println("Sending Position " + timestamp.toString());
            var url = SERVER_URL + "/api/traccar/?id=" + deviceId +
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
            isConnected = true;
        } else {
            isConnected = false;
        }
        Ui.requestUpdate();
    }
}