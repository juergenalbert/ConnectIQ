using Toybox.WatchUi;
using Toybox.Communications;
using Toybox.Lang;
//using LogBarrel.Logger as Logger;

module OverpassBarrel {

(:API)
module OverpassAPI {

	function getProxy(options) {
		return new OverpassProxy(options);
	}

	class OverpassProxy {
		hidden var searchActive = false;
		hidden var options;
		
	    function initialize(options) {
	        self.options = options; 
	    }
		
		function query() {
			var url = "http://www.overpass-api.de/api/interpreter?data=[out:json];node[amenity=restaurant](48.14,11.64,48.16,11.66);out%20meta;";
	
	        WatchUi.pushView(new WatchUi.ProgressBar("searching...", null), new ProgressDelegate(), WatchUi.SLIDE_DOWN);
	
	    	Communications.makeJsonRequest(url, null, null, method(:onQueryOverPassResponse));
			searchActive = true;
		}
	
	    function onQueryOverPassResponse(code, data) {
	    	logDebug("onQueryOverPassResponse(" + code + ")");
	
			if (searchActive) {
		        WatchUi.popView(WatchUi.SLIDE_UP);
		
		        if (code == 200) {
		        	var elements = data["elements"];
					for (var i = 0; i < elements.size(); i++) {
						var element = elements[i];
						//Logger.Debug.logVariable("OverpassAPI", "element", element);
					}
				} else {
					var message = "makeJsonRequest finished with code " + code;
					logError(message);
					if (options.hasKey(:errorDialog)) {
						options[:errorDialog].invoke(message);
					}
				}
			}
			options[:result].invoke(code, data);
	    }
	    
	    function logDebug(message) {
			if (options.hasKey(:logDebug)) {
				options[:logDebug].invoke("OverpassProxy", message);
			}
	    }
	    
	    function logError(message) {
			if (options.hasKey(:logError)) {
				options[:logError].invoke("OverpassProxy", message);
			}
	    }
	}

	class ProgressDelegate extends WatchUi.BehaviorDelegate
	{
	    function initialize() {
	        BehaviorDelegate.initialize();
	    }
	
	    function onBack() {
			Communications.cancelAllRequests();
			searchActive= false;
	        return true;
	    }
	}

}
}
