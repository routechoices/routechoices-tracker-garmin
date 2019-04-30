using Toybox.Application;
using Toybox.Position;
using Toybox.Communications;
using Toybox.System;

class RoutechoicesTrackerApp extends Application.AppBase {

    var mainView;
    var deviceId;

    function initialize() {
        AppBase.initialize();
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
        return [ mainView ];
    }

}
