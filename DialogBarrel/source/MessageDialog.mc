using Toybox.WatchUi as Ui;
using Toybox.Lang;
using Toybox.Application;
using Toybox.Graphics as Gfx;
using DialogBarrel;

module DialogBarrel {
    function showError(error) {
        var view = new MessageDialogView(toText(Rez.Strings.Error), Gfx.COLOR_RED, toText(error), [{:text => toText(Rez.Strings.OK), :callback => new Toybox.Lang.Method(DialogBarrel, :close)}]);
        Ui.pushView(view, new MessageDialogDelegate(view), Ui.SLIDE_DOWN);
    }

    function showMessage(options) {
        var text = toText(options[:text]);
        var view = new MessageDialogView(options[:title], Gfx.COLOR_BLACK, text, options[:menu]);
        Ui.pushView(view, new MessageDialogDelegate(view), Ui.SLIDE_DOWN);
    }

    function toText(message) {
        if (message instanceof Lang.String) {
            return message;
        } else if (message instanceof Lang.Number) {
            return Ui.loadResource(message);
        } else {
            return message.toString();
        }
    }

    function close() {
        Ui.popView(Ui.SLIDE_DOWN);
    }

    class MessageDialogView extends Ui.View {

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

            bodyText.draw(dc);

            if (bodyText.atStart()) {
                header.setColor(titleColor);
                header.draw(dc);
                headerText.draw(dc);
            } else {
                drawUpArrow(dc, dc.getWidth() / 2, ARROW_PADDING, Gfx.COLOR_BLACK);
            }

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
            var customFont = Ui.loadResource(Rez.Fonts.icons);
            dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_WHITE);
            dc.drawText(40, 40, customFont, "ABC", Graphics.TEXT_JUSTIFY_LEFT);
            */
        }

        function scrollDown() {
            if (bodyText.atEnd()) {
                if (menu.size() == 1) {
                    menu[0][:callback].invoke();
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

        function zoom() {
            bodyText.zoom();
        }

        function openMenu() {
            var menuView;
            menuView = new ListView({
                :title => title,
                :type => ListView.SINGLE_SELECT,
                :titleStyle => ListView.TITLE_MINIMIZE,
                :wrapStyle => ListView.LEAVE_TITLE,
                :model => menu,
                :cellDrawable => new MenuItemDrawable(null),
            });
            var delegate = new ListViewDelegate(menuView);
            Ui.pushView(menuView, delegate, Ui.SLIDE_UP);
        }
    }

    class MessageDialogDelegate extends Ui.BehaviorDelegate {
        var log = getLogger(:MessageDialogDelegate);
        var view;

        function initialize(view) {
            BehaviorDelegate.initialize();
            self.view = view;
        }

        function onMenu() {
            log.debug("onMenu");
            view.openMenu();
            return true;
        }

        function onSelect() {
            log.debug("onSelect");
            if (!System.getDeviceSettings().isTouchScreen) {
                view.zoom();
            }
            return true;
        }

        function onBack() {
            log.debug("onBack");
        }

        function pushDialog() {
            log.debug("pushDialog");
        }

        function onNextPage() {
            log.debug("onNextPage");
            view.scrollDown();
            return true;
        }

        function onPreviousPage() {
            log.debug("onPreviousPage");
            view.scrollUp();
            return true;
        }

        function onKey(keyEvent) {
            log.debug("onKey");
            log.logVariable("keyEvent", keyEvent);
            if (keyEvent.getKey() == Ui.KEY_DOWN) {
                view.scrollDown();
                return true;
            } else if (keyEvent.getKey() == Ui.KEY_UP) {
                view.scrollUp();
                return true;
            }
            return false;
        }

        function onResponse(value) {
            log.debug("onResponse");
        }

        function onTap(clickEvent) {
            log.debug("onTap");
            if (System.getDeviceSettings().isTouchScreen) {
                var ypos = clickEvent.getCoordinates()[1];
                if (ypos < view.bodyText.locY) {
                    view.scrollUp();
                } else if (ypos > view.bodyText.locY + view.bodyText.height) {
                    view.scrollDown();
                } else {
                    view.zoom();
                }
            }
            return true;
        }

        function onSwipe(swipeEvent) {
            log.debug("onSwipe");
            var dir = swipeEvent.getDirection();
            if (dir == Ui.SWIPE_DOWN) {
                view.scrollUp();
            } else if (dir == Ui.SWIPE_UP) {
                view.scrollDown();
            }
            return true;
        }
    }

    class MessageMenuDelegate extends Ui.MenuInputDelegate {
        hidden var menu;

        function initialize(menu) {
            self.menu = menu;
            MenuInputDelegate.initialize();
        }

        function onMenuItem(item) {
            menu[item][:callback].invoke();
        }
    }

    class MessageMenu2Delegate extends Ui.Menu2InputDelegate {
        hidden var menu;

        function initialize(menu) {
            self.menu = menu;
            Menu2InputDelegate.initialize();
        }

        function onSelect(item) {
            var index = item.getId();
            Ui.popView(Ui.SLIDE_DOWN);
            menu[index][:callback].invoke();
        }

        function onWrap(key) {
            log.debug("onWrap");
            if(key == Ui.KEY_UP) {
                Ui.popView(Ui.SLIDE_DOWN);
            }
        }
    }

    class DrawableMenuTitle extends Ui.Drawable {
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

    class Background extends Ui.Drawable {
        var color = Gfx.COLOR_BLACK;

        function initialize(options) {
            Drawable.initialize(options);
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

    class TextArea extends Ui.Drawable {
        var color = Gfx.COLOR_BLACK;
        var text;
        var dcWidth = -1;
        var dcHeight = -1;
        var fontStandard = Gfx.FONT_MEDIUM;
        var font = Gfx.FONT_MEDIUM;
        var lines = [];
        var lineHeight;
        var scrollPos = 0;
        var fraction = 0;
        var numLines;
        var scrolling = NONE;
        var scrollCount;

        enum { NONE, UP, DOWN }

        function initialize(options) {
            Drawable.initialize(options);
            if (options.hasKey(:font)) {
                font = options[:font];
            }
            fontStandard = font;
        }

        function zoom() {
            font++;
            scrollPos *= 1.3;
            if (font == fontStandard + 2) {
                font = fontStandard - 1;
                scrollPos /= 2.1;
            }
            scrollPos = scrollPos.toNumber();
            dcWidth = -1;
            Ui.requestUpdate();
        }

        function draw(dc) {
            if (dc.getWidth() != dcWidth || dc.getHeight() != dcHeight) {
                dcWidth = dc.getWidth();
                dcHeight = dc.getHeight();
                recalculate(dc);
            }

            switch (scrolling) {
                case NONE:
                    fraction = 0;
                    break;
                case UP:
                    fraction += lineHeight; // / SCROLL_FRACTION_STEPS;
                    if (fraction >= lineHeight) {
                        fraction = 0;
                        scrollPos--;
                        scrollCount--;
                        if (scrollCount == 0 || scrollPos == 0) {
                            scrolling = NONE;
                        } else {
                            scrollTimer.start(method(:updateUi), SCROLL_DELAY, false);
                        }
                    } else {
                        scrollTimer.start(method(:updateUi), SCROLL_DELAY, false);
                    }
                    break;
                case DOWN:
                    fraction -= lineHeight; // / SCROLL_FRACTION_STEPS;
                    if (fraction <= -lineHeight) {
                        fraction = 0;
                        scrollPos++;
                        scrollCount--;
                        if (scrollCount == 0 || scrollPos + numLines > lines.size()) {
                            scrolling = NONE;
                        } else {
                            scrollTimer.start(method(:updateUi), SCROLL_DELAY, false);
                        }
                    } else {
                        scrollTimer.start(method(:updateUi), SCROLL_DELAY, false);
                    }
                    break;
            }

            dc.setColor(color, Gfx.COLOR_TRANSPARENT);

            if (dc has :setClip) {
                dc.setClip(locX, locY, width, height);
            }
            for (var i = 0; i < numLines && i < lines.size(); i++ ) {
                if (scrollPos + i < lines.size()) {
                    dc.drawText(locX, locY + lineHeight * i + fraction, font, lines[scrollPos + i], Gfx.TEXT_JUSTIFY_LEFT);
                }
            }
            if (dc has :clearClip) {
                dc.clearClip();
            }
        }

        function updateUi() {
            Ui.requestUpdate();
        }

        function scrollDown() {
            if (scrollPos + numLines <= lines.size()) {
                scrolling = DOWN;
                scrollCount = numLines / 2;
                Ui.requestUpdate();
                return true;
            } else {
                return false;
            }
        }

        function scrollUp() {
            if (scrollPos > 0) {
                scrolling = UP;
                scrollCount = numLines / 2;
                Ui.requestUpdate();
                return true;
            } else {
                return false;
            }
        }

        function atStart() {
            return scrollPos == 0;
        }

        function atEnd() {
            return scrollPos > lines.size() - numLines;
        }

        hidden function recalculate(dc) {
            locX = calc(locX, dc.getWidth());
            locY = calc(locY, dc.getHeight());
            width = calc(width, dc.getWidth());
            height = calc(height, dc.getHeight());
            lines = [];

            var fontDescent = Gfx.getFontDescent(font);
            var fontHeight = Gfx.getFontHeight(font);
            numLines = (height + fontDescent) / fontHeight + 1;
            lineHeight = fontHeight;

            splitText(text, font, dc, width, lines);
        }

        function setColor(color) {
            self.color = color;
        }

        function setText(text) {
            self.text = text;
        }
    }
}

