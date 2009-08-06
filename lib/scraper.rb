require 'timeout'
require 'uri'

# Scraper for geo-located .gov sites, getting us our goodies.
class Scraper
  
  SOURCES = {
    'quakes'    => 'http://earthquake.usgs.gov/eqcenter/catalogs/7day-M2.5.xml',
    'twitter'  => 'http://search.twitter.com/search.atom'
  }
  
  MAGNITUDE_FINDER = /\AM (\d+\.\d+)/
  TEXT_FINDER = /\AM \d+\.\d+, (.+)\Z/
  
  REQUEST_TIMEOUT = 10
  
  def earthquakes
    @earthquakes ||= fetch_earthquakes
  end
    
  def query_string(hash)
    URI.escape("?" + hash.map {|k, v| "#{k}=#{v}" }.join('&'))
  end
  
  # Attempt fetch a resource from the web, cache it locally.
  def fetch(resource)
    local_path = "data/sources/#{resource}.xml"
    xml = nil
    begin
      if File.exists?(local_path) && File.mtime(local_path) > (Time.now - 300) # More than 5 minutes ago.
        puts "Reading #{resource} from the local cache."
        xml = File.read(local_path)
      else
        puts "Fetching #{resource} from the web."
        Timeout.timeout(REQUEST_TIMEOUT) { xml = open(SOURCES[resource]).read }
        File.open(local_path, 'w+') {|f| f.write(xml) }
      end
    rescue Timeout::Error, OpenURI::HTTPError => e
      puts "Failed to fetch #{resource} from the web ... falling back to cache."
      xml = File.read(local_path) if File.exists? local_path
    end
    raise "Could not fetch #{resource}" unless xml
    Hpricot xml
  end
  
  def fetch_map(quake)
    Thread.new do
      $app.status.set :earthquakes, "Downloading map of #{quake.text}..."
      html = Hpricot(open(quake.url).read)
      src = (html / "//li/a/img[@alt='Earthquake Location Maps']").attr('src')
      src.sub!('_small.gif', '.jpg')
      quake.map = Map.new(src)
      $app.status.remove :earthquakes
    end
  end
  
  def fetch_earthquakes
    $app.status.set :earthquakes, "Downloading recent earthquakes..."
    doc = fetch('quakes')

    quakes = (doc / 'entry').map do |entry|
      point = (entry / 'georss:point').inner_html.split(' ').map {|n| n.to_f }
      time  = Time.parse((entry / 'updated').inner_html)
      title = (entry / 'title').inner_html
      url   = 'http://earthquake.usgs.gov' + (entry / 'link').attr('href')
      text  = title.match(TEXT_FINDER)[1]
      text  = text[0..0].upcase + text[1..-1]
      mag   = title.match(MAGNITUDE_FINDER)[1].to_f
      Quake.new(point[0], point[1], mag, text, time, url)
    end
    
    quakes = quakes.sort_by {|q| q.longitude }
    $app.status.remove :earthquakes
    quakes
  end
  
  def fetch_tweets(quake)
    Thread.new do
      $app.status.set :earthquakes, "Searching Twitter near #{quake.text}..."
      query = {
        'q'       => 'earthquake OR terremoto',
        'geocode' => "#{quake.latitude},#{quake.longitude},100mi",
        'since'   => quake.time.strftime('%Y-%m-%d'),
        'rpp'     => 5
      }
      url = SOURCES['twitter'] + query_string(query)
      doc = Hpricot(open(url).read)
      
      quake.tweets = (doc / 'entry').map do |entry|
        Tweet.new(
          (entry / '/title').inner_html,
          (entry / '/author/name').inner_html.match(/\((.+)\)\Z/)[1],
          (entry / '/link[@rel="image"]').attr('href')
        )
      end
      
      $app.status.remove :earthquakes
    end
  end
  
  
end