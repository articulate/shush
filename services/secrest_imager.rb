require 'http'

class SecrestImager
  BASE_URL = 'https://ajax.googleapis.com/ajax/services/search/images'
  BASE_SEARCH = "ryan secrest"
  PAGE_SIZE = 8

  def initialize
    @rnd = Random.new
  end

  # returns array size of <count> random image urls
  def get(count=1)
    images = fetch_images

    1.upto(count.to_i).map do |i|
      random(images)
    end
  end

  private

  def fetch_images
    response = HTTP.accept(:json).get(BASE_URL, params: request_params)
    decoded = JSON.parse(response.to_s)

    parse_images(decoded)
  end

  def parse_images(body)
    body['responseData']['results'].map do |img_def|
      img_def['url']
    end
  end

  def request_params
    {
      q: BASE_SEARCH,
      safe: 'active',
      rsz: 8,
      start: (@rnd.rand(8) * 8),
      v: '1.0'
    }
  end

  def random(images)
    index = @rnd.rand(images.count)
    images[index]
  end
end

