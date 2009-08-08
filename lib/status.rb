class Status
  include Processing::Proxy
  
  def initialize
    @statuses = {}
  end
  
  def set(key, text, timeout=false)
    if timeout
      @statuses[key] = [text, Time.now + timeout]
    else
      @statuses[key] = text
    end
  end
  
  def remove(key)
    @statuses.delete(key)
  end
  
  def message
    # drop old messages that time out
    values = @statuses.clone.inject([]){|m,p|
      k,v=*p
      if v.is_a?(Array) && Time.now > v[1]
        remove(k)
      else
        m << (v.is_a?(Array) ? v[0] : v)
      end
      m
    }
    (values << "#{frame_rate.to_i} FPS").join("\n")
  end
  
  def draw
    fill 200
    text(message, 10, 20)
  end
  
end