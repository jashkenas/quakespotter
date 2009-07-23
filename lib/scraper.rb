require 'timeout'
require 'uri'

# Scraper for geo-located .gov sites, getting us our goodies.
class Scraper
  
  SOURCES = {
    'quakes.xml'    => 'http://earthquake.usgs.gov/eqcenter/catalogs/7day-M2.5.xml',
    'twitter.json'  => 'http://search.twitter.com/search.json'
  }
  
  MAGNITUDE_FINDER = /\AM (\d+\.\d+)/
  
  REQUEST_TIMEOUT = 10
  
  attr_reader :earthquakes
  
  def initialize
    @earthquakes = fetch_earthquakes
  end
  
  def query_string(hash)
    URI.escape("?" + hash.map {|k, v| "#{k}=#{v}" }.join('&'))
  end
  
  # Attempt fetch a resource from the web, cache it locally.
  def fetch(resource)
    local_path = "data/sources/#{resource}"
    xml = nil
    begin
      Timeout.timeout(REQUEST_TIMEOUT) do
        xml = open(SOURCES[resource]).read
      end
      File.open(local_path, 'w+') {|f| f.write(xml) }
    rescue Timeout::Error, OpenURI::HTTPError => e
      puts "Failed to fetch #{resource} from the web ... falling back to cache."
      xml = File.read(local_path) if File.exists? local_path
    end
    raise "Could not fetch #{resource}" unless xml
    Hpricot xml
  end
  
  def fetch_earthquakes
    doc = fetch('quakes.xml')

    quakes = (doc / 'entry').map do |entry|
      point = (entry / 'georss:point').inner_html.split(' ').map {|n| n.to_f }
      title = (entry / 'title').inner_html
      mag = title.match(MAGNITUDE_FINDER)[1].to_f
      # Faux Richter-scale adjustments to visual magnitude size.
      mag = (1.9 ** mag) / 3.0 + 2.5
      Quake.new(point[0], point[1], mag, title)
    end
    
    quakes.sort_by {|q| q.longitude }
  end
  
  def fetch_tweets(quake)
    query = {
      'q' => 'earthquake OR quake OR terremoto OR 地震 OR землетрясение',
      'geocode' => "#{quake.latitude},#{quake.longitude},100mi"
    }
  end
  
  
end