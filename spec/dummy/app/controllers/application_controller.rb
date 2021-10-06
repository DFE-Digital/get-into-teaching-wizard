class ApplicationController < ActionController::Base
  rescue_from ActionController::RoutingError, with: :render_not_found

private

  def raise_not_found
    raise ActionController::RoutingError, "Not Found"
  end

  def render_not_found
    render status: 404, body: nil
  end
end
