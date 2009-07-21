# Plotting longitude and latitude on a globe: 
# x = r * cos(lat) * sin(long)
# y = r * sin(lat)
# z = r * cos(lat) * cos(long)
# where r is radius, lat is latitude and long is longitude

class Location
  
  class << self
    attr_accessor :epicenter, :epicenter_selected
  end
  
  HORIZON_Z = 100
  
  include Processing::Proxy
  include Math
    
  attr_reader :latitude, :longitude, :magnitude, :text
  attr_accessor :index
  
  def initialize(latitude, longitude, magnitude, text)
    @latitude, @longitude = latitude, longitude
    @magnitude, @text = magnitude, text
    @color = color(100, 255, 255, 155)
    @image = (Location.epicenter ||= load_image "images/epicenter.png")
    @selected_image = (Location.epicenter_selected ||= load_image "images/epicenter_selected.png")
    compute_position
  end
  
  def compute_position
    # The negative and the ninety are the fudge to compensate for our map.
    lat = @latitude_radians = radians(-@latitude)
    long = @longitude_radians = radians(@longitude + 90)
    radius = $app.globe.diameter / 2.0 - 23
    @x = radius * cos(lat) * sin(long)
    @y = radius * sin(lat)
    @z = radius * cos(lat) * cos(long)
  end
  
  def draw(selected=false)
    return unless model_z(@x, @y, @z) > HORIZON_Z
    push_matrix
    translate @x, @y, @z
    rotate_y @longitude_radians
    rotate_x -@latitude_radians
    image selected ? @selected_image : @image, 0, 0, @magnitude, @magnitude
    pop_matrix
  end
  
  def draw_for_picking(index, buffer)
    # return unless model_z(@x, @y, @z) > 1 # Not working for some reason.
    buffer.push_matrix
    buffer.translate @x, @y, @z
    buffer.fill index
    buffer.rotate_y @longitude_radians
    buffer.rotate_x -@latitude_radians
    buffer.ellipse 0, 0, @magnitude, @magnitude
    buffer.pop_matrix
  end
  
end