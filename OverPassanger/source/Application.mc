using Toybox.Application;
using Toybox.Timer;
using Toybox.WatchUi as Ui;
using LogBarrel;

class OverPassangerApp extends Application.AppBase {

    var log = LogBarrel.getLogger(:OverPassangerApp);

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
    }

    function onStop(state) {
    }

    function getInitialView() {
        var menu = null;
        var delegate = null;
        //if (WatchUi has :Menu2) {
        if (false) {
            /*
            menu = new Rez.Menus.MainMenu2();
            delegate = new MainMenuDelegate();
            */
        } else {
            menu = new Rez.Menus.MainMenu();
            delegate = new MainMenuDelegate();
        }

        //return [ menu, delegate ]; native views not supported for older devices
        return [ new DummyView(menu, delegate), new Ui.BehaviorDelegate() ];
    }

    class DummyView extends Ui.View {
        var log = LogBarrel.getLogger(:DummyView);
        hidden var menu;
        hidden var delegate;
        hidden var firstTime = true;
        
        function initialize(menu, delegate) {
            self.menu = menu;
            self.delegate = delegate;
            View.initialize();
        }
    
        function onLayout(dc) {
            log.debug("onLayout");
            View.onLayout(dc);
        }
        // onShow() is called when this View is brought to the foreground
        function onShow() {
            log.debug("onShow");
            if (firstTime) {
                firstTime = false;
                new Timer.Timer().start(method(:startupTimerCallback), 100, false);
            } else {
                Ui.popView(Ui.SLIDE_IMMEDIATE);         
            }
        }
    
        function startupTimerCallback() {
            Ui.pushView(menu, delegate, Ui.SLIDE_IMMEDIATE);
        }
        
        // onUpdate() is called periodically to update the View
        function onUpdate(dc) {
            log.debug("onUpdate");
            View.onUpdate(dc);
        }
    
        // onHide() is called when this View is removed from the screen
        function onHide() {
            log.debug("onHide");
        }
    }
}
