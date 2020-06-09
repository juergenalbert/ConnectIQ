using Toybox.WatchUi;
using Toybox.Graphics;
using Toybox.Position;

/*
function logDebug(message) {
	if ($ has :LogBarrel) {
		LogBarrel.logDebug(:POIMenu, message);
	}
}
    
function logError(message) {
	if ($ has :LogBarrel) {
		LogBarrel.logError(:POIMenu, message);
	}
}
*/

function logVariable(name, value) {
   	logVariable(name, value);
}

function pushPOIMenu(elements, subtitleTag) {
	//var menu = new WatchUi.Menu2({:title=>"POIs"});
	var menu = new WrapTopMenu(80,Graphics.COLOR_BLACK,{});
	
	for (var i = 0; i < elements.size(); i++) {
		var element = elements[i];
		var tags = element["tags"];
		var subTitle = null;
		if (subtitleTag != null) {
			subTitle = tags[subtitleTag];
		}
        menu.addItem(new WatchUi.MenuItem(tags["name"], subTitle, i, null));
    	//menu.addItem(new CustomWrapItem(i, tags["name"], Graphics.COLOR_WHITE));
	}
    menu.addItem(new CustomWrapItem(:iii, "iii", Graphics.COLOR_WHITE));
    var drawable1 = new CustomIcon();
    //menu.addItem(new WatchUi.IconMenuItem("Icon 1", drawable1.getString(), "left", drawable1, {:alignment=>WatchUi.MenuItem.MENU_ITEM_LABEL_ALIGN_LEFT}));
    menu.addItem(new CustomWrapItem("yyy", "xxx", Graphics.COLOR_WHITE));
    WatchUi.pushView(menu, new POIMenuDelegate(elements), WatchUi.SLIDE_UP);
}

class POIMenuDelegate extends WatchUi.Menu2InputDelegate {
	hidden var elements;

    function initialize(el) {
    	elements = el;
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
    	var index = item.getId();
		var poi = elements[index];

		pushTagMenu(poi["tags"]);
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    function onDone() {
		logDebug("onDone");
    }

    function onFooter() {
		logDebug("onFooter");
    }

    function onTitle() {
		logDebug("onTitle");
    }

    function onWrap(key) {
		logDebug("onWrap key=" + key.toString());
    }

    function onMenu() {
		logDebug("onMenu");
    }
}

class CustomWrapItem extends WatchUi.CustomMenuItem {
    var mLabel;
    var mTextColor;

    function initialize(id, label, textColor) {
        CustomMenuItem.initialize(id, {});
        mLabel = label;
        mTextColor = textColor;
    }

    // draw the item string at the center of the item.
    function draw(dc) {
        var font;
        if( isFocused() ) {
            font = Graphics.FONT_LARGE;
        } else {
            font = Graphics.FONT_SMALL;
        }

        if( isSelected() ) {
            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLUE);
            dc.clear();
        }

        dc.setColor(mTextColor, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth() / 2, dc.getHeight()/2, font, mLabel, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}






class WrapTopMenu extends WatchUi.CustomMenu {
    function initialize(itemHeight, backgroundColor, options) {
        CustomMenu.initialize(itemHeight, backgroundColor, options);
    }

	/*
    function drawBackground(dc) {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
    }
    */

    function drawTitle(dc) {
        if( Toybox.WatchUi.CustomMenu has :isTitleSelected ) {
            if( isTitleSelected() ) {
                dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_BLUE);
                dc.clear();
            }
        }
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_DK_GRAY);
        dc.setPenWidth(3);
        dc.drawLine(0,dc.getHeight()-2,dc.getWidth(),dc.getHeight()-2);
        dc.setPenWidth(1);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth()/2, dc.getHeight()/2, Graphics.FONT_MEDIUM, "Top\nMenu", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }

    function drawFooter(dc) {
        var height = dc.getHeight();
        var centerX = dc.getWidth() / 2;
        var bkColor = Graphics.COLOR_WHITE;
        if( Toybox.WatchUi.CustomMenu has :isFooterSelected ) {
            bkColor = isFooterSelected() ? Graphics.COLOR_BLUE : Graphics.COLOR_WHITE;
        }
        dc.setColor(bkColor, bkColor);
        dc.clear();
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_DK_GRAY);
        dc.setPenWidth(3);
        dc.drawLine(0,1,dc.getWidth(),1);
        dc.setPenWidth(1);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth()/2, dc.getHeight()/3, Graphics.FONT_MEDIUM, "To Sub Menu", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillPolygon([[centerX,height-10],[centerX+5,height-15],[centerX-5,height-15]]);
    }
}

class WrapBottomMenu extends WatchUi.CustomMenu {
    function initialize(itemHeight, backgroundColor, options) {
        CustomMenu.initialize(itemHeight, backgroundColor, options);
    }

    function drawTitle(dc) {
        var centerX = dc.getWidth() / 2;
        var bkColor = Graphics.COLOR_BLACK;
        if( Toybox.WatchUi.CustomMenu has :isTitleSelected ) {
            bkColor = isTitleSelected() ? Graphics.COLOR_BLUE : Graphics.COLOR_BLACK;
        }
        dc.setColor(bkColor, bkColor);
        dc.clear();
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_DK_GRAY);
        dc.setPenWidth(3);
        dc.drawLine(0,dc.getHeight()-2,dc.getWidth(),dc.getHeight()-2);
        dc.setPenWidth(1);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth()/2, dc.getHeight()/3*2, Graphics.FONT_MEDIUM, "Back to Top", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
        dc.fillPolygon([[centerX,10],[centerX+5,15],[centerX-5,15]]);
    }
}

//This is the menu input delegate shared by all the basic sub-menus in the application
class WrapTopCustomDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        WatchUi.requestUpdate();
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    function onWrap(key) {
        if(key == WatchUi.KEY_DOWN) {
            logDebug("onWrap");
            //pushWrapCustomBottom();
        }
        return false;
    }

    function onFooter() {
        logDebug("onFooter");
        //pushWrapCustomBottom();
    }
}

//This is the menu input delegate shared by all the basic sub-menus in the application
class WrapBottomCustomDelegate extends WatchUi.Menu2InputDelegate {
    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item) {
        WatchUi.requestUpdate();
    }

    function onBack() {
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
    }

    function onWrap(key) {
        if(key == WatchUi.KEY_UP) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        }
        return false;
    }

    function onTitle() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}

// This is the custom Icon drawable. It fills the icon space with a color to
// to demonstrate its extents. It changes color each time the next state is
// triggered, which is done when the item is selected in this application.
class CustomIcon extends WatchUi.Drawable {
    // This constant data stores the color state list.
    const mColors = [Graphics.COLOR_RED, Graphics.COLOR_ORANGE, Graphics.COLOR_YELLOW, Graphics.COLOR_GREEN, Graphics.COLOR_BLUE, Graphics.COLOR_PURPLE];
    const mColorStrings = ["Red", "Orange", "Yellow", "Green", "Blue", "Violet"];
    var mIndex;

    function initialize() {
        Drawable.initialize({});
        mIndex = 0;
    }

    // Advance to the next color state for the drawable
    function nextState() {
        mIndex++;
        if(mIndex >= mColors.size()) {
            mIndex = 0;
        }

        return mColorStrings[mIndex];
    }

    // Return the color string for the menu to use as it's sublabel
    function getString() {
        return mColorStrings[mIndex];
    }

    // Set the color for the current state and use dc.clear() to fill
    // the drawable area with that color
    function draw(dc) {
        var color = mColors[mIndex];
        dc.setColor(color, color);
        dc.clear();
    }
}


