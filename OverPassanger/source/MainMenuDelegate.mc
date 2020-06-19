using Toybox.WatchUi as Ui;
using Toybox.PersistedContent;
using Toybox.Communications;
using Toybox.Position;
using Toybox.Application.Storage;
using Toybox.Background;
using OverpassBarrel as Overpass;
using DialogBarrel as Dialog;
using LogBarrel;

class MainMenuDelegate extends Ui.MenuInputDelegate {
    var log = LogBarrel.getLogger(:MainMenuDelegate);
    var searchActive = false;

    function initialize() {
        log.debug(:initialize);
        MenuInputDelegate.initialize();
    }

    function onMenuItem(item) {
        log.debug(:onMenuItem);
        self.method(item).invoke();
    }

    /*
    // for menu2
    function onSelect(item) {
        self.method(item.getId()).invoke();
    }

    // for menu2
    function onWrap(key) {
        log.debug("onWrap");
    }
    */

    function createAppWaypoints() {
        log.debug("createWaypoints");
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
            log.debug("Waypoint created: " + options);
        }
    }

    function createWaypoints() {
        log.debug("createWaypoints");
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
            log.debug("Waypoint created: " + options);
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
            log.debug("Waypoint created: " + options);
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
            log.logVariable("Waypoint read: ", value);
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
        log.logVariable("queryOverPassResult code", code);
        log.logVariable("queryOverPassResult data", data);
    }

    function queryList() {
        log.debug("queryList");
        var url = Application.getApp().getProperty("QueriesURL");

        var mySettings = System.getDeviceSettings();
        var phoneConnected = mySettings.phoneConnected;
        if (phoneConnected) {
            Dialog.showProgress("searching...", method(:stopSearch));
            var options = {
                :callback => Communications.HTTP_REQUEST_METHOD_GET,
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
        log.debug("stopSearch");
        searchActive = false;
        Communications.cancelAllRequests();
    }

    function onQueriesResponse(code, data) {
        log.debug("onQueriesResponse(" + code + ")");

        if (searchActive) {
            Ui.popView(Ui.SLIDE_DOWN);

            if (code == 200) {
                Storage.setValue("queries", data["queries"]);
                new QueriesDialog().show(data["queries"]);
            } else {
                logError("queryList terminated with " + code);
                var queries = Storage.getValue("queries");
                if (queries == null) {
                    Dialog.showError(Rez.Strings.NoQueries);
                } else {
                    new QueriesDialog().show(queries);
                }
            }
        }
    }

    function readData() {
        var searchResult = Storage.getValue("search_result");
        log.logVariable("searchResult", searchResult);
    }

    function listViewTest() {
        var options = {
            :title => "ListView Test",
            :type => Dialog.ListView.SINGLE_SELECT,
            :titleStyle => Dialog.ListView.TITLE_MINIMIZE,
            :wrapStyle => Dialog.ListView.WRAP_NONE,
            :model => [
                {:text => "Verwerfen", :callback => method(:dismiss)},
                {:text => "Akzeptieren", :callback => method(:accept)},
                {:text => "Verwerfen\nOption 2", :callback => method(:dismiss)},
                {:text => "Akzeptieren und lorem ipsum uns so weiter", :callback => method(:accept)},
                {:text => "Verwerfen kurz", :callback => method(:dismiss)},
                {:text => "Akzeptieren laaaaaaaaaaaaaaaaaaaaaaaaaaaang", :callback => method(:accept)},
                {:text => "Verwerfen\ntri\ntra\ntrullala", :callback => method(:dismiss)},
                {:text => "Akzeptieren endlich", :callback => method(:accept)},
            ],
            :cellDrawable => new Dialog.MenuItemExDrawable(null),
        };
        Dialog.showListView(options);
    }

    function messageTest() {
        var options = {
            :title => "Der Titel ist lang",
            //:text => "Lorem abcdefghijklmnopqrstuvwxyz\nIn Connect IQ 3.1, these are no longer issues thanks to Ui.TextArea and relative coordinates. The Ui.TextArea is a super powered upgrade to Ui.Text.\nLorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet.",
            :text => "Lorem abcdefghijklmnopqrstuvwxyz\nIn Connect IQ 3.1, these are no longer issues thanks to Ui.TextArea and relative coordinates.",
            :menu => [
                {:text => "Verwerfen", :callback => method(:dismissAndClose)},
                {:text => "Akzeptieren", :callback => method(:dismissAndClose)},
            ]
        };
        Dialog.showMessage(options);
    }

    function dismissAndClose() {
        log.debug("dismiss");
        Ui.popView(Ui.SLIDE_DOWN);
        Ui.popView(Ui.SLIDE_DOWN);
    }

    function acceptAndClose() {
        log.debug("accept");
        Ui.popView(Ui.SLIDE_DOWN);
        Ui.popView(Ui.SLIDE_DOWN);
    }

    function dismiss() {
        log.debug("dismiss");
    }

    function accept() {
        log.debug("accept");
    }
}


