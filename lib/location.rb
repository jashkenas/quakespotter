# Plotting longitude and latitude on a globe: 
# x = r * cos(lat) * sin(long)
# y = r * sin(lat)
# z = r * cos(lat) * cos(long)
# where r is radius, lat is latitude and long is longitude

class Location
  
  include Processing::Proxy
  include Math
  
  attr_reader :latitude, :longitude, :magnitude
  
  def initialize(latitude, longitude, magnitude)
    @latitude, @longitude, @magnitude = latitude, longitude, magnitude
  end
  
  def draw(diameter)
    # The negative and the ninety are the fudge to compensate for our map.
    lat, long = radians(-@latitude), radians(@longitude + 90)
    radius = diameter / 2.0 - 5
    x = radius * cos(lat) * sin(long)
    y = radius * sin(lat)
    z = radius * cos(lat) * cos(long)
    push_matrix
    translate x, y, z
    rotate_y(long)
    rotate_x(-lat)
    oval 0, 0, @magnitude, @magnitude
    pop_matrix
  end
  
end