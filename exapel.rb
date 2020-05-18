require 'fox16'
require "yaml"
include Fox

#aplication = FXApp.new("hi","ruby")
#main = FXMainWindow.new(aplication, "ruby",nil,nil,DECOR_ALL)
#aplication.create()
#main.show(PLACEMENT_SCREEN)
#aplication.run()
class Example < FXMainWindow
    def initialize(app)
        super(app, "Google Classroom Assignment Downloader", :width => 800, :height => 400)#skapar fönstret med dimitioner
        mainframe = FXVerticalFrame.new( self, :opts => LAYOUT_FILL )
        FXButton.new(mainframe, "Mode") do |button|
            button.connect(SEL_COMMAND, method(:funcy))
        end
        

            # table
            whiteList = File.open("whiteList.yml", "r")
            @yamlwhiteListList = YAML.load(whiteList)

            dirlist = Dir.glob( '**/*', base:@yamlwhiteListList[0])
            print(dirlist)

            @table = FXTable.new(mainframe, :opts => LAYOUT_FILL)
            @table.setTableSize(dirlist.length , 4)
            @table.tableStyle |= TABLE_COL_SIZABLE
    
            @table.rowHeaderWidth = 10
            @table.columnHeaderMode = LAYOUT_FIX_HEIGHT
            @table.columnHeaderHeight = 10
            x = 0
            dirlist.each do |fi|
                
                @table.setItemText(x, 0, fi, SEL_COMMAND)
                @table.setItemText(x, 1, "guess_the_number.rb")
                @table.setItemText(x, 2, "2020-02-23 15:31:23")
                whitebutton = FXButton.new(mainframe, "H", :opts => BUTTON_NORMAL | LAYOUT_FILL ) do |button|
                    button.connect(SEL_COMMAND, method(:whiteList))
                end
                x +=1

            end

    
    end
    def create
        super
        show(PLACEMENT_SCREEN)
    end
    def funcy( sender, sel, ptr )
        puts( sender, sel, ptr )
    end
    def whiteList( sender, sel, ptr )
        puts("bep boop added to list", sender, sel, ptr )
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