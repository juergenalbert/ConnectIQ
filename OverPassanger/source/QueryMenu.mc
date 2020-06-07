using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Position;
using Toybox.Application.Storage;
using DialogBarrel as Dialog;

function pushQueryMenu(elements) {
	var menu = new WatchUi.Menu2({:title=>"Query"});

	for (var i = 0; i < elements.size(); i++) {
		var element = elements[i];
		OverPassanger.logVariable("MainMenuDelegate", "element", element);
        menu.addItem(new WatchUi.MenuItem(element["name"], element["subtitle"], i, null));
	}

    WatchUi.pushView(menu, new QueryMenuDelegate(elements), WatchUi.SLIDE_UP);
}

class QueryMenuDelegate extends WatchUi.Menu2InputDelegate {
	hidden var elements;
	hidden var searchActive = false;
	hidden var subtitleTag;

    function initialize(el) {
    	elements = el;
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
    	var index = item.getId();
		OverPassanger.logDebug("QueryMenuDelegate", "onSelect(" + index + ")");
		var query = elements[index]["query"];
		subtitleTag = elements[index]["subtitleTag"];
 		var url = "http://www.overpass-api.de/api/interpreter?data=[out:json];" + query + "(48.14,11.64,48.16,11.66);out%20meta;";
  		
  		Dialog.showProgress("searching...", method(:stopSearch));

    	Communications.makeJsonRequest(url, null, null, self.method(:onResponse));
		searchActive = true;
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    function stopSearch() {
		OverPassanger.logDebug("QueryMenuDelegate", "stopSearch");
		searchActive = false;
		Communications.cancelAllRequests();
    }
    
    function onResponse(code, data) {
		OverPassanger.logDebug("QueryMenuDelegate", "onResponse(" + code + ")");

		OverPassanger.logVariable("QueryMenuDelegate", "searchActive", searchActive);
		if (searchActive) {
	        WatchUi.popView(WatchUi.SLIDE_DOWN);
	
	        if (code == 200) {
	        	var elements = data["elements"];
	        	Storage.setValue("search_result", elements);
	        	
				pushPOIMenu(elements, subtitleTag);
			} else {
				showError("code: " + code);
			}
		}
    }
}

