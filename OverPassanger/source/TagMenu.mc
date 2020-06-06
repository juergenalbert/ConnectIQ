using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Position;

function pushTagMenu(tags) {
    var menu = new WatchUi.Menu2({:title=>tags["name"]});

	var tagKeys = tags.keys();
	for (var i = 0; i < tagKeys.size(); i++) {
		var key = tagKeys[i];
		var value = tags[key];
        menu.addItem(new WatchUi.MenuItem(key, value, i, null));
	}
	menu.addItem(new CustomWrapItem(:navigateTo, "Navigate To", Graphics.COLOR_BLUE));
    WatchUi.pushView(menu, new TagMenuDelegate(tags), WatchUi.SLIDE_UP);
}

class TagMenuDelegate extends WatchUi.Menu2InputDelegate {
	hidden var elements;

    function initialize(el) {
    	elements = el;
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}

