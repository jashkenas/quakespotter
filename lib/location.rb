# Plotting longitude and latitude on a globe: 
# x = r * cos(lat) * sin(long)
# y = r * sin(lat)
# z = r * cos(lat) * cos(long)
# where r is radius, lat is latitude and long is longitude

class Location
  
  COORDS = [
    [0.0,      0.0],      # The Origin
    [37.77,   -122.41],   # San Francisco
    [40.77,   -73.97],    # Central Park
    [19.78,   -155.01],   # Mauna Kea
    [30.06,    31.24]     # Cairo
  ]
  
  include Processing::Proxy
  include Math
  
  attr_reader :latitude, :longitude
  
  def initialize(latitude, longitude)
    @latitude, @longitude = latitude, longitude 
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
    sphere 1
    pop_matrix
  end
  
end