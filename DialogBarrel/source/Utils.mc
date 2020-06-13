using Toybox.Timer;
using Toybox.StringUtil;
using Toybox.Graphics as Gfx;

module DialogBarrel {
    const SCROLL_DELAY = 50;
    const SCROLL_FRACTION_STEPS = 3;

    var scrollTimer = new Timer.Timer();

    const ARROW_PADDING = 7;
    const ARROW_SIZE = 10;

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

    function splitText(text, font, dc, width, lines) {
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
                charArray = chars.slice(startPos, endPos + 1);
                testee = StringUtil.charArrayToString(charArray);
                testeeWidth = dc.getTextWidthInPixels(testee, font);
            } while (testeeWidth < width && lastChar != '\n');
            if (breakAll) {
                lines.add(testee);
            } else if (lastSplit != -1) {
                testee = StringUtil.charArrayToString(chars.slice(startPos, lastSplit));
                lines.add(testee);
                startPos = lastSplit + 1;
                endPos = startPos;
            } else {
                lines.add(testee);
                startPos = endPos;
            }
        } while (!breakAll);
	}
}
