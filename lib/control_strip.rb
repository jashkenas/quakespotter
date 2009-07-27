class ControlStrip
  
  include Processing::Proxy
  
  WIDTH  = 750
  HEIGHT = 120
  
  def initialize
    @background = load_image 'images/control_strip.png'
    @buffer = $app.buffer(WIDTH, HEIGHT, JAVA2D) do |b|
      b.image @background, 0, 0, WIDTH, HEIGHT
    end
  end
  
  def draw
    image_mode CORNER
    image @buffer, 0, height - HEIGHT, WIDTH, HEIGHT
    
    fill 255
    text("#{frame_rate.to_i} FPS", 14, height-100)
    
    fill 40
    quake = $app.selected_quake
    text quake.info, 15, height-50 if quake
  end
  
end