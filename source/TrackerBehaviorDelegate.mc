using Toybox.System;
using Toybox.WatchUi as Ui;

class TrackerBehaviorDelegate extends Ui.BehaviorDelegate {
    hidden var model;
    hidden var lastDownKeyPressed;

    function initialize(mdl) {
        model = mdl;
        lastDownKeyPressed = null;
        BehaviorDelegate.initialize();
    }

    function onSelect() {
        if(model.session.isRecording()) {
            model.stopActivity();
        } else {
            if (lastDownKeyPressed && System.getTimer() - lastDownKeyPressed < 1000) {
                model.resetDeviceId();
            } else {
                model.startActivity();
            }
        }
        lastDownKeyPressed = null;
        return true;
    }

    function onBack() {
        if(model.session.isRecording()) {
            model.addLap();
        } else {
            model.onQuit();
            System.exit();
        }
        lastDownKeyPressed = null;
        return true;
    }

    function onNextPage() {
        if(model.accumulatedTime == 0) {
            lastDownKeyPressed = System.getTimer();
        }
        return true;
    }
}
