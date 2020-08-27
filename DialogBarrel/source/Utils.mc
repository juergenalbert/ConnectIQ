using Toybox.Timer;
using Toybox.StringUtil;
using Toybox.Graphics as Gfx;
using Toybox.WatchUi as Ui;
using Toybox.System as Sys;

module DialogBarrel {
    
    class FontSize { 
        function tiny() {
            return Ui.loadResource(Rez.Strings.TINY).toNumber();
        }
        function small() {
            return Ui.loadResource(Rez.Strings.SMALL).toNumber();
        }
        function medium() {
            return Ui.loadResource(Rez.Strings.MEDIUM).toNumber();
        }
        function large() {
            return Ui.loadResource(Rez.Strings.LARGE).toNumber();
        }
    }
    var FONT_SIZE = new FontSize(); 

    class NullLogger {
        function debug(message) {}
        function error(message) {}
        function logException(exception) {}
        function logVariable(variableName, variable) {}
    }
    
    var scrollTimer = new Timer.Timer();
    var NL = new NullLogger();

    const ARROW_PADDING = 7;
    const ARROW_SIZE = 10;
    const SCROLL_DELAY = 50;
    const SCROLL_FRACTION_STEPS = 3;

    function getLogger(tag) {
        if ($ has :LogBarrel) {
            return LogBarrel.getLogger(tag);
        } else {
            return NL;
        }
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

    function splitText(text, font, dc, width, lines) {
        getLogger(:DialogBarrel).debug("splitText");
        if (text == null) {
            return;
        }
        
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
                charArray = chars.slice(startPos, endPos + 1);
                testee = StringUtil.charArrayToString(charArray);
                if (endPos >= chars.size()) {
                    breakAll = true;
                    break;
                }
                lastChar = chars[endPos];
                if (lastChar == ' ' || lastChar == '\t' || lastChar == '\n') {
                    lastSplit = endPos;
                }
                testeeWidth = dc.getTextWidthInPixels(testee, font);
            } while (testeeWidth < width && lastChar != '\n');
            if (breakAll) {
                if (testee.length() > 0) {
                    lines.add(testee);
                }
            } else if (lastSplit != -1) {
                testee = StringUtil.charArrayToString(chars.slice(startPos, lastSplit));
                lines.add(testee);
                startPos = lastSplit + 1;
                endPos = startPos;
            } else {
                lines.add(testee);
                startPos = endPos + 1;
            }
        } while (!breakAll);
    }
}
