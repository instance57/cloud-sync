require 'fox16'

include Fox

#aplication = FXApp.new("hi","ruby")
#main = FXMainWindow.new(aplication, "ruby",nil,nil,DECOR_ALL)
#aplication.create()
#main.show(PLACEMENT_SCREEN)
#aplication.run()
class Example < FXMainWindow
    def initialize(app)
        super(app, "Google Classroom Assignment Downloader")#skapar fönstret med dimitioner
        mainframe = FXVerticalFrame.new( self, :opts => LAYOUT_FILL )
        @table = FXTable.new(mainframe, :opts => LAYOUT_FILL)
        @table.setTableSize(4, 4)
        @table.tableStyle |= TABLE_COL_SIZABLE

        @table.rowHeaderWidth = 10
        @table.columnHeaderMode = LAYOUT_FIX_HEIGHT
        @table.columnHeaderHeight = 10
        hour_button = FXButton.new(@table.setItem(0,0,), "H", :opts => BUTTON_NORMAL | LAYOUT_FILL ) do |button|
            button.connect(SEL_COMMAND, method(:on_hour_button_clicked))
        end

    end
    def on_hour_button_clicked( sender, sel, ptr )
        print("beep boop added file to whitelist", sender, sel, ptr )
    end
    def create
        super
        show(PLACEMENT_SCREEN)
    end
end

#no idea to figure this out it just works:
if __FILE__ == $0
    FXApp.new do |app1|
        Example.new(app1)
        app1.create
        app1.run
    end
end