using Toybox.WatchUi;
using Toybox.Lang;
using Toybox.Application;
using Toybox.Graphics as Gfx;
using DialogBarrel;

module DialogBarrel {
	const ARROW_PADDING = 7;
	const ARROW_SIZE = 10;
		
    function logDebug(message) {
		if ($ has :LogBarrel) {
			LogBarrel.logDebug(:DialogBarrel, message);
		}
    }
    
    function logError(message) {
		if ($ has :LogBarrel) {
			LogBarrel.logError(:DialogBarrel, message);
		}
    }
    
    function logVariable(name, value) {
		if ($ has :LogBarrel) {
			LogBarrel.logVariable(:DialogBarrel, name, value);
		}
    }
    
	function showError(error) {
		var view = new MessageDialogView(toText(Rez.Strings.Error), Gfx.COLOR_RED, toText(error), [{:text => toText(Rez.Strings.OK), :method => new Toybox.Lang.Method(DialogBarrel, :close)}]);
		WatchUi.pushView(view, new MessageDialogDelegate(view), WatchUi.SLIDE_DOWN);
	}

	function showMessage(options) {
		var text = toText(options[:text]);
		var view = new MessageDialogView(options[:title], Gfx.COLOR_BLACK, text, options[:menu]);
		WatchUi.pushView(view, new MessageDialogDelegate(view), WatchUi.SLIDE_DOWN);
	}
	
	function toText(message) {
		if (message instanceof Lang.String) {
			return message;
		} else if (message instanceof Lang.Number) {
			return WatchUi.loadResource(message);
		} else {
			return message.toString();
		}
	}
	
	function close() {
		WatchUi.popView(WatchUi.SLIDE_DOWN);
	}
	
	function drawDownArrow(dc, x, y, color) {
		dc.setPenWidth(1);
	    dc.setColor(color, color);
		
		var d;
		for (var i = 0; i < ARROW_SIZE; i++) {
			d = ARROW_SIZE - 1 - i;
			dc.drawLine(x - d, y + i, x + d + 1, y + i);
		}
	}	
	
	function drawUpArrow(dc, x, y, color) {
		dc.setPenWidth(1);
	    dc.setColor(color, color);
		
		for (var i = 0; i < ARROW_SIZE; i++) {
			dc.drawLine(x - i, y + i, x + i + 1, y + i);
		}
	}	

	class MessageDialogView extends WatchUi.View {
	
	    hidden var title;
	    hidden var titleColor;
	    hidden var text;
	    hidden var menu;
	    
	    hidden var header;
	    hidden var footer;
	    hidden var headerText;
	    var bodyText;
	    hidden var footerText;
	    	
	    function initialize(title, titleColor, text, menu) {
	        View.initialize();
	        self.title = title;
	        self.titleColor = titleColor;
	        self.text = text;
	        self.menu = menu;
	    }
	
	    function onLayout(dc) {
	    	var layout = DialogBarrel.Rez.Layouts.MessageDialogLayout(dc);
	    	setLayout(layout);
	      	header = findDrawableById("header");
	      	footer = findDrawableById("footer");
	      	headerText = findDrawableById("headerText");
	      	bodyText = findDrawableById("bodyText");
	      	footerText = findDrawableById("footerText");
	    	
	    	headerText.setText(title);
	    	bodyText.setText(text);
	    	
	    	var f = "";
	    	if (menu.size() == 1) {
				f = menu[0][:text];
	    	} else if (menu.size() > 1) {
	    		f = "...";
	    	}
    		if (!System.getDeviceSettings().isTouchScreen) {
    			f = "  " + f;
    		} 
	    	footerText.setText(f);
	    }
	    
		function onUpdate(dc) {
			dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_WHITE);
			dc.clear();
			
			if (bodyText.atStart()) {
				header.setColor(titleColor);
				header.draw(dc);
	    		headerText.draw(dc);
	    	} else {
				drawUpArrow(dc, dc.getWidth() / 2, ARROW_PADDING, Gfx.COLOR_BLACK);
	    	}
	    	
	    	bodyText.draw(dc);
	    	
	    	if (bodyText.atEnd()) {
	    		footer.draw(dc);
	    		footerText.draw(dc);
	    		if (!System.getDeviceSettings().isTouchScreen) {
		    		drawDownArrow(dc, (dc.getWidth() - footerText.width) / 2, footerText.locY + 10, Gfx.COLOR_WHITE);
		    	}
	    	} else {
				drawDownArrow(dc, dc.getWidth() / 2, dc.getHeight() - ARROW_SIZE - ARROW_PADDING, Gfx.COLOR_BLACK);
			}	
			
			/*
			var customFont = WatchUi.loadResource(Rez.Fonts.icons);
			dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_WHITE);
			dc.drawText(40, 40, customFont, "ABC", Graphics.TEXT_JUSTIFY_LEFT);
			*/
		}
	
	    function scrollDown() {
	    	if (bodyText.atEnd()) {
	    		if (menu.size() == 1) {
	    			menu[0][:method].invoke();
	    		} else if (menu.size() > 1 ) {
	    			openMenu();
	    		}
	    	} else {
	    		bodyText.scrollDown();
	    	}
	    }
	    
	    function scrollUp() {
	    	bodyText.scrollUp();
	    }
	    
	    function openMenu() {
  			var menuView;
			if (WatchUi has :Menu2) {
				menuView = new WatchUi.Menu2({:title => new DrawableMenuTitle(title)});
				for (var i = 0; i < menu.size(); i++) {
		        	menuView.addItem(new WatchUi.MenuItem(menu[i][:text], null, i, null));
				}
				WatchUi.pushView(menuView, new MessageMenu2Delegate(menu), WatchUi.SLIDE_UP);
			} else {
				menuView = new WatchUi.Menu();
				for (var i = 0; i < menu.size(); i++) {
			        menuView.addItem(menu[i][:text], i);
				}
				WatchUi.pushView(menuView, new MessageMenuDelegate(menu), WatchUi.SLIDE_UP);
			}
	    }
	}
	
	class MessageDialogDelegate extends WatchUi.BehaviorDelegate {
	    var view;
	    
	    function initialize(view) {
	        BehaviorDelegate.initialize();
	        self.view = view;
	    }
	
	    function onMenu() {
			logDebug("onMenu");
			view.openMenu();
	    }
	
	    function onSelect() {
			logDebug("onSelect");
			return false;
	    }
	
	    function onBack() {
			logDebug("onBack");
	    }
	
	    function pushDialog() {
			logDebug("pushDialog");
	    }
	
	    function onNextPage() {
			logDebug("onNextPage");
			view.scrollDown();
	    }
	    
	    function onPreviousPage() {
			logDebug("onPreviousPage");
			view.scrollUp();
	    }
	    
	    function onResponse(value) {
			logDebug("onResponse");
	    }
	    
	    function onTap(clickEvent) {
			logDebug("onTap");
	        var ypos = clickEvent.getCoordinates()[1];
	        if (ypos < view.bodyText.locY) {
				view.scrollUp();
	        } else if (ypos > view.bodyText.locY + view.bodyText.height) {
				view.scrollDown();
	        }    
	        return true;
    	}
    	
    	function onSwipe(swipeEvent) {
			logDebug("onSwipe");
			var dir = swipeEvent.getDirection();
			if (dir == WatchUi.SWIPE_DOWN) {
				view.scrollUp();
			} else if (dir == WatchUi.SWIPE_UP) {
				view.scrollDown();
			} 
	        return false;
    	}
	}
	
	class MessageMenuDelegate extends WatchUi.MenuInputDelegate {
		hidden var menu;
	
	    function initialize(menu) {
	    	self.menu = menu;
	        MenuInputDelegate.initialize();
	    }
	    
	    function onMenuItem(item) {
	    	menu[item][:method].invoke();
	    }
	}
	
	class MessageMenu2Delegate extends WatchUi.Menu2InputDelegate {
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
	        logDebug("onWrap");
	        if(key == WatchUi.KEY_UP) {
	            WatchUi.popView(WatchUi.SLIDE_DOWN);
	        }
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
	
	        var arrowX = (dc.getWidth() - (ARROW_SIZE + ARROW_PADDING + labelWidth)) / 2;
	        var arrowY = (dc.getHeight() - ARROW_SIZE) / 2;
	        var labelX = arrowX + ARROW_SIZE + ARROW_PADDING;
	        var labelY = dc.getHeight() / 2;
	
	        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
	        dc.clear();
	
	        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
	        dc.drawText(labelX, labelY, Graphics.FONT_TINY, title, Graphics.TEXT_JUSTIFY_LEFT | Graphics.TEXT_JUSTIFY_VCENTER);
	        drawUpArrow(dc, arrowX, arrowY, Gfx.COLOR_WHITE);
	    }
	}
	
	class Background extends Toybox.WatchUi.Drawable {
		var color = Gfx.COLOR_BLACK;
		
		function initialize(options) {
			Toybox.WatchUi.Drawable.initialize(options);
		}
		
		function draw(dc) {
	        dc.setColor(color, color);
	        locX = calc(locX, dc.getWidth());
	        locY = calc(locY, dc.getHeight());
	        width = calc(width, dc.getWidth());
	        height = calc(height, dc.getHeight());
	        dc.fillRectangle(locX, locY, width, height);
	    }
	    
	    function setColor(color) {
	    	self.color = color;
	    }
	}

    function calc(val, dcSize) {
    	if (val instanceof Lang.String) {
        	if (val.find("%") == val.length() -1) {
        		return val.toNumber() * dcSize / 100;
        	} else {
        		return val.toNumber();
        	}
        } else {
        	return val;
        }
    }
	    
	class TextArea extends Toybox.WatchUi.Drawable {
		var color = Gfx.COLOR_BLACK;
		var text;
		var dcWidth = -1;
		var dcHeight = -1;
		var font = Gfx.FONT_MEDIUM;
		var lines = [];
		var lineHeight;
		var scrollPos = 0;
		var numLines;
		
		function initialize(options) {
			Toybox.WatchUi.Drawable.initialize(options);
			if (options.hasKey(:font)) {
				font = options[:font];
				/*
				if (fontname.equals("Graphics.FONT_XTINY")) {
					font = Graphics.FONT_XTINY;
				} else if (fontname.equals("Graphics.FONT_TINY")) {
					font = Graphics.FONT_TINY;
				} else if (fontname.equals("Graphics.FONT_SMALL")) {
					font = Graphics.FONT_SMALL;
				} else if (fontname.equals("Graphics.FONT_MEDIUM")) {
					font = Graphics.FONT_MEDIUM;
				} else if (fontname.equals("Graphics.FONT_LARGE")) {
					font = Graphics.FONT_LARGE;
				} 
				logVariable("fontname", fontname);
				logVariable("font", font);
				*/
			}
		}
		
		function draw(dc) {
			if (dc.getWidth() != dcWidth || dc.getHeight() != dcHeight) {
				dcWidth = dc.getWidth();
				dcHeight = dc.getHeight();
				recalculate(dc);
			}

	        dc.setColor(color, Gfx.COLOR_TRANSPARENT);
	        for (var i = 0; i < numLines && i < lines.size(); i++ ) {
	        	dc.drawText(locX, locY + lineHeight * i, font, lines[scrollPos + i], Gfx.TEXT_JUSTIFY_LEFT);
	        }
	    }
	    
	    function scrollDown() {
	    	if (scrollPos + numLines <= lines.size()) {
	    		scrollPos++;
	    		WatchUi.requestUpdate();
	    		return true;
	    	} else {
	    		return false;
	    	}
	    }
	    
	    function scrollUp() {
	    	if (scrollPos > 0) {
	    		scrollPos--;
	    		WatchUi.requestUpdate();
	    		return true;
	    	} else {
	    		return false;
	    	}
	    }
	    
	    function atStart() {
	    	return scrollPos == 0;
	    }
	    
	    function atEnd() {
	    	return scrollPos >= lines.size() - numLines;
	    }
	    
	    hidden function recalculate(dc) {
	        locX = calc(locX, dc.getWidth());
	        locY = calc(locY, dc.getHeight());
	        width = calc(width, dc.getWidth());
	        height = calc(height, dc.getHeight());
	        
	        var fontDescent = Gfx.getFontDescent(font);
	        var fontHeight = Gfx.getFontHeight(font);
	        numLines = (height + fontDescent) / fontHeight;
	        lineHeight = fontHeight;
	        
	        var chars = text.toCharArray();
	        var startPos = 0;
	        var endPos = 0;
	        var breakAll = false;
	        
	        do {
		        var lastSplit = -1;
		        var testee;
		        var testeeWidth; 
		        var charArray;
		        var lastChar;
		        do {
		        	endPos++;
		        	if (endPos >= chars.size()) {
		        		breakAll = true;
		        		break;
		        	}
		        	lastChar = chars[endPos];
		        	if (lastChar == ' ' || lastChar == '\t' || lastChar == '\n') {
		        		lastSplit = endPos;
		        	} 
		        	charArray = chars.slice(startPos, endPos); 
		        	testee = StringUtil.charArrayToString(charArray);
		        	testeeWidth = dc.getTextWidthInPixels(testee, font);
		        } while (testeeWidth < width && lastChar != '\n');
		        if (lastSplit != -1) {
		        	testee = StringUtil.charArrayToString(chars.slice(startPos, lastSplit));
		        	lines.add(testee);
		        	startPos = lastSplit + 1;
		        	endPos = startPos;
		        } else {
		        	lines.add(testee);
		        	startPos = endPos;
		        }
		    } while (!breakAll);
	        
	        
	        
	        /*
	        lines.add("some text");
	        lines.add("some more text");
	        lines.add("some very long text");
	        lines.add("some very long and too long text");
	        lines.add("last line");
	        */
	    }
	    
	    function setColor(color) {
	    	self.color = color;
	    }
	    
	    function setText(text) {
	    	self.text = text;
	    }
	}
}  

