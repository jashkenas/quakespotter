class Globe
  
  include Processing::Proxy
  include Math
  
  attr_reader :diameter
  
  def initialize
    @sphere_detail = 35
    @diameter = 500
    
    @cx, @cz, @sphere_x, @sphere_y, @sphere_z = [], [], [], [], []
    @sin_lut, @cos_lut = [], []
    @sin_cos_precision = 0.5
    @sin_cos_length = (360.0 / @sin_cos_precision).to_i
    
    @texmap = load_image "land_ocean_ice_2048.jpg"
    initialize_sphere(@sphere_detail)
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
  def draw
    r, t, res = @diameter, @texmap, @sphere_detail
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