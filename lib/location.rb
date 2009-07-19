# Plotting longitude and latitude on a globe: 
# x = r * cos(lat) * sin(long)
# y = r * sin(lat)
# z = r * cos(lat) * cos(long)
# where r is radius, lat is latitude and long is longitude

class Location
  
  include Processing::Proxy
  include Math
  
  HOVER_RADIUS = 4
  
  attr_reader :latitude, :longitude, :magnitude
  attr_accessor :index
  
  def initialize(latitude, longitude, magnitude)
    @latitude, @longitude, @magnitude = latitude, longitude, magnitude
    @color = color(100, 255, 255, 155)
    compute_position
  end
  
  def compute_position
    # The negative and the ninety are the fudge to compensate for our map.
    lat = @latitude_radians = radians(-@latitude)
    long = @longitude_radians = radians(@longitude + 90)
    radius = $app.globe.diameter / 2.0 - 5
    @x = radius * cos(lat) * sin(long)
    @y = radius * sin(lat)
    @z = radius * cos(lat) * cos(long)
  end
  
  def draw(selected)
    push_matrix
    translate @x, @y, @z
    fill selected ? 255 : @color
    rotate_y @longitude_radians
    rotate_x -@latitude_radians
    ellipse 0, 0, @magnitude, @magnitude
    pop_matrix
  end
  
  def draw_for_picking(index, buffer)
    buffer.push_matrix
    buffer.translate @x, @y, @z
    if model_z(0,0,0) < 1
      buffer.fill index
      buffer.rotate_y @longitude_radians
      buffer.rotate_x -@latitude_radians
      buffer.ellipse 0, 0, @magnitude, @magnitude
    end
    buffer.pop_matrix
  end
  
end