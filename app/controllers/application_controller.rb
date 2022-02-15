class ApplicationController < ActionController::Base
  include Authentication

  helper_method :alert_class

  def alert_class(type)
    case type.to_sym
    when :alert
      'alert-danger'
    when :notice
      'alert-success'
    when :primary
      'alert-primary'
    else
      'alert-info'
    end
  end
end
