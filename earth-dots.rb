$LOAD_PATH << 'vendor/hpricot/lib'

require 'open-uri'
require 'vendor/hpricot/lib/hpricot'
require 'lib/globe'
require 'lib/dot_gov'
require 'lib/location'

class WorldWide < Processing::App

  load_library 'opengl', 'control_panel'
  
  attr_reader :globe, :selected
        
  def setup
    size(700, 700, OPENGL)
    
    @mouse_sensitivity = 0.03
    @push_back = 0
    @rot_x, @rot_y = 0, 0
    @vel_x, @vel_y = 0, 0
    @globe = Globe.new
    @source = DotGov.new
    @locations = @source.earthquakes
    @buffer = create_graphics(width, height, P3D)
    
    no_stroke
    smooth
    texture_mode IMAGE
    ellipse_mode CENTER
  end
  
  def draw
    background 0
    lights
    push_matrix
    translate width/2, height/2, @push_back
    rotate_x radians(-@rot_x)
    rotate_y radians(270 - @rot_y)
    fill 255
    @globe.draw
    @locations.each_with_index {|loc, i| loc.draw(i == @selected) }
    pop_matrix
    update_position
  end
  
  def mouse_pressed
    @buffer.begin_draw
    @buffer.background 255
    @buffer.no_stroke
    @buffer.translate width/2, height/2, @push_back
    @buffer.rotate_x radians(-@rot_x)
    @buffer.rotate_y radians(270 - @rot_y)
    @locations.each_with_index {|l, i| l.draw_for_picking(i, @buffer) }
    @selected = red(@buffer.get(mouse_x, mouse_y)).to_i
    @buffer.end_draw
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