using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

module DialogBarrel {    
    function showListView(options) {
        var listView = new ListView(options);
        var delegate = new ListViewDelegate(listView);
        Ui.pushView(listView, delegate, Ui.SLIDE_UP);
    }

    class ListView extends Ui.View {
        static var log = getLogger(:ListView);
    
        enum { SINGLE_SELECT, MULTI_SELECT }
        enum { TITLE_MINIMIZE, TITLE_NONE, TITLE_HIDE, TITLE_ALWAYS }
        enum { WRAP_NONE, WRAP_BOTH, LEAVE_TITLE }

        enum { NONE, UP, DOWN }

        const SCROLL_FRACTION_STEPS = 2;
        const CELL_WIDTH_PERCENTAGE = .9;
        const CELL_POS_X_PERCENTAGE = (1.0 - CELL_WIDTH_PERCENTAGE) / 2;

        hidden var title;
        hidden var type = SINGLE_SELECT;
        hidden var cellDrawable;
        hidden var model;
        hidden var modelKeys;
        hidden var itemToString;
        hidden var callback;
        hidden var titleStyle = TITLE_MINIMIZE;
        hidden var wrapStyle = WRAP_NONE;

        hidden var font = FontSize.medium();
        hidden var currentItem = 0;
        hidden var topItem = 0;
        hidden var cellHeights = [];

        hidden var fraction = 0;
        hidden var scrolling = NONE;
        hidden var scrollHeight;
        hidden var currentTop = -1;

        function initialize(options) {
            log.debug(:initialize);
            View.initialize();
            title = options[:title];
            cellDrawable = options[:cellDrawable];
            model = options[:model];
            callback = options[:callback];
            itemToString = options[:itemToString];
            type = options[:type];
            titleStyle = options[:titleStyle];
            wrapStyle = options[:wrapStyle];
            
            if (model instanceof Dictionary) {
                modelKeys = model.keys();
            }
        }

        function onUpdate(dc) {
            log.debug("onUpdate");
            dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
            dc.clear();

            switch (scrolling) {
                case NONE:
                    fraction = 0;
                    scrollHeight = 0;
                    break;
                case UP:
                    if (needScrolling(dc)) {
                        if (scrollHeight == 0) {
                            scrollHeight = (getCellHeight(currentItem, dc) + getCellHeight(currentItem - 1, dc)) / 2;
                        }
                        fraction += scrollHeight / SCROLL_FRACTION_STEPS;
                        if (fraction >= scrollHeight) {
                            fraction = 0;
                            currentItem--;
                            topItem = currentItem;
                            scrolling = NONE;
                        } else {
                            scrollTimer.start(method(:updateUi), SCROLL_DELAY, false);
                        }
                    } else {
                        currentItem--;
                        scrolling = NONE;
                    }
                    break;
                case DOWN:
                    if (needScrolling(dc)) {
                        if (scrollHeight == 0) {
                            scrollHeight = (getCellHeight(currentItem, dc) + getCellHeight(currentItem + 1, dc)) / 2;
                        }
                        fraction -= scrollHeight / SCROLL_FRACTION_STEPS;
                        if (fraction <= -scrollHeight) {
                            fraction = 0;
                            currentItem++;
                            topItem = currentItem;
                            scrolling = NONE;
                        } else {
                            scrollTimer.start(method(:updateUi), SCROLL_DELAY, false);
                        }
                    } else {
                        currentItem++;
                        scrolling = NONE;
                    }
                    break;
            }

            var y = regularTopOfItem(topItem, dc);
            var index;
            for (index = topItem - 1; y >= 0 && index >= 0; index--) {
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

            cellDrawable.setSize(dc.getWidth() * CELL_WIDTH_PERCENTAGE, 0);
            do {
                // entries
                if (model instanceof Array) {
                    cellDrawable.setModel(model[index]);
                } else if (model instanceof Dictionary) {
                    cellDrawable.setModel([modelKeys[index], model[modelKeys[index]]]);
                }
                cellDrawable.setSelected(index == currentItem);
                cellDrawable.setLocation(dc.getWidth() * CELL_POS_X_PERCENTAGE, y + fraction);
                cellDrawable.draw(dc);

                if (index == currentItem) {
                    currentTop = y;
                }

                y += cellDrawable.height;

                index++;
            } while (index < model.size() && y < dc.getHeight());
        }

        function regularTopOfItem(index, dc) {
            log.debug("regularTopOfItem");
            if (System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_RECTANGLE/* && dc.getHeight() >= 400*/) {
                return dc.getHeight() * .25;
            } else {
                return (dc.getHeight() - getCellHeight(index, dc)) / 2;
            }
        }
        
        function needScrolling(dc) {
            log.debug("needScrolling");
            if (fraction > 0) {
                // we are in scrolling mode, dont calc anything
                return true;
            } else {
                switch (scrolling) {
                    case UP:
                        if (topItem > 0) {
                            return currentTop - getCellHeight(topItem - 1, dc) < regularTopOfItem(topItem - 1, dc);
                        } else {
                            return false;
                        }
                    case DOWN:       
                        if (currentTop < 0) {
                            currentTop = regularTopOfItem(0, dc);
                        }
                        var y = currentTop;
                        var index = currentItem;
                        var maxBottom;
                        if (System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_ROUND) {
                            maxBottom = dc.getHeight() * .85;
                        } else {
                            maxBottom = dc.getHeight();
                        }
                        do {
                            y += getCellHeight(index, dc);
                            index++;
                        } while (y < maxBottom && index < model.size());
                        return (index < model.size() || y >= maxBottom);
                }
            }
        }

        function getCellHeight(index, dc) {
            log.debug("getCellHeight");
            if (index >= cellHeights.size() || cellHeights[index][ListViewDrawable.UNSELECTED] == 0) {
                log.debug("...calculate");
                while (cellHeights.size() <= index) {
                    cellHeights.add([0, 0]);
                }

                // cell height if selected
                cellDrawable.setSize(dc.getWidth() * CELL_WIDTH_PERCENTAGE, 0);
                if (model instanceof Array) {
                    cellDrawable.setModel(model[index]);
                } else if (model instanceof Dictionary) {
                    cellDrawable.setModel([modelKeys[index], model[modelKeys[index]]]);
                }
                cellHeights[index] = cellDrawable.calculateHeight(dc);
            }
            switch (type) {
                case SINGLE_SELECT:
                    if (index == currentItem) {
                        return cellHeights[index][ListViewDrawable.SELECTED];
                    } else {
                        return cellHeights[index][ListViewDrawable.UNSELECTED];
                    }
                    break;
                case MULTI_SELECT:
                    if (model[index][:selected]){
                        return cellHeights[index][ListViewDrawable.SELECTED];
                    } else {
                        return cellHeights[index][ListViewDrawable.UNSELECTED];
                    }
                    break;
            }
        }

        function updateUi() {
            log.debug("updateUi");
            Ui.requestUpdate();
        }

        function up() {
            log.debug("up");
            if (currentItem > 0) {
                scrolling = UP;
            } else {
                switch (wrapStyle) {
                    case WRAP_BOTH:
                        currentItem = model.size() - 1;
                        topItem = currentItem;
                        break;
                    case LEAVE_TITLE:
                        Ui.popView(Ui.SLIDE_DOWN);
                }
            }
            Ui.requestUpdate();
        }

        function down() {
            log.debug("down");
            if (currentItem < model.size() - 1) {
                scrolling = DOWN;
            } else {
                switch (wrapStyle) {
                    case WRAP_BOTH:
                        currentItem = 0;
                        topItem = currentItem;
                }
            }
            Ui.requestUpdate();
        }

        function selectCurrent() {
            log.debug("selectCurrent");
            switch (type) {
                case SINGLE_SELECT:
                    var item = model[currentItem];
                    if (item instanceof String) {
                        callback.invoke(item);  
                    } else {
                        if (item instanceof Lang.Dictionary && item.hasKey(:callback)) {
                            item[:callback].invoke();    
                        } else {
                            callback.invoke(item);
                        }
                    }
                    break;
                case MULTI_SELECT:
                    model[currentItem][:selected] = !model[currentItem][:selected];
                    break;
            }
        }
    }

    class ListViewDelegate extends Ui.BehaviorDelegate {
        static var log = getLogger(:ListViewDelegate);
        hidden var view;

        function initialize(view) {
            BehaviorDelegate.initialize();
            self.view = view;
        }

        function onPreviousPage() {
            log.debug("onPreviousPage");
            view.up();
            return true;
        }

        function onNextPage() {
            log.debug("onNextPage");
            view.down();
            return true;
        }

        function onKey(keyEvent) {
            log.debug("onKey");
            log.logVariable("keyEvent", keyEvent);
            if (keyEvent.getKey() == Ui.KEY_DOWN) {
                view.down();
                return true;
            } else if (keyEvent.getKey() == Ui.KEY_UP) {
                view.up();
                return true;
            }
            return false;
        }

        function onSelect() {
            log.debug("onSelect");
            if (!System.getDeviceSettings().isTouchScreen) {
                view.selectCurrent();
            }
            return true;
        }

        function onSwipe(swipeEvent) {
            log.debug("onSwipe");
            var dir = swipeEvent.getDirection();
            if (dir == Ui.SWIPE_DOWN) {
                view.up();
            } else if (dir == Ui.SWIPE_UP) {
                view.down();
            }
            return true;
        }

        function onTap(clickEvent) {
            log.debug("onTap");
            return true;
        }
    }

    class ListViewDrawable extends Ui.Drawable {
        enum { UNSELECTED = 0, SELECTED = 1 }
    
        hidden var model;
        hidden var selected;
        hidden var itemToString;

        function initialize(itemToString) {
            self.itemToString = itemToString;
            Drawable.initialize({});
        }

        function setModel(model) {
            self.model = model;
        }

        function setSelected(selected) {
            self.selected = selected;
        }
    }

    class MenuItemDrawable extends ListViewDrawable {
        static var log = getLogger(:MenuItemDrawable);
        const PADDING = 8;

        function initialize(itemToString) {
            log.debug("initialize");
            ListViewDrawable.initialize(itemToString);
        }

        function calculateHeight(dc) {
            log.debug("calculateHeight");
            var height = Gfx.getFontHeight(FontSize.medium()) + 2 * PADDING;
            return [height, height];
        }
        
        function draw(dc) {
            log.debug("draw");
            var font;
            var color;
            if (selected) {
                font = FontSize.medium();
                color = Gfx.COLOR_WHITE;
            } else {
                font = FontSize.small();
                color = Gfx.COLOR_LT_GRAY;
            }

            height = Gfx.getFontHeight(font) + 2 * PADDING;

            dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
            dc.fillRectangle(locX, locY, width, height);
            dc.setColor(color, Gfx.COLOR_TRANSPARENT);

            if (itemToString != null) {
                dc.drawText(dc.getWidth() / 2, locY + PADDING, font, itemToString.invoke(model), Gfx.TEXT_JUSTIFY_CENTER);
            } else if (model instanceof String) {
                dc.drawText(dc.getWidth() / 2, locY + PADDING, font, model, Gfx.TEXT_JUSTIFY_CENTER);
            } else {
                dc.drawText(dc.getWidth() / 2, locY + PADDING, font, model[:text], Gfx.TEXT_JUSTIFY_CENTER);
            }
        }
    }

    class MenuItemExDrawable extends ListViewDrawable {
        static var log = getLogger(:MenuItemExDrawable);
        const PADDING = 8;
        static var titleCache = {}; 
        static var subTextCache = {}; 

        function initialize(itemToString) {
            log.debug("initialize");
            ListViewDrawable.initialize(itemToString);
        }

        function calculateHeight(dc) {
            log.debug("calculateHeight");
            return drawOrCalc(dc, false);
        }

        function draw(dc) {
            log.debug("draw");
            drawOrCalc(dc, true);
        }

        hidden function drawOrCalc(dc, doDraw) {
            log.debug("drawOrCalc");
            var font = FONT_SIZE.medium();
            var color;
            var bgColor;

            // split title into lines
            var lineHeight = Gfx.getFontHeight(font);
            var title;
            if (itemToString != null) {
                title = itemToString.invoke(model)[0];
            } else if (model instanceof String) {
                title = model;
            } else {
                title = model[:text];
            }
            var lines = titleCache[title];
            if (lines == null) {
                lines = [];
                splitText(title, font, dc, width, lines);
                titleCache[title] = lines;
            }

            // split subText into lines
            var subLines = [];
            var subLineHeight = Gfx.getFontHeight(font - 2);
            var subText;
            if (itemToString != null) {
                subText = itemToString.invoke(model)[1];
            } else {
                subText = model[:subText];
            }
            if (subText != null) {
                subLines = subTextCache[subText];
                if (subLines == null) {
                    subLines = [];
                    splitText(subText, font - 2, dc, width, subLines);
                    subTextCache[subText] = subLines;
                }
            }
 
            height = lineHeight * lines.size() + subLineHeight * subLines.size() + 2 * PADDING;

            if (doDraw) {
                if (selected) {
                    color = Gfx.COLOR_WHITE;
                    bgColor = Gfx.COLOR_BLACK;
                } else {
                    color = Gfx.COLOR_LT_GRAY;
                    bgColor = Gfx.COLOR_DK_GRAY;
                }
                
                dc.setColor(Gfx.COLOR_WHITE, bgColor);
                dc.drawLine(0, locY + height, dc.getWidth(), locY + height);
    
                dc.setColor(color, Gfx.COLOR_TRANSPARENT);
                for (var i = 0; i < lines.size(); i++) {
                    dc.drawText(dc.getWidth() / 2, locY + i * lineHeight + PADDING, font, lines[i], Gfx.TEXT_JUSTIFY_CENTER);
                }
                for (var i = 0; i < subLines.size(); i++) {
                    dc.drawText(dc.getWidth() / 2, locY + lines.size() * lineHeight +i * subLineHeight + PADDING, font - 2, subLines[i], Gfx.TEXT_JUSTIFY_CENTER);
                }
            } 
            return [height, height];
        }
    }
}