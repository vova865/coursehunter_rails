# frozen_string_literal: true

class StaticPagesController < ApplicationController
  def landing_page; end

  def privacy_policy; end

  def activity
    if current_user.has_role?(:admin)
      @pagy, @activities = pagy(PublicActivity::Activity.order(created_at: :desc))

    else
      redirect_to root_path, alert: 'You are not authorized to access this page'
    end
  end

  def analytics
    if current_user.has_role?(:admin)
      @enrollments = Enrollment.all
      @courses = Course.all
    else
      redirect_to root_path, alert: 'You are not authorized to access this page'
    end
  end

end
