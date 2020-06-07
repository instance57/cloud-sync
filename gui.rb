require "fox16"
require "yaml"
include Fox

class GUI < FXMainWindow
  def initialize(app)
    whiteList = File.open("whiteList.yml", "r")
    @yamlwhiteListList = YAML.load(whiteList)
    whiteList.close

    @dirlist = Dir.glob("**/*", base: @yamlwhiteListList[0])
    print(@dirlist)

    blackListRam = []
    blackList = File.open("fileBlackList.yml", "r")
    @yamlblackListList = YAML.load(blackList)
    blackList.close

    super(app, "Google Classroom Assignment Downloader", :width => 800, :height => 400) #skapar fönstret med dimitioner

    mainframe = FXVerticalFrame.new(self, :opts => LAYOUT_FILL)

    topframe = FXHorizontalFrame.new(mainframe, :opts => MATRIX_BY_ROWS | LAYOUT_FILL)
    middleframe = FXVerticalFrame.new(mainframe, :opts => MATRIX_BY_ROWS | LAYOUT_FILL)
    bottomframe = FXHorizontalFrame.new(mainframe, :opts => MATRIX_BY_ROWS | LAYOUT_FILL) # creates the frames


     #here i create all widgets like buttons and inputs
    FXButton.new(bottomframe, "Save", :opts => BUTTON_NORMAL) do |button|
      button.connect(SEL_COMMAND, method(:updateLists))
    end
    FXButton.new(bottomframe, "Avsluta", :opts => BUTTON_NORMAL) do |button|
      button.connect(SEL_COMMAND, method(:quit)) 

    end
   
   
    @textfield = FXText.new(middleframe, :opts => LAYOUT_FILL)
 #   here i open whitelist.yml to show it in text ad edit & save it later
    @whiteListData = []
    File.open("whiteList.yml", "r") do |f|
      f.each_line do |line|
        if line != "---\n"
          @whiteListData << line
        end

      end
    end
    
    addPathBtn = FXButton.new(bottomframe, "Add a path", :opts => BUTTON_NORMAL)
    addPathBtn.connect(SEL_COMMAND) do
      dialog = FXDirDialog.new(self, "Select")
      if dialog.execute != 0
        puts dialog.directory
        @whiteListData << dialog.directory
        @textfield.text = @whiteListData.join("\n- ")
      end
    end
    @textfield.text = @whiteListData.join(" ")

    FXButton.new(bottomframe, "End sync", :opts => BUTTON_NORMAL) do |button|
      button.connect(SEL_COMMAND, method(:quit))
    end
    # here i create a table with all listed stuff

    @table = FXTable.new(topframe, :opts => LAYOUT_FILL)
    @table.setTableSize(@dirlist.length, 4)
    @table.tableStyle |= TABLE_COL_SIZABLE

    @table.rowHeaderWidth = 10
    @table.columnHeaderMode = LAYOUT_FIX_HEIGHT
    @table.columnHeaderHeight = 10
    x = 0
    @dirlist.each do |fi|
      @table.setItemText(x, 0, fi, SEL_COMMAND)
      @table.setItemJustify(x, 0, FXTableItem::LEFT)
      @table.setItemJustify(x, 1, FXTableItem::LEFT)
      @table.setItemText(x, 2, "2020-02-23 15:31:23")
      @table.setItemJustify(x, 2, FXTableItem::LEFT)

      if @yamlblackListList.include?(@yamlwhiteListList[0]+"\\"+fi) == false
        @table.setItemText(x, 3, "synced")
        print("checking if ",@yamlblackListList[0]+"\\"+fi," is in ", @yamlblackListList,"\n\n")
      else
        @table.setItemText(x, 3, "unsynced")
      end

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

  def create #grej för att starta gui
    super
    show(PLACEMENT_SCREEN)
  end
  #städa upp och stäng ner programmet
  def quit()
    getApp().exit(0)
  end

  def funcy(sender, sel, ptr) # debug metod till knappar
    puts(sender, sel, ptr)
  end

  #städa upp och stäng ner programmet
  def quit()
    getApp().exit(0)
  end

  def updateLists(sender, sel, ptr)#kör denna när du stänger ner. detta sparar till .yml
    
    File.open("whiteList.yml", "w") do |out|
      YAML.dump(@whiteListData, out)
    end


    blackListSync = { "files" => [] }
    tableY = 0
    @dirlist.each do |objectFile|
      puts(@table.getItemText(tableY, 3)[0])
      if @table.getItemText(tableY, 3)[0] == "u" #checks
        blackListSync["files"] << objectFile
      end
      tableY += 1
    end
    puts(blackListSync)
    File.open("fileBlackList.yml", "w") do |out|
      YAML.dump(blackListSync, out)
    end
  end

#no idea to figure this out, it just works:
if __FILE__ == $0
  FXApp.new do |app1|
    GUI.new(app1)
    app1.create
    app1.run
  end
end
