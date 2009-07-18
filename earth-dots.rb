$LOAD_PATH << 'vendor/hpricot/lib'

require 'open-uri'
require 'vendor/hpricot/lib/hpricot'
require 'lib/globe'
require 'lib/seer'
require 'lib/location'

class WorldWide < Processing::App

  load_library 'opengl', 'control_panel'
    
  def setup
    @mouse_sensitivity = 0.03
    @push_back = 0
    @rot_x, @rot_y = 0, 0
    @vel_x, @vel_y = 0, 0
    
    @globe = Globe.new
    @locations = Location::COORDS.map {|pair| Location.new(*pair) }
    
    no_stroke
    smooth
    texture_mode IMAGE
    size(700, 700, OPENGL)
  end
  
  def draw
    background 0
    lights
    push_matrix
    translate width/2, height/2, @push_back
    rotate_x radians(-@rot_x)
    rotate_y radians(270 - @rot_y)
    @globe.draw
    @locations.each {|l| l.draw(@globe.diameter) }
    pop_matrix
    update_position
  end
  
  def key_pressed
    @push_back += 3 if key == '='
    @push_back -= 3 if key == '-'
  end
  
  def update_position
    @rot_x += @vel_x
    @rot_y += @vel_y
    @vel_x *= 0.9
    @vel_y *= 0.9
    if mouse_pressed?
      @vel_x += (mouse_y - pmouse_y) * @mouse_sensitivity
      @vel_y -= (mouse_x - pmouse_x) * @mouse_sensitivity
    end
  end
  
end

WorldWide.new