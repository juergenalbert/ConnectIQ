using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Position;
using DialogBarrel as Dialog;

class POIDialog {
    var log = LogBarrel.getLogger(:POIDialog); 
    var subtitleTag;

    function show(elements, subtitleTag) {
        log.debug(:show);
        self.subtitleTag = subtitleTag;
        var options = {
            :title => "POIs",
            :type => Dialog.ListView.SINGLE_SELECT,
            :titleStyle => Dialog.ListView.TITLE_MINIMIZE,
            :wrapStyle => Dialog.ListView.WRAP_BOTH,
            :model => elements,
            :callback => method(:selectPOI),
            :cellDrawable => new Dialog.MenuItemExDrawable(method(:itemToString)),
        };
        Dialog.showListView(options);
    }
    
    function itemToString(itemModel) {
        if (subtitleTag != null) {
            return [itemModel["tags"]["name"], itemModel["tags"][subtitleTag]];
        } else {
            return [itemModel["tags"]["name"], null];
        }
    }
    
    function selectPOI(itemModel) {
        log.debug(:selectPOI);
        var options = {
            :title => "Tags",
            :type => Dialog.ListView.SINGLE_SELECT,
            :titleStyle => Dialog.ListView.TITLE_MINIMIZE,
            :wrapStyle => Dialog.ListView.WRAP_BOTH,
            :model => itemModel["tags"],
            :cellDrawable => new Dialog.MenuItemExDrawable(method(:poiToString)),
        };
        Dialog.showListView(options);
    }
    
    function poiToString(itemModel) {
        return [itemModel[0], itemModel[1]];
    }
}   
