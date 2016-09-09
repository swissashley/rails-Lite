require 'byebug'
require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'
require_relative './flash'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res, route_params = {})
    @req, @res = req, res
    @params = route_params.merge(req.params)
    @already_built_response = false
    @@protect_from_forgery ||= false
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    raise "Double render" if already_built_response?
    @res.status = 302
    @res["Location"] = url
    session.store_session(@res)
    flash.store_flash(@res)
    @already_built_response = true
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    raise "Double render" if already_built_response?
    @res.write(content)
    @res['Content-Type'] = content_type
    @already_built_response = true
    session.store_session(@res)
    flash.store_flash(@res)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    current_path = File.dirname(__FILE__)
    path = current_path + "/../views/" +  self.class.name.underscore + "/" + template_name.to_s + ".html.erb"
    template = File.read(path)
    # p "Before ERB: #{template}"

    content = ERB.new(template).result(binding)
    # p "After  ERB: #{content}"

    #FIXME should put in the content instead of template

    render_content(content, 'text/html')
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  def flash
    @flash ||= Flash.new(@req)
  end
  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    p "!@!#"
    p protect_from_forgery?
    if protect_from_forgery? && @req.request_method != "GET"
      check_authenticity_token
    else
      form_authenticity_token
    end
    self.send(name)
    render(name) unless already_built_response?
  end

  def form_authenticity_token
    @form_authenticity_token ||= generate_auth_token
    @res.set_cookie('authenticity_token', value: @form_authenticity_token, path: '/')
    @form_authenticity_token
  end

  def self.protect_from_forgery
    @@protect_from_forgery = true
  end

  def check_authenticity_token
    cookie = @req.cookies["authenticity_token"]
    unless cookie && cookie == @params['authenticity_token']
      raise "Invalid authenticity token"
    end
  end


  def protect_from_forgery?
      @@protect_from_forgery
  end

  def generate_auth_token
    SecureRandom.urlsafe_base64(16)
  end
end
