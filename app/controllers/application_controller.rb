# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include PublicActivity::StoreController
  include Pundit
  protect_from_forgery
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  after_action :user_activity

  private

  def user_activity
    current_user.try :touch
  end

  def user_not_authorized
    flash[:alert] = 'You are not authorized to perform this action.'
    redirect_back(fallback_location: root_path)
  end
end
