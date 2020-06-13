using Toybox.WatchUi as Ui;
using Toybox.PersistedContent;
using Toybox.Communications;
using Toybox.Position;
using Toybox.Application.Storage;
using Toybox.Background;
using OverpassBarrel as Overpass;
using DialogBarrel as Dialog;

class MainMenuDelegate extends Ui.MenuInputDelegate {
    var searchActive = false;

    function logDebug(message) {
        if ($ has :LogBarrel) {
            LogBarrel.logDebug(:MainMenuDelegate, message);
        }
    }

    function logError(message) {
        if ($ has :LogBarrel) {
            LogBarrel.logError(:MainMenuDelegate, message);
        }
    }

    function logVariable(name, value) {
        if ($ has :LogBarrel) {
            LogBarrel.logVariable(:MainMenuDelegate, name, value);
        }
    }

    function initialize() {
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
        logVariable("item", item);
        self.method(item).invoke();
    }

    // for menu2
    function onSelect(item) {
        self.method(item.getId()).invoke();
    }

    // for menu2
    function onWrap(key) {
        logDebug("onWrap");
    }

    function createAppWaypoints() {
        logDebug("createWaypoints");
        for (var i = 0; i < 100; i++) {
            var location = new Position.Location ({
                :latitude => 48.130366 + i * 0.01,
                :longitude => 11.640660 + i * 0.01,
                :format => :degrees
            });
            var options = {
                :name => "Waypoint " + i
            };

            PersistedContent.saveWaypoint(location, options);
            logDebug("Waypoint created: " + options);
        }
    }

    function createWaypoints() {
        logDebug("createWaypoints");
        for (var i = 0; i < 100; i++) {
            var location = new Position.Location ({
                :latitude => 48.130366 + i * 0.01,
                :longitude => 11.640660 + i * 0.01,
                :format => :degrees
            });
            var options = {
                :name => "Waypoint " + i
            };

            PersistedContent.saveWaypoint(location, options);
            logDebug("Waypoint created: " + options);
        }
    }

    function getWaypoints() {
        var iterator = PersistedContent.getWaypoints();
        var waypoint = iterator.next();

        while (waypoint != null) {
            waypoint = iterator.next();
        }
    }

    function getAppWaypoints() {
        var iterator = PersistedContent.getAppWaypoints();
        var waypoint = iterator.next();

        while (waypoint != null) {
            waypoint = iterator.next();
        }
    }

    function deleteWaypoints() {
        var iterator = PersistedContent.getWaypoints();
        var waypoint = iterator.next();

        while (waypoint != null) {
            try {
                waypoint.remove();
            } catch (e) {
                logError(e);
            }
            waypoint = iterator.next();
        }
    }

    function createProperites() {
        for (var i = 0; i < 100; i++) {
            var location = new Position.Location ({
                :latitude => 48.130366 + i * 0.01,
                :longitude => 11.640660 + i * 0.01,
                :format => :degrees
            });
            var options = {
                :name => "Waypoint " + i
            };

            var name = options.get(:name);

            Storage.setValue(name, name);
            logDebug("Waypoint created: " + options);
        }
    }

    function getProperites() {
        var i = 0;
        do {
            var name = "Waypoint " + i;
            var value = Storage.getValue(name);
                if (value == null) {
                break;
            }
            logVariable("Waypoint read: ", value);
            i++;
        } while (true);
    }

    function createIntent() {
        var iterator = PersistedContent.getAppWaypoints();
        var waypoint = iterator.next();

        System.exitTo(waypoint.toIntent());
    }

    function queryOverPass() {
        Overpass.getProxy({
            :result => self.method(:queryOverPassResult),
            :errorDialog => new Toybox.Lang.Method(Dialog, :showError),
        }).query();
    }

    function queryOverPassResult(code, data) {
        logVariable("queryOverPassResult code", code);
        logVariable("queryOverPassResult data", data);
    }

    function queryList() {
        var url = Application.getApp().getProperty("QueriesURL");

        var mySettings = System.getDeviceSettings();
        var phoneConnected = mySettings.phoneConnected;
        if (phoneConnected) {
            Dialog.showProgress("searching...", method(:stopSearch));
            var options = {
                :method => Communications.HTTP_REQUEST_METHOD_GET,
                :headers => {
                   "Content-Type" => Communications.REQUEST_CONTENT_TYPE_JSON
                },
                :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
            };
            Communications.makeJsonRequest(url, null, options, self.method(:onQueriesResponse));
            searchActive = true;
        } else {
            Dialog.showError(Rez.Strings.Offline);
        }
    }

    function stopSearch() {
        logDebug("stopSearch");
        searchActive = false;
        Communications.cancelAllRequests();
    }

    function onQueriesResponse(code, data) {
        logDebug("onQueriesResponse(" + code + ")");

        if (searchActive) {
            Ui.popView(Ui.SLIDE_DOWN);

            if (code == 200) {
                Storage.setValue("queries", data["queries"]);
                pushQueryMenu(data["queries"]);
            } else {
                logError("queryList terminated with " + code);
                var queries = Storage.getValue("queries");
                if (queries == null) {
                    Dialog.showError(Rez.Strings.NoQueries);
                } else {
                    pushQueryMenu(queries);
                }
            }
        }
    }

    function readData() {
        var searchResult = Storage.getValue("search_result");
        logVariable("searchResult", searchResult);
    }

	function listViewTest() {
        var options = {
        	:title => "ListView Test",
        	:type => Dialog.ListView.SINGLE_SELECT,
        	:titleStyle => Dialog.ListView.TITLE_MINIMIZE,
        	:wrapStyle => Dialog.ListView.LEAVE_TITLE,
            :model => [
                {:text => "Verwerfen", :method => method(:dismiss)},
                {:text => "Akzeptieren", :method => method(:accept)},
                {:text => "Verwerfen\nOption 2", :method => method(:dismiss)},
                {:text => "Akzeptieren und lorem ipsum uns so weiter", :method => method(:accept)},
                {:text => "Verwerfen kurz", :method => method(:dismiss)},
                {:text => "Akzeptieren laaaaaaaaaaaaaaaaaaaaaaaaaaaang", :method => method(:accept)},
                {:text => "Verwerfen\ntri\ntra\ntrullala", :method => method(:dismiss)},
                {:text => "Akzeptieren endlich", :method => method(:accept)},
            ],
        	:cellDrawable => new Dialog.MenuItemExDrawable(),
        };
        Dialog.showListView(options);
	}

    function messageTest() {
        var options = {
            :title => "Der Titel ist lang",
            //:text => "Lorem abcdefghijklmnopqrstuvwxyz\nIn Connect IQ 3.1, these are no longer issues thanks to Ui.TextArea and relative coordinates. The Ui.TextArea is a super powered upgrade to Ui.Text.\nLorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.",
            :text => "Lorem abcdefghijklmnopqrstuvwxyz\nIn Connect IQ 3.1, these are no longer issues thanks to Ui.TextArea and relative coordinates.",
            :menu => [
                {:text => "Verwerfen", :method => method(:dismiss)},
                {:text => "Akzeptieren", :method => method(:accept)},
                {:text => "Verwerfen 2", :method => method(:dismiss)},
                {:text => "Akzeptieren 2", :method => method(:accept)},
                {:text => "Verwerfen 3", :method => method(:dismiss)},
                {:text => "Akzeptieren 3", :method => method(:accept)},
                {:text => "Verwerfen 4", :method => method(:dismiss)},
                {:text => "Akzeptieren 4", :method => method(:accept)},
            ]
        };
        Dialog.showMessage(options);
    }

    function dismiss() {
        logDebug("dismiss");
        Ui.popView(Ui.SLIDE_DOWN);
    }

    function accept() {
        logDebug("accept");
        Ui.popView(Ui.SLIDE_DOWN);
    }
}


