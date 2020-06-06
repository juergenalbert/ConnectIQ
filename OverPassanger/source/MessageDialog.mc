using Toybox.WatchUi;
using Toybox.Lang;
using Toybox.Application;
using Toybox.Graphics as Gfx;

module MessageDialog {

	function show(options) {
		var text;
		if (options[:text] instanceof Lang.String) {
			text = options[:text];
		} else if (options[:text] instanceof Lang.Number) {
			text = Application.loadResource(options[:text]);
		} else {
			text = options[:text].toString();
		}
		
		var view = new MessageDialogView(options[:title], text, options[:menu]);
		WatchUi.pushView(view, new MessageDialogDelegate(view), WatchUi.SLIDE_DOWN);
	}

class MessageDialogView extends WatchUi.View {

    hidden var title;
    hidden var text;
    hidden var menu;
    
    hidden var header;
    hidden var footer;
    hidden var headerText;
    hidden var bodyText;
    hidden var footerText;
    
    hidden var currentPage = 0;
    hidden var pages = [];

    function initialize(title, text, menu) {
        View.initialize();
        self.title = title;
        self.text = text;
        self.menu = menu;
    }

    function onLayout(dc) {
    	var layout = Rez.Layouts.MessageDialogLayout(dc);
    	setLayout(layout);
      	header = findDrawableById("header");
      	footer = findDrawableById("footer");
      	headerText = findDrawableById("headerText");
      	bodyText = findDrawableById("bodyText");
      	footerText = findDrawableById("footerText");
    	
    	headerText.setText(title);
    	
    	var textToBreak = text;
    	do {
    		var result = cutPage(textToBreak);
    		pages.add(result.get(:pageTest));
    		textToBreak = result.get(:remaining);
    	} while (textToBreak.length() > 0);
    	
    	if (menu.size() == 1) {
    		footerText.setText("  " + menu[0][:text]);
    	} else if (menu.size() > 1) {
    		footerText.setText("  ...");
    	}
    }
    
    hidden function cutPage(text) {
    	var result = {};
    	result.put(:pageTest, text.substring(0, 50));
    	result.put(:remaining, text.substring(50, text.length()));
    	return result;
    }

	function onUpdate(dc) {
		dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_WHITE);
		dc.clear();
		
		if (currentPage == 0) {
    		header.draw(dc);
    		headerText.draw(dc);
    	} else {
			drawUpArrow(dc);
    	}
    	
    	bodyText.setText(pages[currentPage]);
    	bodyText.draw(dc);
    	
    	if (currentPage == pages.size() - 1) {
    		footer.draw(dc);
    		footerText.draw(dc);
    		drawMenuDownArrow(dc, (dc.getWidth() - footerText.width) / 2, footerText.locY + 10);
    	} else {
			drawDownArrow(dc);
		}	
		
		var customFont = WatchUi.loadResource(Rez.Fonts.icons);
		dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_WHITE);
		dc.drawText(40, 40, customFont, "ABC", Graphics.TEXT_JUSTIFY_LEFT);
	}

    function nextPage() {
    	currentPage++;
    	if (currentPage == pages.size()) {
    		currentPage = pages.size() - 1;
    		if (menu.size() == 1) {
    			menu[0][:method].invoke();
    		} else if (menu.size() > 1 ) {
				var menu2 = new WatchUi.Menu2({:title => new DrawableMenuTitle(title)});
			
				for (var i = 0; i < menu.size(); i++) {
					var element = menu[i];
			        menu2.addItem(new WatchUi.MenuItem(menu[i][:text], null, i, null));
				}
			
			    WatchUi.pushView(menu2, new MessageMenuDelegate(menu), WatchUi.SLIDE_UP);
    		}
    	}
    	WatchUi.requestUpdate();
    }
    
    function previousPage() {
    	if (currentPage > 0) {
    		currentPage--;
    	}
    	WatchUi.requestUpdate();
    }
}

class MessageMenuDelegate extends WatchUi.Menu2InputDelegate {
	hidden var menu;

    function initialize(menu) {
    	self.menu = menu;
        Menu2InputDelegate.initialize();
    }
    
    function onSelect(item) {
    	var index = item.getId();
    	WatchUi.popView(WatchUi.SLIDE_DOWN);
    	menu[index][:method].invoke();
    }
    
    function onWrap(key) {
        OverPassanger.logDebug("POIMenuDelegate", "onWrap");
        if(key == WatchUi.KEY_UP) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        }
    }
    
    function onTitle(key) {
        OverPassanger.logDebug("POIMenuDelegate", "onTitle");
    }
}


class MessageDialogDelegate extends WatchUi.BehaviorDelegate {
    var view;
    
    function initialize(view) {
        BehaviorDelegate.initialize();
        self.view = view;
    }

    function onMenu() {
		OverPassanger.logDebug(:MessageDialogDelegate, "onMenu");
    }

    function onSelect() {
		OverPassanger.logDebug(:MessageDialogDelegate, "onSelect");
    }

    function onBack() {
		OverPassanger.logDebug(:MessageDialogDelegate, "onBack");
    }

    function pushDialog() {
		OverPassanger.logDebug(:MessageDialogDelegate, "pushDialog");
    }

    function onNextPage() {
		OverPassanger.logDebug(:MessageDialogDelegate, "onNextPage");
		view.nextPage();
    }
    
    function onPreviousPage() {
		OverPassanger.logDebug(:MessageDialogDelegate, "onPreviousPage");
		view.previousPage();
    }
    
    function onResponse(value) {
		OverPassanger.logDebug(:MessageDialogDelegate, "onResponse");
    }
}

class DrawableMenuTitle extends WatchUi.Drawable {
    var mIsTitleSelected = false;
    var title;

    function initialize(title) {
        Drawable.initialize({});
        self.title = title;
    }

    function setSelected(isTitleSelected) {
        mIsTitleSelected = isTitleSelected;
    }

    // Draw the application icon and main menu title
    function draw(dc) {
        var labelWidth = dc.getTextWidthInPixels(title, Graphics.FONT_MEDIUM);

        var arrowX = (dc.getWidth() - (SIZE + GAP + labelWidth)) / 2;
        var arrowY = (dc.getHeight() - SIZE) / 2;
        var labelX = arrowX + SIZE + GAP;
        var labelY = dc.getHeight() / 2;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(labelX, labelY, Graphics.FONT_TINY, title, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
        drawMenuUpArrow(dc, arrowX, arrowY);
    }
}

const GAP = 7;
const SIZE = 10;
	
function drawUpArrow(dc) {
	var x = dc.getWidth() / 2;
	var y;

	dc.setPenWidth(1);
    dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
	
	y = GAP;
	for (var i = 0; i < SIZE; i++) {
		dc.drawLine(x - i, y + i, x + i + 1, y + i);
	}
}	

function drawDownArrow(dc) {
	var x = dc.getWidth() / 2;
	var y = dc.getHeight() - SIZE - GAP;

	dc.setPenWidth(1);
    dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
	
	var d;
	for (var i = 0; i < SIZE; i++) {
		d = SIZE - 1 - i;
		dc.drawLine(x - d, y + i, x + d + 1, y + i);
	}
}	

function drawMenuUpArrow(dc, x, y) {
	dc.setPenWidth(1);
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
	
	for (var i = 0; i < SIZE; i++) {
		dc.drawLine(x - i, y + i, x + i + 1, y + i);
	}
}	
 
function drawMenuDownArrow(dc, x, y) {
	dc.setPenWidth(1);
    dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
	
	var d;
	for (var i = 0; i < SIZE; i++) {
		d = SIZE - 1 - i;
		dc.drawLine(x - d, y + i, x + d + 1, y + i);
	}
}	
 
}
   

