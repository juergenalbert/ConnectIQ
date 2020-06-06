using Toybox.Application;
using Toybox.WatchUi;
using LogBarrel.Logger as Logger;

class OverPassangerApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
    }

    function onStop(state) {
    }

    function getInitialView() {
    	return [ new Rez.Menus.MainMenu(), new MainMenuDelegate() ];
    }
}

module OverPassanger {
	function logDebug(tag, message) {
		var doLog = Application.getApp().getProperty("LogDebug");
		if (doLog == true) {
			out(Logger.Debug, tag, message);
		}
	}
	
	function logError(tag, message) {
		out(Logger.Error, tag, message);
	}
	
	function logVariable(tag, name, value) {
		var doLog = Application.getApp().getProperty("LogDebug");
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
}

