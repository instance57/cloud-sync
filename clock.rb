  
require 'fox16'
include Fox
# require 'eventmachine'
#require 'em/pure_ruby'

class ClockModel
    
    attr_reader :alarm_on
    attr_writer :alarm_on
    
    def initialize( clock_view, app )
        @clock_view = clock_view
        @app = app
        @alarm_time = { :hour => 0, :minute => 0 }
        @alarm_on = false
        clock_updater_thread
    end
    
    def clock_updater_thread
        Thread.new do               # 100ms resolution timer informs view on every second elapsed
            EM.run do
                previous_epoch = Time.now.to_i
                EM.add_periodic_timer(0.1) do
                    time_now = Time.now
                    if previous_epoch != time_now.to_i
                        update_clock_view
                        previous_epoch = time_now.to_i
                    end
                end
            end
        end
    end
    
    def get_current_time_as_string                  # method called from view to get model state
        return Time.now.strftime( "%H:%M:%S" )
    end
    
    def get_alarm_time_as_string                    # method called from view to get model state
        hour = @alarm_time[:hour].to_s.rjust( 2, "0" )
        minute = @alarm_time[:minute].to_s.rjust( 2, "0" )
        return hour + ":" + minute
    end
    
    def update_clock_view                           # inform view that model has changed
        @app.runOnUiThread do                       # GUI updates must run in UI-thread!
            @clock_view.update_time_display
        end
    end
    
    def alarm_increment_hour
        @alarm_time[:hour] = ( @alarm_time[:hour] + 1 ) % 24
        update_clock_view
    end
    
    def alarm_increment_minute
        @alarm_time[:minute] = ( @alarm_time[:minute] + 1 ) % 60
        update_clock_view
    end
    
end

module ClockModes
    MODE_SHOW_TIME = 0
    MODE_SET_ALARM = 1
end

class ClockController
    include ClockModes
    
    attr_reader :mode
    attr_reader :clock_model
    
    def initialize
        @mode = ClockModes::MODE_SHOW_TIME
        @clock_model = nil
    end
    
    def attach_model( clock_model )
        @clock_model = clock_model
    end
    
    def change_mode( mode )
        @mode = mode
        @clock_model.update_clock_view if @clock_model
    end
    
    def alarm_increment_hour
        @clock_model.alarm_increment_hour if @clock_model
    end
    
    def alarm_increment_minute
        @clock_model.alarm_increment_minute if @clock_model
    end
    
end


class ClockView < FXMainWindow
    
    def initialize( app, clock_controller )
        @clock_controller = clock_controller
        
        super(app, "MVC Clock - MVC Demo Application", :width => 500, :height => 120)
        @status_bar = FXStatusBar.new(self, :opts => LAYOUT_SIDE_BOTTOM|LAYOUT_FILL_X )
        @status_bar.statusLine.normalText = "Alarm off"
        
        h_frame = FXHorizontalFrame.new( self, :padding => 0, :opts => LAYOUT_FILL )
        matrix = FXMatrix.new( h_frame, 3, MATRIX_BY_COLUMNS | LAYOUT_FILL )
        
        left_button_matrix = FXMatrix.new( matrix, 2, MATRIX_BY_ROWS | LAYOUT_FILL )
        
        mode_button = FXButton.new( left_button_matrix, "Mode", :opts => BUTTON_NORMAL | LAYOUT_FILL ) do |button|
            button.connect(SEL_COMMAND, method(:on_mode_button_clicked))
        end
        
        @toggle_alarm_button = FXButton.new( left_button_matrix, "Toggle alarm", :opts => BUTTON_NORMAL | LAYOUT_FILL ) do |button|
            button.connect(SEL_COMMAND, method(:on_toggle_alarm_button_clicked))
        end
        
        @clock_value = FXLabel.new( matrix, "", :padTop => 10 )
        clock_font = FXFont.new( app, "consolas", 48 )
        @clock_value.font = clock_font
        
        @right_button_matrix = FXMatrix.new( matrix, 3, MATRIX_BY_ROWS | LAYOUT_FILL )
        @right_button_matrix.visible = false
        
        hour_button = FXButton.new( @right_button_matrix, "H", :opts => BUTTON_NORMAL | LAYOUT_FILL ) do |button|
            button.connect(SEL_COMMAND, method(:on_hour_button_clicked))
        end
        
        minute_button = FXButton.new( @right_button_matrix, "M", :opts => BUTTON_NORMAL | LAYOUT_FILL ) do |button|
            button.connect(SEL_COMMAND, method(:on_minute_button_clicked))
        end
        
        set_alarm_button = FXButton.new( @right_button_matrix, "Set", :opts => BUTTON_NORMAL | LAYOUT_FILL ) do |button|
            button.connect(SEL_COMMAND, method(:on_set_alarm_button_clicked))
        end
        
    end
    
    def on_mode_button_clicked( sender, sel, ptr )
        case @clock_controller.mode
        when ClockController::MODE_SHOW_TIME
            @clock_controller.change_mode( ClockController::MODE_SET_ALARM )
        when ClockController::MODE_SET_ALARM
            @clock_controller.change_mode( ClockController::MODE_SHOW_TIME )
        end
        update_status_line
        @toggle_alarm_button.enabled = !@toggle_alarm_button.enabled
        @right_button_matrix.visible = !@right_button_matrix.visible?
        self.repaint
    end

    def on_toggle_alarm_button_clicked( sender, sel, ptr )
        @clock_controller.clock_model.alarm_on = !@clock_controller.clock_model.alarm_on
        update_status_line
    end
    
    def on_hour_button_clicked( sender, sel, ptr )
        @clock_controller.alarm_increment_hour
    end
    
    def on_minute_button_clicked( sender, sel, ptr )
        @clock_controller.alarm_increment_minute
    end

    def on_set_alarm_button_clicked( sender, sel, ptr )
        @clock_controller.clock_model.alarm_on = true
        @right_button_matrix.visible = false
        @toggle_alarm_button.enabled = true
        @clock_controller.change_mode( ClockController::MODE_SHOW_TIME )
        update_status_line
    end
    
    def update_status_line
        status_line = ""
        case @clock_controller.mode
        when ClockController::MODE_SET_ALARM    
            status_line = "Set alarm"
        when ClockController::MODE_SHOW_TIME
            if @clock_controller.clock_model.alarm_on
                status_line = "Alarm on: #{@clock_controller.clock_model.get_alarm_time_as_string}"
                @status_bar.statusLine.normalText = status_line
            else
                status_line = "Alarm off"
            end
        end
        @status_bar.statusLine.normalText = status_line
    end

    def update_time_display
        case @clock_controller.mode
        when ClockController::MODE_SHOW_TIME
            @clock_value.text = @clock_controller.clock_model.get_current_time_as_string
        when ClockController::MODE_SET_ALARM
            @clock_value.text = "   " + @clock_controller.clock_model.get_alarm_time_as_string
        end
        @clock_value.repaint
    end
    
    def create
        super
        show(PLACEMENT_SCREEN)
    end
end

if __FILE__ == $0
    FXApp.new do |app|
        clock_controller = ClockController.new
        clock_view = ClockView.new(app, clock_controller)
        clock_model = ClockModel.new( clock_view, app )
        clock_controller.attach_model( clock_model )
        app.create
        app.run
    end
end