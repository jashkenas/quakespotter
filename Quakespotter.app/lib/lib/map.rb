class Map
  
  attr_reader :url, :image, :width, :height
  
  def initialize(map_image_url)
    @url    = map_image_url
    @image  = $app.load_image(@url)
    @width  = @image.width
    @height = @image.height
  end
  
  def scale_factor(max_width, max_height)
    scale_x = scale_horizontal?(max_width, max_height)
    scale_x ? @width / max_width.to_f : @height / max_height.to_f
  end
  
  
  private
  
  def scale_horizontal?(max_width, max_height)
    @width > @height && @height < max_height
  end

end