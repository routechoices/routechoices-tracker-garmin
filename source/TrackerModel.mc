using Toybox.Attention;
using Toybox.Communications;
using Toybox.Position;
using Toybox.Sensor;
using Toybox.System;
using Toybox.Time;
using Toybox.Timer;
using Toybox.WatchUi;


class TrackerModel{
    var SERVER_URL = "https://www.routechoices.com";
    var buffer;
    var heartRate;
    var deviceId = null;
    var isRequestingDeviceId = false;
    var activityStartTime = null;
    var lapStartTime = null;
    var accumulatedTime = 0;
    var accumulatedLapTime = 0;
    var isConnected = false;
    var session = ActivityRecording.createSession({
        :name=>"Live Tracking",
        :sport=>ActivityRecording.SPORT_RUNNING,
        :subSport=>ActivityRecording.SUB_SPORT_TRAIL
    });
    const HAS_TONES = Attention has :playTone;
    const HAS_VIBRATE = Attention has :vibrate;

    hidden var refreshTimer = new Timer.Timer();
    hidden var sendTimer = new Timer.Timer();

    function initialize(){
        buffer = new PositionBuffer();
        Position.enableLocationEvents(
            Position.LOCATION_CONTINUOUS,
            method(:onPosition)
        );
        Sensor.setEnabledSensors([Sensor.SENSOR_HEARTRATE]);
        Sensor.enableSensorEvents(method(:onSensor));
        sendTimer.start(method(:sendBuffer), 10000, true);
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
        if (lapStartTime) {
            lapStartTime = Time.now().value();
        }
        WatchUi.requestUpdate();
        refreshTimer.start(method(:refresh), 100, true);
        startStopBuzz();
    }

    function stopActivity() {
        if (session.isRecording()) {
            accumulatedTime += Time.now().value() - activityStartTime;
            if (lapStartTime) {
                accumulatedLapTime += Time.now().value() - lapStartTime;
            }
            session.stop();
            startStopBuzz();
        }
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
        isConnected = buffer.isConnected;
        WatchUi.requestUpdate();
    }


    function onPosition(info) {
        buffer.addPosition(Time.now().value(), info);
        isConnected = buffer.isConnected;
    }

    function sendBuffer() {
        if (deviceId != null && deviceId != "") {
            buffer.send(deviceId);
        }
        isConnected = buffer.isConnected;
    }

    function onSensor(sensorInfo) {
       heartRate = sensorInfo.heartRate;
    }

    function addLap() {
        if (session.isRecording()){
            session.addLap();
            accumulatedLapTime = 0;
            lapStartTime = Time.now().value();
            startStopBuzz();
        }
    }

    function onQuit(){
        if (accumulatedTime != 0) {
            session.save();
            session = null;
        }
        refreshTimer.stop();
        sendTimer.stop();
        Position.enableLocationEvents(
            Position.LOCATION_DISABLE,
            method(:onPosition)
        );
        Sensor.setEnabledSensors([]);
    }
}
