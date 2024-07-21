module Authenticatable
  # Devise method overwrites
  def current_user
    authenticate_or_request_with_http_token do |token, options|
      @current_user ||= Core::User.find_by(auth_token: token)
    end
      # @current_user ||= Core::User.find_by(auth_token: request.headers['Authorization'])
  rescue Mongoid::Errors::DocumentNotFound
    render json: { status: 'error', message: 'Not authenticated'}, status: :unauthorized
  end

  def authenticate_with_token!
    render json: { status: 'error', message: 'Not authenticated'}, status: :unauthorized unless user_signed_in?
  end

  def user_signed_in?
    current_user.present?
  end
end
