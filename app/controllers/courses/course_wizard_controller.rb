class Courses::CourseWizardController < ApplicationController
  include Wicked::Wizard
  before_action :set_progress, only: [:show, :update]
  before_action :set_course, only: [:show, :update, :finish_wizard_path]

  steps :basic_info, :details

  def show
    authorize @course, :edit?
    render_wizard
  end

  def update
    authorize @course
    case step
    when :basic_info
      @course.update(course_params)
    when :details
      @course.update(course_params)
    end
    render_wizard @course
  end

  def finish_wizard_path
    authorize @course
    course_path(@course)
  end

  private

  def set_progress
    if wizard_steps.any? && wizard_steps.index(step).present?
      @progress = ((wizard_steps.index(step) + 1).to_d / wizard_steps.count.to_d) * 100
    else
      @progress = 0
    end
  end

  def course_params
    params.require(:course).permit(:title, :description, :short_description, :price, :language, :level, :image,
                                   :published)
  end

  def set_course
    @course = Course.find(params[:course_id])
  end
end
