require 'base64'
require 'open-uri'

class ImageEncoder
  def self.encode(image_path, ext)
    content = open(image_path) { |f| f.read }
    encoded = Base64.encode64(content)

    image = "data:image/#{ext};base64,#{encoded}"
  end
end
