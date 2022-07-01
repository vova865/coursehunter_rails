class StaticPagesController < ApplicationController
  def landing_page
  end

  def privacy_policy
  end

  def activity
    @activities = PublicActivity::Activity.all
  end
end
