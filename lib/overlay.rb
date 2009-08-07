class Overlay
  include Processing::Proxy  
  
  CLOSE_BUTTON_LEFT = 593
  CLOSE_BUTTON_TOP  = 133
  INNER_WIDTH       = 450
  INNER_HEIGHT      = 350
  
  class << self
    attr_accessor :image, :close_button_image
  end
  
  attr_reader :visible
  
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
    @showing_tweets = true
  end
  
  def draw_map_for_quake(quake)
    return unless map = quake.map
    @quake = quake
    draw
    @visible = true
    image_mode Processing::App::CORNER
    factor = map.scale_factor(INNER_WIDTH, INNER_HEIGHT)
    @map_width, @map_height = map.width/factor, map.height/factor
    image map.image, 370 - @map_width/2, 160, @map_width, @map_height
    @showing_map = true
  end
  
  def hide
    @showing_map = false
    @showing_tweets = false
    @visible = false
    @quake.tweets = []
    @quake.map = nil
  end
  
  def detect_mouse_click
    if mouse_inside_close_button?
      hide 
      return true
    end
    return false unless mouse_over?
    @map_clicked_at ||= [0,0]
    if @showing_map && mouse_inside_map? && (mouse_x != @map_clicked_at[0] || mouse_y != @map_clicked_at[1])
      @map_clicked_at = [mouse_x, mouse_y]
      link(@quake.google_news_url) 
      link(@quake.google_map_url) 
    end
    return true
  end
  
  def mouse_inside?
    mouse_inside_close_button? || mouse_inside_map?
  end
  
  def mouse_inside_map?
    @visible && @showing_map && mouse_x > 150 && (mouse_x < 150 + @map_width) && mouse_y > 160 && (mouse_y < 160 + @map_height)
  end
  
  def mouse_inside_close_button?
    @visible && mouse_y > CLOSE_BUTTON_TOP && mouse_y < CLOSE_BUTTON_TOP + @close_button_image.height && mouse_x > CLOSE_BUTTON_LEFT && mouse_x < CLOSE_BUTTON_LEFT + @close_button_image.width
  end
  
  def mouse_over?
    @visible && mouse_y > 135 && mouse_y < 535 && mouse_x > 125 && mouse_x < 625
  end
  
end