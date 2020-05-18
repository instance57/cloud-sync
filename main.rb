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
            # Make menu bar
    menubar = FXMenuBar.new(self, LAYOUT_FILL_X)
    filemenu = FXMenuPane.new(self)
    FXMenuCommand.new(filemenu, "&Quit", nil, getApp(), FXApp::ID_QUIT)
    FXMenuTitle.new(menubar, "&File", nil, filemenu)
    helpmenu = FXMenuPane.new(self)
    FXMenuTitle.new(menubar, "&Help", nil, helpmenu, LAYOUT_RIGHT)

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