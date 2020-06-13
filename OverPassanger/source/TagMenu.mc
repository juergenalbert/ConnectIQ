using Toybox.WatchUi as Ui;
using Toybox.Graphics;
using Toybox.Position;

function pushTagMenu(tags) {
    var menu = new Ui.Menu2({:title=>tags["name"]});

	var tagKeys = tags.keys();
	for (var i = 0; i < tagKeys.size(); i++) {
		var key = tagKeys[i];
		var value = tags[key];
        menu.addItem(new Ui.MenuItem(key, value, i, null));
	}
	menu.addItem(new CustomWrapItem(:navigateTo, "Navigate To", Graphics.COLOR_BLUE));
    Ui.pushView(menu, new TagMenuDelegate(tags), Ui.SLIDE_UP);
}

class TagMenuDelegate extends Ui.Menu2InputDelegate {
	hidden var elements;

    function initialize(el) {
    	elements = el;
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
    }

    function onBack() {
        Ui.popView(Ui.SLIDE_DOWN);
    }
}

