using Toybox.Attention;
using Toybox.Communications;
using Toybox.Position;
using Toybox.System;
using Toybox.Time;
using Toybox.Timer;
using Toybox.WatchUi;


class TrackerModel{
    var SERVER_URL = "https://www.routechoices.com";
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
    const HAS_TONES = Attention has :playTone;
    const HAS_VIBRATE = Attention has :vibrate;

    hidden var refreshTimer = new Timer.Timer();

    function initialize(){
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
        WatchUi.requestUpdate();
    }

    function startActivity() {
        if(session.isRecording()){
            return;
        }
        session.start();
        activityStartTime = Time.now().value();
        WatchUi.requestUpdate();
        refreshTimer.start(method(:refresh), 100, true);
        startStopBuzz();
    }

    function startStopBuzz(){
		var foo = HAS_TONES && beep(Attention.TONE_LOUD_BEEP);
		var bar = HAS_VIBRATE && vibrate(1500);
    }

    function vibrate(duration){
		var vibrateData = [ new Attention.VibeProfile(  100, duration ) ];
		Attention.vibrate( vibrateData );
		return true;
    }

    function beep(tone){
		Attention.playTone(tone);
		return true;
    }

    function refresh() {
        WatchUi.requestUpdate();
    }

    function stopActivity() {
        refreshTimer.stop();
        if (session.isRecording()) {
            session.stop();
            session.save();
            session = null;
            startStopBuzz();
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
        WatchUi.requestUpdate();
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
        WatchUi.requestUpdate();
    }
}
