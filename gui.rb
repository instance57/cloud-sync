require "fox16"
require "yaml"
include Fox

#aplication = FXApp.new("hi","ruby")
#main = FXMainWindow.new(aplication, "ruby",nil,nil,DECOR_ALL)
#aplication.create()
#main.show(PLACEMENT_SCREEN)
#aplication.run()
class GUI < FXMainWindow
  def initialize(app)
    whiteList = File.open("whiteList.yml", "r")
    @yamlwhiteListList = YAML.load(whiteList)

    @dirlist = Dir.glob("**/*", base: @yamlwhiteListList[0])
    print(@dirlist)

    super(app, "Google Classroom Assignment Downloader", :width => 800, :height => 400) #skapar fönstret med dimitioner

    mainframe = FXVerticalFrame.new(self, :opts => LAYOUT_FILL)
    topframe = FXHorizontalFrame.new(mainframe, :opts => MATRIX_BY_ROWS | LAYOUT_FILL)
    bottomframe = FXVerticalFrame.new(mainframe, :opts => MATRIX_BY_ROWS | LAYOUT_FILL)
    leftframe = FXVerticalFrame.new(topframe, :opts => LAYOUT_FILL)
    rightframe = FXVerticalFrame.new(topframe) #, 1, :opts => LAYOUT_FILL ,:width => 50, :height => 2) #osäker på vad siffran gör men om du tar bort den förstörs det.

    FXButton.new(rightframe, "end sync",:opts => BUTTON_NORMAL | LAYOUT_FILL   ) do |button|
      button.connect(SEL_COMMAND, method(:funcy))
    end
    FXButton.new(rightframe, "save", :opts => BUTTON_NORMAL | LAYOUT_FILL) do |button|
      button.connect(SEL_COMMAND, method(:updateLists))
    end
    FXButton.new(bottomframe, "add a path") do |button|
      button.connect(SEL_COMMAND, method(:funcy))
    end
    @textfeild = FXTextField.new(bottomframe, 20, :opts =>LAYOUT_FILL)

    # table

    @table = FXTable.new(leftframe, :opts => LAYOUT_FILL)
    @table.setTableSize(@dirlist.length, 4)
    @table.tableStyle |= TABLE_COL_SIZABLE

    @table.rowHeaderWidth = 10
    @table.columnHeaderMode = LAYOUT_FIX_HEIGHT
    @table.columnHeaderHeight = 10
    x = 0
    @dirlist.each do |fi|
      @table.setItemText(x, 0, fi, SEL_COMMAND)
      @table.setItemJustify(x, 0, FXTableItem::LEFT)
      @table.setItemText(x, 1, "Synced")
      @table.setItemJustify(x, 1, FXTableItem::LEFT)
      @table.setItemText(x, 2, "2020-02-23 15:31:23")
      @table.setItemJustify(x, 2, FXTableItem::LEFT)
      @table.setItemText(x, 3, "synced")
      @table.setItemJustify(x, 3, FXTableItem::LEFT)

      @table.connect(SEL_COMMAND) do |sender, sel, data|
        if sender.anchorColumn == 3
          textcontent = @table.getItemText(sender.anchorRow, sender.anchorColumn)
          puts "anchor row, col = #{sender.anchorRow}, #{sender.anchorColumn}, #{textcontent}"
          if textcontent == "synced"
            @table.setItemText(sender.anchorRow, sender.anchorColumn, "unsynced")
          else
            @table.setItemText(sender.anchorRow, sender.anchorColumn, "synced")
          end
        end
      end
      #whitebutton = FXButton.new(rightframe, fi.split[-1], :height => 2  , :opts => BUTTON_NORMAL | LAYOUT_FILL ) do |button|
      #    button.connect(SEL_COMMAND, method(:whiteList))
      #end
      x += 1
    end
  end

  def create
    super
    show(PLACEMENT_SCREEN)
  end

  def funcy(sender, sel, ptr)
    puts(sender, sel, ptr)
  end
  def updateLists(sender, sel, ptr)
    #UPDATE WHITE LIST
    blackListSync = {}
    tableY = 1
    @dirlist.each do |objectFile|
      blackListSync[:objectFile] = @table.getItemData(2,3)
    end
    puts(blackListSync)

  end

  def whiteList(sender, sel, ptr)
    puts("bep boop added to list", sender, sel, ptr)
  end
end

#no idea to figure this out it just works:
if __FILE__ == $0
  FXApp.new do |app1|
    GUI.new(app1)
    app1.create
    app1.run
  end
end
