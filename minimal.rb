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
    end
    def create
        super
        show(PLACEMENT_SCREEN)
    end
end

#no idea to figure this out it just works:
if __FILE__ == $0
    FXApp.new do |app|
        Example.new(app)
        app.create
        app.run
    end
end