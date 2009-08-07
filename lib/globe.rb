class Globe
  
  include Processing::Proxy
  include Math
  
  attr_reader :diameter
  
  def initialize
    @sphere_detail = 35
    @diameter = 600
    @vertices = []
    @visible_vertices = []
    
    @sphere_x, @sphere_y, @sphere_z = [], [], []
    @sin_cos_precision = 0.5
    @sin_cos_length = (360.0 / @sin_cos_precision).to_i
    
    @texmap = load_image "globes/globe_merged.png"
    initialize_sphere
    compute_vertices
  end
  
  def initialize_sphere
    res = @sphere_detail
    cx, cz = [], []
    sin_table, cos_table = [], []
    
    @sin_cos_length.times do |i|
      sin_table[i] = sin(radians(i) * @sin_cos_precision).to_f
      cos_table[i] = cos(radians(i) * @sin_cos_precision).to_f
    end
    
    delta       = @sin_cos_length / res.to_f
    angle_step  = (@sin_cos_length * 0.5) / res.to_f
    angle       = angle_step
    vert_count  = res * (res - 1) + 2
    curr_vert   = 0
    
    # Calc unit circle in XZ plane
    res.times do |i|
      index = (i * delta) % @sin_cos_length
      cx[i] = -cos_table[index]
      cz[i] = sin_table[index]
    end
    
    # step along Y axis
    (1...res).each do |i|
      index = angle % @sin_cos_length
      curr_radius = sin_table[index]
      curr_y = -cos_table[index]
      res.times do |j|
        @sphere_x[curr_vert] = cx[j] * curr_radius
        @sphere_y[curr_vert] = curr_y
        @sphere_z[curr_vert] = cz[j] * curr_radius
        curr_vert += 1
      end
      angle += angle_step
    end
  end
  
  def compute_vertices
    r, t, res, verts = @diameter, @texmap, @sphere_detail, @vertices
    r = (r + 240) * 0.33
    iu = (t.width - 1) / res.to_f
    iv = (t.height - 1) / res.to_f
    u = 0
    v = iv
    res.times do |i|
      verts << [0, -r, 0, u, 0]
      verts << [@sphere_x[i] * r, @sphere_y[i] * r, @sphere_z[i] * r, u, v]
      u += iu
    end
    verts << [0, -r, 0, u, 0]
    verts << [@sphere_x[0] * r, @sphere_y[0] * r, @sphere_z[0] * r, u, v]
    
    # Middle rings
    voff = 0
    (2...res).each do |i|
      v1 = v11 = voff
      voff += res
      v2 = voff
      u = 0
      res.times do |j|
        verts << [@sphere_x[v1] * r, @sphere_y[v1] * r, @sphere_z[v1] * r, u, v]
        verts << [@sphere_x[v2] * r, @sphere_y[v2] * r, @sphere_z[v2] * r, u, v + iv]
        v1 += 1
        v2 += 1
        u += iu
      end
      
      # Close each ring
      v1 = v11
      v2 = voff
      verts << [@sphere_x[v1] * r, @sphere_y[v1] * r, @sphere_z[v1] * r, u, v]
      verts << [@sphere_x[v2] * r, @sphere_y[v2] * r, @sphere_z[v2] * r, u, v + iv]
      v += iv
    end
    u = 0
    
    # Add the northern cap
    res.times do |i|
      v2 = voff + i
      verts << [0, r, 0, u, v + iv]
      verts << [@sphere_x[v2] * r, @sphere_y[v2] * r, @sphere_z[v2] * r, u, v]
      u += iu
    end
    verts << [0, r, 0, u, v + iv]
    verts << [@sphere_x[voff] * r, @sphere_y[voff] * r, @sphere_z[voff] * r, u, v]
  end
  
  # Generate our sublist of visible vertices to be drawn.
  def check_visibility
    @visible_vertices = @vertices.select {|v| model_z(v[0], v[1], v[2]) > 1 }
  end
  
  # Loop through and draw all the vertices for the globe, but only if they're
  # located on the visible hemisphere.
  def draw
    begin_shape TRIANGLE_STRIP
    texture @texmap
    @visible_vertices.each {|v| vertex *v }
    end_shape
  end
  
end