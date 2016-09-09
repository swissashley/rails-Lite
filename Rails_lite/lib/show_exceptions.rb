require 'erb'

class ShowExceptions

  attr_reader :app

  def initialize(app)
    p "Initialize an app.."
    @app = app
  end

  def call(env)
    begin
      p "Calling app.."
      @app.call(env)
    rescue Exception => e
      render_exception(e)
    end
  end

  private

  def render_exception(e)
    ['500', {'Content-type' => 'text/html'}, "Sending Excption: " + e.to_s]
  end
end
