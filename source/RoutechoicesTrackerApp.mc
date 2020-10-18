using Toybox.Application;


class RoutechoicesTrackerApp extends Application.AppBase {

    var model;

    function initialize() {
        AppBase.initialize();
    }

    //! onStart() is called on application start up
    function onStart(state) {
    }

    //! onStop() is called when your application is exiting
    function onStop(state) {
    }

    //! Return the initial view of your application here
    function getInitialView() {
        model = new TrackerModel();
        var trackerView = new TrackerView(model);
        var trackerBehaviorDelegate = new TrackerBehaviorDelegate(model);
        return [trackerView, trackerBehaviorDelegate];
    }
}
