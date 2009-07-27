class Status
  include Processing::Proxy
  
  def initialize
    @statuses = {}
  end
  
  def set(key, text)
    @statuses[key] = text
  end
  
  def remove(key)
    @statuses.delete(key)
  end
  
  def message
    (@statuses.values << "#{frame_rate.to_i} FPS").join("\n")
  end
  
  def draw
    fill 200
    text(message, 10, 20)
  end
  
end