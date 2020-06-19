using Toybox.Time as Time;
using Toybox.Time.Gregorian as Greg;
using Toybox.Lang as Lang;
using Toybox.System as Sys;

module LogBarrel {

    function getLogger(tag) {
        var logDebug = Toybox.Application.getApp().getProperty("LogDebug");
        if (logDebug) {
            return new Logger(tag, 'D', Sys);
        } else {
            return new Logger(tag, 'E', Sys);
        }
    } 

    /*
    function logDebug(tag, message) {
        var doLog = Toybox.Application.getApp().getProperty("LogDebug");
        if (doLog == true) {
            out(Logger.Debug, tag, message);
        }
    }
    
    function logError(tag, message) {
        out(Logger.Error, tag, message);
    }
    
    function logVariable(tag, name, value) {
        var doLog = Toybox.Application.getApp().getProperty("LogDebug");
        if (doLog == true) {
            Logger.Debug.logVariable(tag, name, value);
        }
    }
    
    function out(logger, tag, object) {
        var tagname = tag;
        if (tagname instanceof Toybox.Lang.Symbol) {
            tagname = tagname.toString();
        }
    
        if (object instanceof Toybox.Lang.String) {
            logger.logMessage(tagname, object);
        } else if (object instanceof Toybox.Lang.Symbol) {
            logger.logMessage(tagname, object.toString());
        } else if (object instanceof Toybox.Lang.Exception) {
            logger.logException(tagname, object);
        }
    }
    */

    class Logger {

        private var tag;
        private var logLevel;
        private var logStream;

        function initialize(tag, logLevel, logStream) {
            self.tag = tag.toString();
            self.logLevel = logLevel;
            self.logStream = logStream;
        }

        // The string formats to use when printing log messages
        private const FORMAT_VARIABLE = "$1$=($2$) $3$";
        private const FORMAT_LOG_MESSAGE = "(lmf1)[$1$] {$2$} $3$: $4$";
        private const FORMAT_TIMESTAMP = "$1$-$2$-$3$ $4$:$5$:$6$"; // YYYY-MM-DD HH:MM:SS

        private function formLogMessage(message) {
            // Get a timestamp from the system
            var currentTime = Greg.info(Time.now(), Time.FORMAT_SHORT);
            var timestamp = Lang.format(FORMAT_TIMESTAMP, [
                currentTime.year.format("%04u"),
                currentTime.month.format("%02u"),
                currentTime.day.format("%02u"),
                currentTime.hour.format("%02u"),
                currentTime.min.format("%02u"),
                currentTime.sec.format("%02u")
            ]);

            // Form the log message
            return Lang.format(FORMAT_LOG_MESSAGE, [timestamp, logLevel, tag, message]);
        }

        private function log(message) {
            // Print the log message
            logStream.println(formLogMessage(message));
        }

        private function getVariableType(variable) {
            // If the given value is null we can't switch on it so perform
            // a null check here. The return value should just be "null".
            if (variable == null) {
                return "null";
            }

            // Switch on the type of the variable and return the variable's
            // class name accordingly.
            switch (variable) {
                case instanceof Lang.Array:
                    return "Array";
                case instanceof Lang.Boolean:
                    return "Boolean";
                case instanceof Lang.Char:
                    return "Char";
                case instanceof Lang.Dictionary:
                    return "Dictionary";
                case instanceof Lang.Double:
                    return "Double";
                case instanceof Lang.Exception:
                    return "Exception";
                case instanceof Lang.Float:
                    return "Float";
                case instanceof Lang.Long:
                    return "Long";
                case instanceof Lang.Method:
                    return "Method";
                case instanceof Lang.Number:
                    return "Number";
                case instanceof Lang.String:
                    return "String";
                case instanceof Lang.Symbol:
                    return "Symbol";
                case instanceof Lang.WeakReference:
                    return "WeakReference";
                default:
                    return "Object";
            }
        }

        function debug(message) {
            if (logLevel == 'D') {
                log(message.toString());
            }
        }

        function error(message) {
            if (logLevel == 'D' || logLevel == 'E') {
                log(message.toString());
            }
        }

        function logException(exception) {
            if (logLevel == 'D' || logLevel == 'E') {
                log(exception.getErrorMessage());
                //TODO: Iteratre through stacktrace.
            }
        }

        function logVariable(variableName, variable) {
            if (logLevel == 'D') {
                var type = getVariableType(variable);
                var value;
                if (variable == null) {
                    value = "null";
                } else {
                    value = variable.toString();
                }
                log(Lang.format(FORMAT_VARIABLE, [variableName, type, value]));
            }
        }
    }
}
