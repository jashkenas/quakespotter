class Overlay
  include Processing::Proxy  
  
  CLOSE_BUTTON_LEFT = 593
  CLOSE_BUTTON_TOP  = 133
  INNER_WIDTH       = 450
  INNER_HEIGHT      = 350
  
  class << self
    attr_accessor :image, :close_button_image
  end
  
  def initialize
    @image = (Overlay.image ||= load_image "images/overlay.png")
    @close_button_image = (Overlay.close_button_image ||= load_image "images/close_button.png")
  end
  
  def draw
    fill 255
    image_mode Processing::App::CORNER
    image @image, Tweet::LEFT, Tweet::TOP, @image.width, @image.height
    image @close_button_image, CLOSE_BUTTON_LEFT, CLOSE_BUTTON_TOP, @close_button_image.width, @close_button_image.height
  end
  
  def draw_tweets_for_quake(quake)
    return if quake.tweets.empty?
    @quake = quake
    draw 
    @visible = true
    @quake.tweets.each_with_index {|tweet, index| tweet.draw(index) }
  end
  
  def draw_map_for_quake(quake)
    return unless map = quake.map
    @quake = quake
    draw
    @visible = true
    image_mode Processing::App::CORNER
    factor = map.scale_factor(INNER_WIDTH, INNER_HEIGHT)
    image map.image, 150, 160, map.width/factor, map.height/factor
  end
  
  def hide
    @visible = false
    @quake.tweets = []
    @quake.map = nil
  end
  
  def detect_mouse_click
    hide if mouse_inside_close_button?
  end
  
  def detect_mouse_over
    cursor HAND if mouse_inside_close_button?
  end
  
  def mouse_inside_close_button?
    @visible && mouse_y > CLOSE_BUTTON_TOP && mouse_y < CLOSE_BUTTON_TOP + @close_button_image.height && mouse_x > CLOSE_BUTTON_LEFT && mouse_x < CLOSE_BUTTON_LEFT + @close_button_image.width
  end
  
  def mouse_over?
    @visible && mouse_y > 135 && mouse_y < 535 && mouse_x > 125 && mouse_x < 625
  end
  
end