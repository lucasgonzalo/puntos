class ErrorsController < ApplicationController
  def not_found
    render status: 404
  end

  def internal_server_error
    render status: 500
  end

  def service_unavailable
    render status: 503
  end

  def not_allowed
    # render status: 505
  end
end