using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;

module DialogBarrel {
    class MenuView extends Ui.View {
        hidden var lineHeight; 
        hidden var title;
    
        function initialize(options) {
            View.initialize();
            lineHeight = Gfx.getFontHeight(Gfx.FONT_MEDIUM);
            title = options[:title];
        }
        
        /*
        function onLayout(dc) {
            var layout = DialogBarrel.Rez.Layouts.MenuLayout(dc);
        }
        */
        
        function onUpdate(dc) {
            dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
            dc.clear();
        
            dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_WHITE);
            dc.fillRectangle(0, 0, dc.getWidth(), lineHeight * 2);
        }
    }
    
    class MenuViewDelegate extends Ui.InputDelegate {
        hidden var view;
    
        function initialize(view) {
            InputDelegate.initialize();
            self.view = view;
        }
    
    }
}