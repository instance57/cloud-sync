require 'fox16'

include Fox

aplication = FXApp.new("hi","ruby")
main = FXMainWindow.new(aplication, "ruby",nil,nil,DECOR_ALL)
aplication.create()
main.show(PLACEMENT_SCREEN)
aplication.run()