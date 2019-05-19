using Toybox.WatchUi as Ui;

class TrackerDelegate extends Ui.BehaviorDelegate {
    hidden var model;
    hidden var started = false;

    function initialize(mdl) {
        model = mdl;
        BehaviorDelegate.initialize();
    }

    function onSelect() {
        model.startActivity();
        started = true;
        return true;
    }

    function onBack() {
        model.stopActivity();
        Toybox.System.exit();
    }
}