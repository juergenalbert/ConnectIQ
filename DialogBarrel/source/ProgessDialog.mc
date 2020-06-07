using Toybox.WatchUi;

module DialogBarrel {
	function showProgress(message, callback) {
        WatchUi.pushView(new WatchUi.ProgressBar(message, null), new ProgressDelegate(callback), WatchUi.SLIDE_DOWN);
	}

	class ProgressDelegate extends WatchUi.BehaviorDelegate
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
