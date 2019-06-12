using Toybox.System;
using Toybox.WatchUi as Ui;

class TrackerDelegate extends Ui.BehaviorDelegate {
    hidden var model;

    function initialize(mdl) {
        model = mdl;
        BehaviorDelegate.initialize();
    }

    function onSelect() {
        if(model.session.isRecording()) {
            model.stopActivity();
        } else {
            model.startActivity();
        }
        return true;
    }

    function onBack() {
        if(model.session.isRecording()) {
            model.addLap();
        } else {
            model.onQuit();
            System.exit();
        }
        return true;
    }
}
