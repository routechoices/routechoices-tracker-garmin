using Toybox.Time;
using Toybox.WatchUi;


class PositionBuffer {
    var SERVER_URL = "https://www.routechoices.com";
    var lastPositionSent = null;
    var lastPositionReceived = null;
    var positionBuffer = {};
    var isSending = false;
    var isConnected = false;

    function addPosition(t, positionInfo) {
        try {
            positionBuffer.put(t.toLong(), positionInfo.position.toDegrees());
        } catch (e) {
        }
    }

    function getSize() {
        return positionBuffer.size();
    }

    function send(deviceId) {
        if(isSending || getSize() == 0) {
            return;
        }
        isSending = true;
        var t = "";
        var lat = "";
        var lon = "";
        var maxT = 0;
        var keys = positionBuffer.keys();
        for (var i = 0; i < keys.size(); i++) {
            if(keys[i] > maxT) {
                maxT = keys[i];
            }
            t += keys[i].toString() + ",";
            lat += positionBuffer.get(keys[i])[0].toString() + ",";
            lon += positionBuffer.get(keys[i])[1].toString() + ",";
        }
        lastPositionSent = maxT;

        var params = {
            "device_id" => deviceId,
            "timestamps" => t,
            "latitudes" => lat,
            "longitudes" => lon,
        };
        var url = SERVER_URL + "/api/garmin/";
        var options = {
            :method => Communications.HTTP_REQUEST_METHOD_POST,
            :headers => {
                "Content-Type" => Communications.REQUEST_CONTENT_TYPE_URL_ENCODED
            },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        };
        var responseCallback = method(:onSent);
        Communications.makeWebRequest(url, params, options, responseCallback);
    }

    function onSent(code, data) {
        isSending = false;
        if(code==200) {
            isConnected = true;
            var prevLastPositionReceived = lastPositionReceived;
            var lastPositionReceived = lastPositionSent;
            var keys = positionBuffer.keys();
            for (var i = 0; i < keys.size(); i++) {
                if (keys[i] < lastPositionReceived) {
                    positionBuffer.remove(i);
                }
            }
        } else {
            isConnected = false;
            var minT = Time.now().value() - 60;
            var keys = positionBuffer.keys();
            for (var i = 0; i < keys.size(); i++) {
                if (keys[i] < minT) {
                    positionBuffer.remove(keys[i]);
                }
            }
        }
        WatchUi.requestUpdate();
    }
}
