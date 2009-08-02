class ControlStrip
  
  include Processing::Proxy
  
  WIDTH  = 750
  HEIGHT = 120
  
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
      image @buttons, 491, 683, 245, 57
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
    (491..738).include?(mouse_x) && (678..745).include?(mouse_y)
  end
  
  def detect_mouse_over
    cursor HAND if mouse_inside? 
  end
  
  def detect_mouse_click
    return false                  unless mouse_inside?
    return show_map && true       if mouse_x < 491 + 68
    return search_twitter && true if mouse_x < 491 + 170
    return usgs_page && true
  end
  
  def show_map
    $app.scraper.fetch_map($app.selected_quake)
  end
  
  def search_twitter
    $app.scraper.fetch_tweets($app.selected_quake)
  end
  
  def usgs_page
    link($app.selected_quake.url)
  end
  
end