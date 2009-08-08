class ControlStrip
  
  include Processing::Proxy
  
  WIDTH  = 750
  HEIGHT = 120
  LEFT_EDGE = 398
  
  RED_CROSS_DONATION_URL = 'http://american.redcross.org/site/Donation2'
  
  def initialize
    @background = load_image 'images/control_strip.png'
    @logo       = load_image 'images/logo.png'
    @buttons    = load_image 'images/buttons.png'
    @lw, @lh, @bw, @bh = @logo.width, @logo.height, @buttons.width, @buttons.height
  end
  
  def draw
    image_mode CORNER
    image @background, 0, height - HEIGHT, WIDTH, HEIGHT
    quake = $app.selected_quake
    if quake
      image @buttons, LEFT_EDGE, 683, 338, 57
      fill 40
      text quake.info, 15, height-50
    else 
      image @logo, 8, 681, @lw, @lh
    end
  end
  
  def mouse_over?
    mouse_y > 678
  end
  
  def mouse_inside?
    return false unless $app.selected_quake
    (LEFT_EDGE..738).include?(mouse_x) && (678..745).include?(mouse_y)
  end
  
  def detect_mouse_click
    return false                  unless mouse_inside?
    return show_map && true       if mouse_x < LEFT_EDGE + 68
    return search_twitter && true if mouse_x < LEFT_EDGE + 170
    return usgs_page && true      if mouse_x < LEFT_EDGE + 255
    return red_cross_donation && true
  end
  
  def show_map
    $app.scraper.fetch_map($app.selected_quake)
  end
  
  def search_twitter
    $app.scraper.fetch_tweets($app.selected_quake)
  end
  
  def usgs_page
    link $app.selected_quake.url
  end
  
  def red_cross_donation
    link RED_CROSS_DONATION_URL
  end
  
end