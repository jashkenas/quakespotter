$LOAD_PATH << 'vendor/hpricot/lib'

require 'open-uri'
require 'vendor/hpricot/lib/hpricot'
require 'lib/globe'
require 'lib/scraper'
require 'lib/quake'
require 'lib/overlay'
require 'lib/control_strip'
require 'lib/status'
require 'lib/tweet'
require 'lib/map'

class WorldWide < Processing::App

  load_library 'opengl'
  
  attr_reader :globe, :quakes, :selected, :status, :scraper, :controls, :overlay
        
  def setup
    size(750, 750, OPENGL)
    
    @mouse_sensitivity = 0.03
    @push_up, @push_back = 30, 0
    @rot_x, @rot_y = 25, 270 # Center on the ol' US of A.
    @vel_x, @vel_y = 0, 0
    
    @globe     = Globe.new
    @scraper   = Scraper.new
    @status    = Status.new
    @controls  = ControlStrip.new
    @overlay   = Overlay.new
    @starfield = load_image "images/starfield.png"
    @buffer    = create_graphics(width, height, P3D)
    @quakes    = []
    
    Thread.new { @quakes = @scraper.earthquakes }
    
    no_stroke
    texture_mode IMAGE
    ellipse_mode CENTER
    text_font    load_font('fonts/AkzidenzGrotesk-Bold-14.vlw')
  end
  
  def draw
    hint ENABLE_DEPTH_TEST
    background 0
    image @starfield, 0, 0, width, height
    fill 255
    lights
    image_mode CENTER
    push_matrix
    translate width/2, height/2 - @push_up, @push_back
    rotate_x radians(-@rot_x)
    rotate_y radians(270 - @rot_y)
    @globe.check_visibility if position_changed?
    @globe.draw
    hint DISABLE_DEPTH_TEST
    @quakes.each_with_index {|loc, i| loc.draw unless i == @selected }
    selected_quake.draw(true) if selected_quake
    
    pop_matrix
    @status.draw
    @controls.draw
    
    if selected_quake
      @overlay.draw_tweets_for_quake(selected_quake)
      @overlay.draw_map_for_quake(selected_quake)
    end
    
    update_position
    
    cursor ARROW
    @controls.detect_mouse_over 
    @overlay.detect_mouse_over
  end
  
  def selected_quake
    @selected && @quakes[@selected]
  end
  
  def position_changed?
    @rot_x.to_i != @p_rot_x.to_i || @rot_y.to_i != @p_rot_y.to_i
  end
  
  def mouse_pressed
    @overlay.detect_mouse_click
    @controls.detect_mouse_click
    return if @controls.mouse_over? || @overlay.mouse_over?
    @selected = nil
    @buffer.begin_draw
    @buffer.background 255
    @buffer.no_stroke
    @buffer.translate width/2, height/2 - @push_up, @push_back
    @buffer.rotate_x radians(-@rot_x)
    @buffer.rotate_y radians(270 - @rot_y)
    @quakes.each_with_index {|l, i| l.draw_for_picking(i, @buffer) unless l.hidden? }
    result = red(@buffer.get(mouse_x, mouse_y)).to_i
    @selected = result if @quakes[result]
    @buffer.end_draw
  end
  
  def key_pressed
    handle_zoom
    handle_selection
    if key == 'c' && selected_quake
      selected_quake.map = nil
      selected_quake.tweets = []
    end
  end
  
  def handle_zoom
    @push_back += 3 if key == '='
    @push_back -= 3 if key == '-'
  end
  
  def handle_selection
    return unless [37, 39].include? key_code
    if key_code == 37 # left
      @selected -= 1 if @selected
      @selected = @quakes.length - 1 if !selected_quake
    end
    if key_code == 39 # right
      @selected += 1 if @selected
      @selected = 0 if !selected_quake
    end
    @seeking = true
  end
  
  def update_position
    # seek the selected quake
    if @seeking && selected_quake && selected_quake.latitude && selected_quake.longitude
      dx = selected_quake.latitude - @rot_x
      @rot_x += (dx * 0.15) if dx.abs >= 1
      @rot_x = selected_quake.latitude if dx.abs < 1

      dy = selected_quake.longitude - @rot_y
      @rot_y += (dy * 0.15) if dy.abs >= 1
      @rot_y = selected_quake.longitude if dy.abs < 1 
        
      @seeking = false if (dx.abs < 1 && dy.abs < 1)
    else
      @p_rot_x, @p_rot_y = @rot_x, @rot_y
      @rot_x += @vel_x
      @rot_y += @vel_y
      @vel_x *= 0.9
      @vel_y *= 0.9
    end
    if mouse_pressed? && !@controls.mouse_over? && !@overlay.mouse_over?
      @seeking = false
      @vel_x += (mouse_y - pmouse_y) * @mouse_sensitivity
      @vel_y -= (mouse_x - pmouse_x) * @mouse_sensitivity
    end
  end
  
end

WorldWide.new