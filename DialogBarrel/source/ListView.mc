using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

module DialogBarrel {
	function showListView(options) {
		var listView = new ListView(options);
        var delegate = new ListViewDelegate(listView);
        Ui.pushView(listView, delegate, Ui.SLIDE_UP);
	}

    class ListView extends Ui.View {

		enum { SINGLE_SELECT, MULTI_SELECT }
		enum { TITLE_MINIMIZE, TITLE_NONE, TITLE_HIDE, TITLE_ALWAYS }
		enum { WRAP_NONE, WRAP_BOTH, LEAVE_TITLE }

        enum { NONE, UP, DOWN }

		const HEADER_HEIGHT = 85;
		const SCROLL_FRACTION_STEPS = 3;

        hidden var title;
        hidden var type = SINGLE_SELECT;
        hidden var cellDrawable;
        hidden var model;
        hidden var titleStyle = TITLE_MINIMIZE;
        hidden var wrapStyle = WRAP_NONE;

        hidden var font = Gfx.FONT_SMALL;
        hidden var currentItem = 0;
        hidden var topItem = 0;
        hidden var cellHeights = [];

        hidden var fraction;
        hidden var scrolling = NONE;
        hidden var scrollHeight;

        function initialize(options) {
            View.initialize();
            title = options[:title];
            cellDrawable = options[:cellDrawable];
            model = options[:model];
            type = options[:type];
            titleStyle = options[:titleStyle];
            wrapStyle = options[:wrapStyle];
        }

        function onUpdate(dc) {
            dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
            dc.clear();

            switch (scrolling) {
                case NONE:
                    fraction = 0;
                    scrollHeight = 0;
                    break;
                case UP:
                	if (scrollHeight == 0) {
        				scrollHeight = (getCellHeight(currentItem, dc) + getCellHeight(currentItem - 1, dc)) / 2;
        			}
                    fraction += scrollHeight / SCROLL_FRACTION_STEPS;
                    if (fraction >= scrollHeight) {
                        fraction = 0;
                        currentItem--;
                        scrolling = NONE;
                    }
                    scrollTimer.start(method(:updateUi), SCROLL_DELAY, false);
                    break;
                case DOWN:
                	if (scrollHeight == 0) {
	        			scrollHeight = (getCellHeight(currentItem, dc) + getCellHeight(currentItem + 1, dc)) / 2;
	        		}
	                fraction -= scrollHeight / SCROLL_FRACTION_STEPS;
                    if (fraction <= -scrollHeight) {
                        fraction = 0;
        				currentItem++;
                        scrolling = NONE;
                    }
                    scrollTimer.start(method(:updateUi), SCROLL_DELAY, false);
                    break;
            }

			var currentTop = (dc.getHeight() - getCellHeight(currentItem, dc)) / 2;
			var y = currentTop;
			var index;
			for (index = currentItem - 1; y >= 0 && index >= 0; index--) {
				y -= getCellHeight(index, dc);
			}
			if (index < 0) {
				// there is space to draw the header
	            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_WHITE);
	            dc.fillRectangle(0, 0, dc.getWidth(), y + fraction);
	            dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
	        	dc.drawText(dc.getWidth() / 2, y + fraction - Gfx.getFontHeight(font), font, title, Gfx.TEXT_JUSTIFY_CENTER);

        		if (currentItem == 0 && wrapStyle == LEAVE_TITLE) {
					drawUpArrow(dc, dc.getWidth() / 2, ARROW_PADDING + fraction, Gfx.COLOR_BLACK);
				}
			}
			index++;

        	cellDrawable.setSize(dc.getWidth() * .9, 0);
        	do {
	        	// entries
	        	cellDrawable.setModel(model[index]);
	        	cellDrawable.setSelected(index == currentItem);
	        	cellDrawable.setLocation(dc.getWidth() * .05, y + fraction);
	        	cellDrawable.draw(dc);

	        	y += cellDrawable.height;

	        	index++;
	        } while (index < model.size() && y < dc.getHeight());



			/*
        	// title
        	var y = 0;
        	if (currentItem == 0) {
        		y = HEADER_HEIGHT;
        		topItem = 0;
        	} else if (currentItem == 1) {
        		y = HEADER_HEIGHT / 2;
        		topItem = 0;
        	} else {
        		topItem = currentItem - 2;
        	}
        	y += fraction;
        	if (currentItem < 2) {
	            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_WHITE);
	            dc.fillRectangle(0, 0, dc.getWidth(), y);
	            dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
	        	dc.drawText(dc.getWidth() / 2, y - Gfx.getFontHeight(font), font, title, Gfx.TEXT_JUSTIFY_CENTER);

        		if (currentItem == 0 && wrapStyle == LEAVE_TITLE) {
					drawUpArrow(dc, dc.getWidth() / 2, ARROW_PADDING + fraction, Gfx.COLOR_BLACK);
				}
			}

        	cellDrawable.setSize(dc.getWidth() * .9, 0);
        	var	index = topItem;
        	do {
	        	// entries
	        	cellDrawable.setModel(model[index]);
	        	cellDrawable.setSelected(index == currentItem);
	        	cellDrawable.setLocation(dc.getWidth() * .05, y);
	        	cellDrawable.draw(dc);

	        	y += cellDrawable.height;
	        	while (cellHeights.size() <= index) {
	        		cellHeights.add(0);
	        	}
	        	cellHeights[index] = cellDrawable.height;

	        	index++;
	        } while (index < model.size() && y < dc.getHeight());
	        */
        }

        function getCellHeight(index, dc) {
        	if (index >= cellHeights.size() || cellHeights[index][0] == 0) {
	        	while (cellHeights.size() <= index) {
	        		cellHeights.add([0, 0]);
	        	}

	        	// cell height if selected
	            dc.setColor(Gfx.COLOR_TRANSPARENT, Gfx.COLOR_TRANSPARENT);
        		cellDrawable.setSize(dc.getWidth() * .9, 0);
	        	cellDrawable.setModel(model[index]);
	        	cellDrawable.setSelected(true);
	        	cellDrawable.setLocation(0, 0);
	        	cellDrawable.draw(dc);
	        	cellHeights[index][1] = cellDrawable.height;

	        	// cell height if not selected
	        	cellDrawable.setSelected(false);
	        	cellDrawable.draw(dc);
	        	cellHeights[index][0] = cellDrawable.height;
        	}
        	switch (type) {
        		case SINGLE_SELECT:
	        		if (index == currentItem) {
	        			return cellHeights[index][1];
	        		} else {
	        			return cellHeights[index][0];
	        		}
	        		break;
        		case MULTI_SELECT:
        			if (model[index][:selected]){
	        			return cellHeights[index][1];
	        		} else {
	        			return cellHeights[index][0];
	        		}
	        		break;
        	}
        }

		function updateUi() {
			Ui.requestUpdate();
		}

        function up() {
        	if (currentItem > 0) {
        		scrolling = UP;
        		Ui.requestUpdate();
        	} else {
        		switch (wrapStyle) {
        			case WRAP_BOTH:
        			    currentItem = model.size() - 1;
        			    break;
        			case LEAVE_TITLE:
        				Ui.popView(Ui.SLIDE_DOWN);
        		}
        	}
        }

        function down() {
        	if (currentItem < model.size() - 1) {
        		scrolling = DOWN;
        		Ui.requestUpdate();
        	} else {
        		switch (wrapStyle) {
        			case WRAP_BOTH:
        			    currentItem = 0;
        			    break;
        		}
        	}
        }

        function selectCurrent() {
        	switch (type) {
        		case SINGLE_SELECT:
            		Ui.popView(Ui.SLIDE_DOWN);
        			model[currentItem][:method].invoke();
        			break;
        		case MULTI_SELECT:
        			model[currentItem][:selected] = !model[currentItem][:selected];
        			break;
        	}
        }
    }

    class ListViewDelegate extends Ui.BehaviorDelegate {
        hidden var view;

        function initialize(view) {
            BehaviorDelegate.initialize();
            self.view = view;
        }

        function onPreviousPage() {
        	view.up();
        }

        function onNextPage() {
        	view.down();
        }

        function onSelect() {
        	view.selectCurrent();
        }
    }

    class ListViewDrawable extends Ui.Drawable {
        hidden var model;
        hidden var selected;

        function setModel(model) {
        	self.model = model;
        }

        function setSelected(selected) {
        	self.selected = selected;
        }

    	function initialize() {
    		Drawable.initialize({});
    	}
    }

    class MenuItemDrawable extends ListViewDrawable {
        const PADDING = 8;

    	function initialize() {
    		ListViewDrawable.initialize();
    	}

     	function draw(dc) {
            var font;
            var color;
            if (selected) {
            	font = Gfx.FONT_MEDIUM;
            	color = Gfx.COLOR_WHITE;
            } else {
            	font = Gfx.FONT_SMALL;
            	color = Gfx.COLOR_LT_GRAY;
            }

            height = Gfx.getFontHeight(font) + 2 * PADDING;

    	    dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
            dc.fillRectangle(locX, locY, width, height);
    	    dc.setColor(color, Gfx.COLOR_TRANSPARENT);

            dc.drawText(dc.getWidth() / 2, locY + PADDING, font, model[:text], Gfx.TEXT_JUSTIFY_CENTER);
    	}
    }

    class MenuItemExDrawable extends ListViewDrawable {
        const PADDING = 8;

    	function initialize() {
    		ListViewDrawable.initialize();
    	}

     	function draw(dc) {
            var font;
            var color;
            if (selected) {
            	font = Gfx.FONT_MEDIUM;
            	color = Gfx.COLOR_WHITE;
            } else {
            	font = Gfx.FONT_SMALL;
            	color = Gfx.COLOR_LT_GRAY;
            }

			var lines = [];
			var lineHeight = Gfx.getFontHeight(font);
			splitText(model[:text], font, dc, width, lines);

            height = lineHeight * lines.size() + 2 * PADDING;

    	    dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
            dc.fillRectangle(locX, locY, width, height);
    	    dc.setColor(color, Gfx.COLOR_TRANSPARENT);

            for (var i = 0; i < lines.size(); i++) {
            	dc.drawText(dc.getWidth() / 2, locY + i * lineHeight + PADDING, font, lines[i], Gfx.TEXT_JUSTIFY_CENTER);
           	}
    	}
    }
}