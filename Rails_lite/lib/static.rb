require 'byebug'
class Static
  attr_reader :app

  MIME_TYPES = {
    'txt' => 'text/plain',
    'jpg' => 'image/jpeg',
    'zip' => 'application/zip'
  }

  def initialize(app)
    p "Initialize an app.."
    @app = app
  end

  def call(env)
    p "Calling app.."
    @app.call(env)
    parsing(env)
  end

  private

  def parsing(env)
    res = Rack::Response.new
    pattern = Regexp.new("^/public/*\.*")
    match_data = pattern.match(env["PATH_INFO"])
    if !match_data.nil?
        ext = match_data[0].split(".").last
    end
    dirpath = File.dirname(__FILE__)
    begin
      file = File.read(dirpath + "/../#{env["PATH_INFO"]}")
      content = ERB.new(file).result(binding)
    rescue
      res.status = 404
      res.write("File not found")
      return res
    end
    res.status = 200
    res['Content-type'] = MIME_TYPES[ext]
    res.write(content)
    return res
  end
end
