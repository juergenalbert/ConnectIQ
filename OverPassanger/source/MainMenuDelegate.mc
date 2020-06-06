using Toybox.WatchUi;
using Toybox.PersistedContent;
using Toybox.Communications;
using Toybox.Position;
using Toybox.Application.Storage;
using Toybox.Background;
using MessageDialog;
using ProgressDialog;
using OverpassBarrel.OverpassAPI as Overpass;
using OverPassanger;

//(:background)
class MainMenuDelegate extends WatchUi.Menu2InputDelegate {
	//hidden const FIVE_MINUTES = new Time.Duration(5 * 60);
    var searchActive = false;
    
   	function logDebug(message) {
   		OverPassanger.logDebug(:MainMenuDelegate, message);
   	}

   	function logError(message) {
   		OverPassanger.logError(:MainMenuDelegate, message);
   	}

   	function logVariable(name, value) {
   		OverPassanger.logVariable(:MainMenuDelegate, name, value);
   	}

    function onTemporalEvent() {
		logDebug("onTemporalEvent");
	}

    function initialize() {
        Menu2InputDelegate.initialize();
	}

    function onSelect(item) {
    	self.method(item.getId()).invoke();
    }

	function createAppWaypoints() {
		logDebug("createWaypoints");
		for (var i = 0; i < 100; i++) {
			var location = new Position.Location ({
	       		:latitude => 48.130366 + i * 0.01, 
	       		:longitude => 11.640660 + i * 0.01,
	       		:format => :degrees
	       	});
	       	var options = {
	       		:name => "Waypoint " + i
	       	};
			
			PersistedContent.saveWaypoint(location, options);
			logDebug("Waypoint created: " + options);
		}
	}

	function createWaypoints() {
		logDebug("createWaypoints");
		for (var i = 0; i < 100; i++) {
			var location = new Position.Location ({
	       		:latitude => 48.130366 + i * 0.01, 
	       		:longitude => 11.640660 + i * 0.01,
	       		:format => :degrees
	       	});
	       	var options = {
	       		:name => "Waypoint " + i
	       	};
			
			PersistedContent.saveWaypoint(location, options);
			logDebug("Waypoint created: " + options);
		}
	}

	function getWaypoints() {
        var iterator = PersistedContent.getWaypoints();
        var waypoint = iterator.next();
        
        while (waypoint != null) {
        	waypoint = iterator.next();
        }
	}

	function getAppWaypoints() {
        var iterator = PersistedContent.getAppWaypoints();
        var waypoint = iterator.next();
        
        while (waypoint != null) {
        	waypoint = iterator.next();
        }
	}

	function deleteWaypoints() {
        var iterator = PersistedContent.getWaypoints();
        var waypoint = iterator.next();
        
        while (waypoint != null) {
        	try {
        		waypoint.remove();
        	} catch (e) {
        		logError(e);
        	}
        	waypoint = iterator.next();
        }
	}
	
	function createProperites() {
		for (var i = 0; i < 100; i++) {
			var location = new Position.Location ({
	       		:latitude => 48.130366 + i * 0.01, 
	       		:longitude => 11.640660 + i * 0.01,
	       		:format => :degrees
	       	});
	       	var options = {
	       		:name => "Waypoint " + i
	       	};
			
			var name = options.get(:name);
			
			Storage.setValue(name, name);
			logDebug("Waypoint created: " + options);
		}
	}

	function getProperites() {
		var i = 0;
		do {
			var name = "Waypoint " + i;
			var value = Storage.getValue(name);
				if (value == null) {
				break;
			} 
			logVariable("Waypoint read: ", value);
			i++;
		} while (true);
	}

	function createIntent() {
        var iterator = PersistedContent.getAppWaypoints();
        var waypoint = iterator.next();

		System.exitTo(waypoint.toIntent());        
	}

	function queryOverPass() {
		Overpass.getProxy({
			:result => self.method(:queryOverPassResult),
			:logDebug => new Toybox.Lang.Method(OverPassanger, :logDebug),
			:logError => new Toybox.Lang.Method(OverPassanger, :logError),
			:errorDialog => new Toybox.Lang.Method(MessageDialog, :show),
		}).query();
	}
	
	function queryOverPassResult(code, data) {
		logVariable("queryOverPassResult code", code);
		logVariable("queryOverPassResult data", data);
	}

	function queryList() {
	   	var url = Application.getApp().getProperty("QueriesURL");                        
 		ProgressDialog.show("searching...", method(:stopSearch));
    	Communications.makeJsonRequest(url, null, null, self.method(:onQueriesResponse));
		searchActive = true;
	}
	
    function stopSearch() {
		logDebug("stopSearch");
		searchActive = false;
		Communications.cancelAllRequests();
    }

    function onQueriesResponse(code, data) {
		logDebug("onQueriesResponse(" + code + ")");

		if (searchActive) {
	        WatchUi.popView(WatchUi.SLIDE_DOWN);
	
	        if (code == 200) {
				Storage.setValue("queries", data["queries"]);
	        	pushQueryMenu(data["queries"]);
			} else {
				logError("queryList terminated with " + code);
				var queries = Storage.getValue("queries");
				if (queries == null) {
					MessageDialog.show(Rez.Strings.NoQueries);	
				} else {
	        		pushQueryMenu(queries);
				}
			}
		}
    }
    
	function readData() {
		var searchResult = Storage.getValue("search_result");
		logVariable("searchResult", searchResult);
	}
	
	function messageTest() {
		var options = {
			:title => "Der Titel ist lang",
			:text => "Lorem\nIn Connect IQ 3.1, these are no longer issues thanks to WatchUi.TextArea and relative coordinates. The WatchUi.TextArea is a super powered upgrade to WatchUi.Text. ",
			:menu => [
				{:text => "Verwerfen", :method => method(:dismiss)},
				{:text => "Akzeptieren", :method => method(:accept)}
			]
		};
		MessageDialog.show(options);
	}
	
	function dismiss() {
		logDebug("dismiss");
		WatchUi.popView(WatchUi.SLIDE_DOWN);
	}
	
	function accept() {
		logDebug("accept");
		WatchUi.popView(WatchUi.SLIDE_DOWN);
	}
}


