# San Francisco: 37.77, -122.41
# Manhattan: 40.80, -73.96
# Mauna Kea, HI: 19.78, -155.01

# Plotting longitude and latitude on a globe: 
# x = r * sin(a) * cos(b)
# y = r * sin(a) * sin(b)
# z = r * cos(a)
# where r is radius, a is latitude and b is longitude

class WorldWide < Processing::App

  load_library 'opengl'

  def setup
    @sphere_detail = 35
    @globe_diameter = 500
    @mouse_sensitivity = 0.03
    @push_back = 0
    @rot_x, @rot_y = 0, 0
    @vel_x, @vel_y = 0, 0
    
    @cx, @cz, @sphere_x, @sphere_y, @sphere_z = [], [], [], [], []
    @sin_lut, @cos_lut = [], []
    @sin_cos_precision = 0.5
    @sin_cos_length = (360.0 / @sin_cos_precision).to_i
    
    size(700, 700, OPENGL)
    frame_rate 10
    @texmap = load_image "land_ocean_ice_2048.jpg"
    initialize_sphere(@sphere_detail)
  end
  
  def draw
    background 0
    render_globe
  end
  
  def render_globe
    push_matrix
    translate width/2, height/2, @push_back
    push_matrix
    no_fill
    stroke 255, 200
    stroke_weight 2
    smooth
    pop_matrix
    lights
    push_matrix
    rotate_x radians(-@rot_x)
    rotate_y radians(270 - @rot_y)
    fill 200
    no_stroke
    texture_mode IMAGE
    plot_point @globe_diameter
    textured_sphere @globe_diameter, @texmap, @sphere_detail
    pop_matrix
    pop_matrix
    @rot_x += @vel_x
    @rot_y += @vel_y
    @vel_x *= 0.9
    @vel_y *= 0.9
    
    if mouse_pressed?
      @vel_x += (mouse_y - pmouse_y) * @mouse_sensitivity
      @vel_y -= (mouse_x - pmouse_x) * @mouse_sensitivity
    end
  end
  
  def plot_point(diameter)
    lat, long = 0, 0
    
    lat, long = radians(-lat + 90), radians(long)
    
    radius = diameter / 2.0
    x = radius * sin(lat) * cos(long)
    y = radius * sin(lat) * sin(long)
    z = radius * cos(lat)
    push_matrix
    translate x, y, z
    sphere 1
    pop_matrix
  end
  
  def initialize_sphere(res)
    @sin_cos_length.times do |i|
      @sin_lut[i] = sin(radians(i) * @sin_cos_precision).to_f
      @cos_lut[i] = cos(radians(i) * @sin_cos_precision).to_f
    end
    
    delta       = @sin_cos_length / res.to_f
    angle_step  = (@sin_cos_length * 0.5) / res.to_f
    angle       = angle_step
    vert_count  = res * (res - 1) + 2
    curr_vert   = 0
    
    # Calc unit circle in XZ plane
    res.times do |i|
      index = (i * delta) % @sin_cos_length
      @cx[i] = -@cos_lut[index]
      @cz[i] = @sin_lut[index]
    end
    
    # step along Y axis
    (1...res).each do |i|
      index = angle % @sin_cos_length
      curr_radius = @sin_lut[index]
      curr_y = -@cos_lut[index]
      res.times do |j|
        @sphere_x[curr_vert] = @cx[j] * curr_radius
        @sphere_y[curr_vert] = curr_y
        @sphere_z[curr_vert] = @cz[j] * curr_radius
        curr_vert += 1
      end
      angle += angle_step
    end
  end
  
  # Generic subroutine to draw a textured sphere
  def textured_sphere(diameter, texture_map, res)
    r, t = diameter, texture_map
    r = (r + 240) * 0.33
    begin_shape TRIANGLE_STRIP
    texture t
    iu = (t.width - 1) / res.to_f
    iv = (t.height - 1) / res.to_f
    u = 0
    v = iv
    res.times do |i|
      vertex 0, -r, 0, u, 0
      vertex @sphere_x[i] * r, @sphere_y[i] * r, @sphere_z[i] * r, u, v
      u += iu
    end
    vertex 0, -r, 0, u, 0
    vertex @sphere_x[0] * r, @sphere_y[0] * r, @sphere_z[0] * r, u, v
    end_shape
    
    # Middle rings
    voff = 0
    (2...res).each do |i|
      v1 = v11 = voff
      voff += res
      v2 = voff
      u = 0
      begin_shape TRIANGLE_STRIP
      texture t
      res.times do |j|
        vertex @sphere_x[v1] * r, @sphere_y[v1] * r, @sphere_z[v1] * r, u, v
        vertex @sphere_x[v2] * r, @sphere_y[v2] * r, @sphere_z[v2] * r, u, v + iv
        v1 += 1
        v2 += 1
        u += iu
      end
      
      # Close each ring
      v1 = v11
      v2 = voff
      vertex @sphere_x[v1] * r, @sphere_y[v1] * r, @sphere_z[v1] * r, u, v
      vertex @sphere_x[v2] * r, @sphere_y[v2] * r, @sphere_z[v2] * r, u, v + iv
      end_shape
      v += iv
    end
    u = 0
    
    # Add the northern cap
    begin_shape TRIANGLE_STRIP
    texture t
    res.times do |i|
      v2 = voff + i
      vertex 0, r, 0, u, v + iv
      vertex @sphere_x[v2] * r, @sphere_y[v2] * r, @sphere_z[v2] * r, u, v
      u += iu
    end
    vertex 0, r, 0, u, v + iv
    vertex @sphere_x[voff] * r, @sphere_y[voff] * r, @sphere_z[voff] * r, u, v
    end_shape
  end
  
end

WorldWide.new