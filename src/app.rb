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

get '/detect.json' do
  uri = URI.parse(params[:url])
  res = Net::HTTP.get_response(uri)
  image = Magick::ImageList.new
  image.from_blob(res.body)
  faces = AnimeFace::detect(image)
  json faces
end

get '/detect.jpg' do
  uri = URI.parse(params[:url])
  res = Net::HTTP.get_response(uri)
  image = Magick::ImageList.new
  image.from_blob(res.body)
  faces = AnimeFace::detect(image)
  gc = Magick::Draw.new
  gc.stroke = 'red'
  gc.fill = 'transparent'
  faces.each do |ctx|
    face = ctx["face"]
    left_eye = ctx["eyes"]["left"]
    right_eye = ctx["eyes"]["right"]
    nose = ctx["nose"]
    mouth = ctx["mouth"]
    chin = ctx["chin"]
    hair_color = ctx["hair_color"]
    gc.rectangle(face["x"], face["y"], face["x"] + face["width"], face["y"] + face["height"])
    gc.rectangle(left_eye["x"], left_eye["y"], left_eye["x"] + left_eye["width"], left_eye["y"] + left_eye["height"])
    gc.rectangle(right_eye["x"], right_eye["y"], right_eye["x"] + right_eye["width"], right_eye["y"] + right_eye["height"])
    gc.rectangle(nose["x"], nose["y"], nose["x"] + 2, nose["y"] + 2)
    gc.rectangle(mouth["x"], mouth["y"], mouth["x"] + mouth["width"], mouth["y"] + mouth["height"])
    gc.rectangle(chin["x"], chin["y"], chin["x"] + 2, chin["y"] + 2)

    hair_gc = Magick::Draw.new
    hair_gc.stroke = 'black'
    hair_gc.fill = hair_color.to_color
    hair_gc.rectangle(face["x"] + face["width"] + 2, face["y"], 
                      face["x"] + face["width"] + 2 + 16, face["y"] + 16)
    hair_gc.draw(image)

    score_gc = Magick::Draw.new
    score_gc.fill = 'red'
    score_gc.stroke = 'transparent'
    score_gc.pointsize = 16
    score_gc.annotate(image, 0, 0, face["x"], [face["y"]- 2, 0].max, sprintf("%.3f", ctx["likelihood"]))
  end
  gc.draw(image)
  output = Tempfile.new()
  image.format = "JPEG"
  image.write(output.path)
  send_file(output.path, :type => 'image/jpg', :disposition => 'inline')
end