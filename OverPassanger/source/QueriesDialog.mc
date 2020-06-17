using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Communications;
using Toybox.Application.Storage;
using DialogBarrel as Dialog;
using LogBarrel;

class QueriesDialog {
    var log = LogBarrel.getLogger(:QueriesDialog);
    var searchActive = false;
    var subtitleTag;
    
    function initialize() {
        log.debug(:initialize);
    }
    
    function show(elements) {
        log.debug(:show);
        var options = {
            :title => "POI Queries",
            :type => Dialog.ListView.SINGLE_SELECT,
            :titleStyle => Dialog.ListView.TITLE_MINIMIZE,
            :wrapStyle => Dialog.ListView.WRAP_BOTH,
            :model => elements,
            :callback => method(:selectQuery),
            :cellDrawable => new Dialog.MenuItemExDrawable(method(:itemToString)),
        };
        Dialog.showListView(options);
    }
    
    function itemToString(itemModel) {
        log.debug(:itemToString);
        return [itemModel["name"], itemModel["description"]];
    }
    
    function selectQuery(itemModel) {
        log.debug(:selectQuery);
        var query = itemModel["query"];
        subtitleTag = itemModel["subtitleTag"];
        //var url = "http://www.overpass-api.de/api/interpreter?data=[out:json];" + query + "(48.14,11.64,48.16,11.66);out%20meta;";
        var url = "http://localhost:8080/testquery.json";
    
        Dialog.showProgress("searching...", method(:stopSearch));
        Communications.makeJsonRequest(url, null, null, method(:onResponse));
        searchActive = true;
    }
    
    function stopSearch() {
        log.debug(:stopSearch);
        searchActive = false;
        Communications.cancelAllRequests();
    }
    
    function onResponse(code, data) {
        log.debug("onResponse code:" + code);
        if (searchActive) {
            Ui.popView(Ui.SLIDE_DOWN);
            searchActive = false;
    
            if (code == 200) {
                var elements = data["elements"];
                Storage.setValue("search_result", elements);
    
                new POIDialog().show(elements, subtitleTag);
            } else {
                log.error("code: " + code);
                showError("code: " + code);
            }
        }
    }
}
