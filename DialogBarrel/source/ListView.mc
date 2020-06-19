using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

module DialogBarrel {
    //var log = getLogger(:DialogBarrel);
    
    function showListView(options) {
        //log.debug(:showListView);
        var listView = new ListView(options);
        var delegate = new ListViewDelegate(listView);
        Ui.pushView(listView, delegate, Ui.SLIDE_UP);
    }

    class ListView extends Ui.View {
        var log = getLogger(:ListView);
    
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
        hidden var modelKeys;
        hidden var itemToString;
        hidden var callback;
        hidden var titleStyle = TITLE_MINIMIZE;
        hidden var wrapStyle = WRAP_NONE;

        hidden var font = Gfx.FONT_SMALL;
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
                        }
                        scrollTimer.start(method(:updateUi), SCROLL_DELAY, false);
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
                        }
                        scrollTimer.start(method(:updateUi), SCROLL_DELAY, false);
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

            cellDrawable.setSize(dc.getWidth() * .9, 0);
            do {
                // entries
                if (model instanceof Array) {
                    cellDrawable.setModel(model[index]);
                } else if (model instanceof Dictionary) {
                    cellDrawable.setModel([modelKeys[index], model[modelKeys[index]]]);
                }
                cellDrawable.setSelected(index == currentItem);
                cellDrawable.setLocation(dc.getWidth() * .05, y + fraction);
                cellDrawable.draw(dc);

                if (index == currentItem) {
                    currentTop = y;
                }

                y += cellDrawable.height;

                index++;
            } while (index < model.size() && y < dc.getHeight());
        }

        function regularTopOfItem(index, dc) {
            if (System.getDeviceSettings().screenShape == System.SCREEN_SHAPE_RECTANGLE/* && dc.getHeight() >= 400*/) {
                return dc.getHeight() * .25;
            } else {
                return (dc.getHeight() - getCellHeight(index, dc)) / 2;
            }
        }
        
        function needScrolling(dc) {
            if (fraction > 0) {
                // we are in scrolling mode, dont calc anything
                return true;
            } else {
                switch (scrolling) {
                    case UP:
                        if (topItem > 0) {
                            return currentTop - getCellHeight(topItem - 1, dc) < regularTopOfItem(0, dc);
                        } else {
                            return false;
                        }
                    case DOWN:       
                        if (currentTop < 0) {
                            currentTop = regularTopOfItem(0, dc);
                        }
                        var y = currentTop;
                        var index = currentItem;
                        do {
                            y += getCellHeight(index, dc);
                            index++;
                        } while (y < dc.getHeight() && index < model.size());
                        return (index < model.size());
                }
            }
        }

        function getCellHeight(index, dc) {
            if (index >= cellHeights.size() || cellHeights[index][0] == 0) {
                while (cellHeights.size() <= index) {
                    cellHeights.add([0, 0]);
                }

                // cell height if selected
                dc.setColor(Gfx.COLOR_TRANSPARENT, Gfx.COLOR_TRANSPARENT);
                cellDrawable.setSize(dc.getWidth() * .9, 0);
                if (model instanceof Array) {
                    cellDrawable.setModel(model[index]);
                } else if (model instanceof Dictionary) {
                    cellDrawable.setModel([modelKeys[index], model[modelKeys[index]]]);
                }
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
            } else {
                switch (wrapStyle) {
                    case WRAP_BOTH:
                        currentItem = model.size() - 1;
                        break;
                    case LEAVE_TITLE:
                        Ui.popView(Ui.SLIDE_DOWN);
                }
            }
            Ui.requestUpdate();
        }

        function down() {
            if (currentItem < model.size() - 1) {
                scrolling = DOWN;
            } else {
                switch (wrapStyle) {
                    case WRAP_BOTH:
                        currentItem = 0;
                        break;
                }
            }
            Ui.requestUpdate();
        }

        function selectCurrent() {
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
        var log = getLogger(:ListViewDelegate);
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
        const PADDING = 8;

        function initialize(itemToString) {
            ListViewDrawable.initialize(itemToString);
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
        const PADDING = 8;

        function initialize(itemToString) {
            ListViewDrawable.initialize(itemToString);
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
            if (itemToString != null) {
                splitText(itemToString.invoke(model)[0], font, dc, width, lines);
            } else if (model instanceof String) {
                splitText(model, font, dc, width, lines);
            } else {
                splitText(model[:text], font, dc, width, lines);
            }

            var subLines = [];
            var subLineHeight = Gfx.getFontHeight(font - 2);
            if (itemToString != null) {
                splitText(itemToString.invoke(model)[1], font - 2, dc, width, subLines);
            } else {
                splitText(model[:subText], font, dc, width, lines);
            }

            height = lineHeight * lines.size() + subLineHeight * subLines.size() + 2 * PADDING;

            dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
            dc.fillRectangle(locX, locY, width, height);
            dc.setColor(color, Gfx.COLOR_TRANSPARENT);

            for (var i = 0; i < lines.size(); i++) {
                dc.drawText(dc.getWidth() / 2, locY + i * lineHeight + PADDING, font, lines[i], Gfx.TEXT_JUSTIFY_CENTER);
            }
            for (var i = 0; i < subLines.size(); i++) {
                dc.drawText(dc.getWidth() / 2, locY + lines.size() * lineHeight +i * subLineHeight + PADDING, font - 2, subLines[i], Gfx.TEXT_JUSTIFY_CENTER);
            }
        }
    }
}