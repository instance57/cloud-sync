require 'fox16'

include Fox

class ComboBoxExample < FXMainWindow

    def initialize(app)
        super(app, "Google Classroom Assignment Downloader")

        target_dir_textfield = FXTextField.new(self, 20)
    end

    def create
        super
        show(PLACEMENT_SCREEN)


    end
end

ComboBoxExample.new(FXApp.new("hi","ruby"))
app.create
app.run