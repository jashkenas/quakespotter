class Tweet
  include Processing::Proxy
  
  TOP         = 85
  LEFT        = 75
  TEXT_WIDTH  = 390
  HEIGHT      = 75
  MARGIN      = 70
  
  def initialize(text, author, image_url)
    @text, @author, @image_url = text, author, image_url
    Thread.new { @image = load_image(@image_url) }
  end
  
  def content
    "#{@author}: #{@text}"
  end
  
  def draw(index)
    push_matrix
    translate LEFT + MARGIN, TOP + MARGIN + (HEIGHT * index), 0
    image @image, 0, 0, 48, 48 if @image
    text content, 60, 0, TEXT_WIDTH, HEIGHT
    pop_matrix
  end
  
end