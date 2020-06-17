using Toybox.WatchUi as Ui;

module DialogBarrel {
    function showProgress(message, callback) {
        if (Ui has :ProgressBar) {
            Ui.pushView(new Ui.ProgressBar(message, null), new ProgressDelegate(callback), Ui.SLIDE_DOWN);
        }
    }

    class ProgressDelegate extends Ui.BehaviorDelegate
    {
        var mCallback;
        function initialize(callback) {
            mCallback = callback;
            BehaviorDelegate.initialize();
        }

        function onBack() {
            mCallback.invoke();
            return true;
        }
    }
}
