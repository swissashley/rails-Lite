require 'json'

class Flash

  attr_reader :now

  def initialize(req)
    cookie = req.cookies["_rails_lite_app_flash"]

    if cookie
      @req = JSON.parse(cookie)
      @now = JSON.parse(cookie)
    else
      @req = {}
      @now = {}
    end

  end

  def [](key)
    @req[key] || @now[key]
  end

  def []=(key, val)
    @req[key] = val
  end

  def store_flash(res)
    cookie = {path: "/", value: @req.to_json}
    res.set_cookie("_rails_lite_app_flash", cookie)
  end
end
