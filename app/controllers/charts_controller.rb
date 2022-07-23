class ChartsController < ApplicationController
  def users_per_day
    render json: User.group_by_day(:created_at).count
  end

  def money_makers
    render json: Enrollment.joins(:course).group(:'courses.title').sum(:price)
  end
end
