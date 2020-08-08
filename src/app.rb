require "sinatra"
require "sinatra/json"
require "net/http"
require "json"
require "rmagick"
require_relative "AnimeFace"

set :bind, '0.0.0.0'

get '/' do
  'ok'
end

get '/detect' do
  uri = URI.parse(params[:url])
  res = Net::HTTP.get_response(uri)
  image = Magick::ImageList.new
  image.from_blob(res.body)
  faces = AnimeFace::detect(image)
  json faces
end