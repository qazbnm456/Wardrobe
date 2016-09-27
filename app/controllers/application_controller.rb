class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :set_timezone
  before_action :configure_permitted_parameters, if: :devise_controller?

  SecureHeaders::Configuration.default do |config|
    config.cookies = {
        secure: true, # mark all cookies as "Secure"
        httponly: true, # mark all cookies as "HttpOnly"
        samesite: {
            strict: true # mark all cookies as SameSite=Strict
        }
    }
    config.hsts = OPT_OUT
    config.x_frame_options = "DENY"
    config.x_content_type_options = "nosniff"
    config.x_xss_protection = "1; mode=block"
    config.x_download_options = "noopen"
    config.x_permitted_cross_domain_policies = "none"
    config.csp = {
        # "meta" values. these will shaped the header, but the values are not included in the header.
        report_only:  Rails.env.development?,     # default: false
        preserve_schemes: Rails.env.development?, # default: false. Schemes are removed from host sources to save bytes and discourage mixed content.

        # directive values: these values will directly translate into source directives
        default_src: %w(https: 'self'),
        frame_src: %w('self'),
        connect_src: %w('self' wss://wargame.cse.nsysu.edu.tw:444),
        font_src: %w('self' fonts.gstatic.com data:),
        img_src: %w('self' https://raw.githubusercontent.com data:),
        media_src: %w('self'),
        object_src: %w('self'),
        script_src: %w(https: 'self' www.google.com 'unsafe-inline' 'unsafe-eval'),
        style_src: %w(https: 'self' 'unsafe-inline'),
        base_uri: %w('self'),
        child_src: %w('self'),
        form_action: %w('self'),
        frame_ancestors: %w('none'),
        plugin_types: %w(application/x-shockwave-flash),
        block_all_mixed_content: true, # see [http://www.w3.org/TR/mixed-content/](http://www.w3.org/TR/mixed-content/)
        upgrade_insecure_requests: true, # see https://www.w3.org/TR/upgrade-insecure-requests/
        report_uri: %w(https://331f16c75888d350134a58be3b017b7a.report-uri.io/r/default/csp/enforce)
    }
  end

  def set_timezone
    Time.zone = "Taipei"
  end

  def emailSubstitude(email)
    email.gsub("@", "-0-").gsub(".", "-").gsub("_", "-")
  end

  def getInstanceName(ready)
    emailSubstitude(ready)
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:name, :email, :password, :password_confirmation])
    devise_parameter_sanitizer.permit(:sign_in, keys: [:email, :password])
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :email, :password, :password_confirmation, :current_password])
  end
end
