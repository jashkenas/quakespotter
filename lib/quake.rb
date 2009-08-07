# Plotting longitude and latitude on a globe: 
# x = r * cos(lat) * sin(long)
# y = r * sin(lat)
# z = r * cos(lat) * cos(long)
# where r is radius, lat is latitude and long is longitude

class Quake
  
  class << self
    attr_accessor :image, :selected_image, :overlay_image
  end
  
  HORIZON_Z = 120
  TIME_FORMAT = '%l:%M %p, %A %B %e (%Z)'
  
  include Processing::Proxy
  include Math
    
  attr_reader :latitude, :longitude, :magnitude, :text, :time, :url
  attr_accessor :index, :tweets, :map
  
  def initialize(latitude, longitude, magnitude, text, time, url)
    @latitude, @longitude = latitude, longitude
    @magnitude, @text, @time, @url = magnitude, text, time, url
    @size = display_size
    @local_time = time.localtime.strftime TIME_FORMAT
    @hidden = false
    @tweets = []
    @color = color(100, 255, 255, 155)
    @image = (Quake.image ||= load_image "images/epicenter.png")
    @selected_image = (Quake.selected_image ||= load_image "images/epicenter_selected.png")
    @overlay_image = (Quake.overlay_image ||= load_image "images/overlay.png")
    compute_position
  end
  
  # Compute the 3D Cartesian coordinates of the earthquake's postition as 
  # plotted on the globe.
  def compute_position
    # The negative and the ninety are the fudge to compensate for our map.
    lat = @latitude_radians = radians(-@latitude)
    long = @longitude_radians = radians(@longitude + 90)
    radius = $app.globe.diameter / 2.0 - 23
    @x = radius * cos(lat) * sin(long)
    @y = radius * sin(lat)
    @z = radius * cos(lat) * cos(long)
  end
  
  # The display size of a quake is a function of the magnitude, adjusted
  # to compensate for the Richter scale.
  def display_size
   # (1.9 ** @magnitude) / 3.0 + 2.5
   (2.05 ** @magnitude) / 3.6 + 2.5
  end
  
  # Is the earthquake hidden from view on the far side of the earth?
  def hidden?
    @hidden
  end
  
  # Generate the information for display in the control strip
  def info
    @info ||= "Magnitude #{@magnitude}\n#{@text}\n#{@local_time}"
  end
  
  # OLD DRAW METHOD
  # Draw the visible earthquakes for display on the globe.
  # def draw(selected=false)
  #   return if @hidden = model_z(@x, @y, @z) < HORIZON_Z
  #   push_matrix
  #   translate @x, @y, @z
  #   rotate_y @longitude_radians
  #   rotate_x -@latitude_radians
  #   image selected ? @selected_image : @image, 0, 0, @size, @size
  #   pop_matrix
  # end

  # Draw the visible earthquakes for display on the globe.
  def draw(selected=false)
    return if @hidden = model_z(@x, @y, @z) < HORIZON_Z
    if selected 
      @size = @size * 1.15 if @size < display_size * 2
    else
      @size = @size / 1.15 if @size > display_size
    end
    quake_2d(selected)
  end
  
  # Draw the earthquakes into the picking buffer for selection.
  def draw_for_picking(index, buffer)
    buffer.push_matrix
    buffer.translate @x, @y, @z
    buffer.fill index
    buffer.rotate_y @longitude_radians
    buffer.rotate_x -@latitude_radians
    buffer.ellipse 0, 0, @size, @size
    buffer.pop_matrix
  end
  
  def quake_2d(selected=false)
    push_matrix
    translate @x, @y, @z
    rotate_y @longitude_radians
    rotate_x -@latitude_radians
    fill(255, 255, 255, 200)
    # center
    ellipse(0, 0, @size/12, @size/12)
    no_fill
    stroke(255, 255, 255)

    rings = selected ?
      [[5, color(87,205,255)], [2, color(0,132,255)], 
      [1.25, color(0, 210, 255)],
      [1, color(0,255,255)]] :
      [[5, color(0,186,255, 200)], [2, color(183,255,175, 200)], 
      [1.25, color(255, 255, 255, 200)],
      [1, color(255,255,255, 200)]]
    #rings
    rings.each do |s|
      ellipse_mode(CENTER)
      stroke(s[1])
      ellipse(0, 0, @size/s[0], @size/s[0])
    end
    no_stroke
    pop_matrix
  end
  
  def quake_3d
    
  end
  
end