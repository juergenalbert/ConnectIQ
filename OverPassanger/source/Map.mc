using Toybox.WatchUi as Ui;
using Toybox.Position as Position;
using Toybox.Graphics as Gfx;

class OverPassangerMapView extends Ui.MapTrackView {

    function initialize() {
        MapTrackView.initialize();

        // set the current mode for the Map to be preview
        setMapMode(Ui.MAP_MODE_PREVIEW);

		/*
        // create a new polyline
        var polyline = new Ui.MapPolyline();

        // set the color of the line
        polyline.setColor(Gfx.COLOR_RED);

        // set width of the line
        polyline.setWidth(2);

        // add locations to the polyline
        polyline.addLocation(new Position.Location({:latitude => 48.13391, :longitude =>11.64630, :format => :degrees}));
        polyline.addLocation(new Position.Location({:latitude => 48.13465, :longitude =>11.64922, :format => :degrees}));
        polyline.addLocation(new Position.Location({:latitude => 48.13508, :longitude =>11.64959, :format => :degrees}));
        polyline.addLocation(new Position.Location({:latitude => 48.13557, :longitude =>11.64864, :format => :degrees}));
        polyline.addLocation(new Position.Location({:latitude => 48.13629, :longitude =>11.64882, :format => :degrees}));
        polyline.addLocation(new Position.Location({:latitude => 48.13583, :longitude =>11.64942, :format => :degrees}));
        polyline.addLocation(new Position.Location({:latitude => 48.13695, :longitude =>11.65051, :format => :degrees}));

        // add the polyline to the Map
        MapView.setPolyline(polyline);
        */

        // create map markers array
        var map_markers = [];

        // create a map marker at a location on the map
        var marker = new Ui.MapMarker(new Position.Location({:latitude => 48.13391, :longitude =>11.64630, :format => :degrees}));
        marker.setIcon(Ui.loadResource(Rez.Drawables.MapPin), 12, 24);
        marker.setLabel("Custom Icon");
        map_markers.add(marker);

        marker = new Ui.MapMarker(new Position.Location({:latitude => 48.13557, :longitude =>11.64864, :format => :degrees}));
        marker.setIcon(Ui.loadResource(Rez.Drawables.MapPin), 12, 24);
        marker.setLabel("Custom Icon");
        map_markers.add(marker);

        marker = new Ui.MapMarker(new Position.Location({:latitude => 48.13508, :longitude =>11.64959, :format => :degrees}));
        marker.setIcon(Ui.MAP_MARKER_ICON_PIN, 0, 0);
        marker.setLabel("Predefined Icon");
        map_markers.add(marker);

        // add map markers to the Map
        MapView.setMapMarker(map_markers);

        // create the bounding box for the map area
        var top_left = new Position.Location({:latitude => 48.13695, :longitude =>11.65051, :format => :degrees});
        var bottom_right = new Position.Location({:latitude => 48.13391, :longitude =>11.6463, :format => :degrees});
        MapView.setMapVisibleArea(top_left, bottom_right);

        // set the bound box for the screen area to focus the map on
		MapView.setScreenVisibleArea(0, 0, System.getDeviceSettings().screenWidth, System.getDeviceSettings().screenHeight / 2);
    }

    // Load your resources here
    function onLayout(dc) {
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() {
    }

    // Update the view
    function onUpdate(dc) {
        // Call the parent onUpdate function to redraw the layout
        MapView.onUpdate(dc);
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
        dc.drawText(
                    dc.getWidth() / 2,                      // gets the width of the device and divides by 2
                    dc.getHeight() / 2,                     // gets the height of the device and divides by 2
                    Gfx.FONT_LARGE,                    // sets the font size
                    "Hello World",                          // the String to display
                    Gfx.TEXT_JUSTIFY_CENTER            // sets the justification for the text
                  );
    }
}

class OverPassangerMapDelegate extends Ui.BehaviorDelegate {

    var mView;

    function initialize(view) {
        BehaviorDelegate.initialize();
        mView = view;
    }

    function onBack() {
        // if current mode is preview mode them pop the view
        if(mView.getMapMode() == Ui.MAP_MODE_PREVIEW) {
            Ui.popView(Ui.SLIDE_UP);
        } else {
            // if browse mode change the mode to preview
            mView.setMapMode(Ui.MAP_MODE_PREVIEW);
        }
        return true;
    }

    function onSelect() {
        // on enter button press chenage the map view to browse mode
        mView.setMapMode(Ui.MAP_MODE_BROWSE);
        return true;
    }
}
