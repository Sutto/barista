class BaristaController < ActionController::Base
  
  caches_page :show if Rails.env.production?
  
  # Used for rendering on the fly.
  def show
    headers['Content-Type'] = "application/javascript"
    path = normalize_path(params[:js_path])
    p path
    return head(:forbidden) unless can_render_path?(path)
    compiled = Barista.render_path(path)
    compiled.nil? ? head(:not_found) : render(:text => compiled.to_s)
  end
  
  protected
  
  def normalize_path(path)
    File.join(Array.wrap(path).flatten)
  end
  
  def can_render_path?(path)
    !path.include?("..")
  end
  
end