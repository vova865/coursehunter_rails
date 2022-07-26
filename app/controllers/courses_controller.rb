# frozen_string_literal: true

class CoursesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_course, only: %i[show edit update destroy approve unapprove analytics]

  def index
    @courses = Course.all
    @q = Course.published.approved.ransack(params[:q])
    @courses = @q.result.includes(:user)
    @pagy, @courses = pagy(@courses)
  end

  def show
    authorize @course
    @lessons = @course.lessons.rank(:row_order)
    @enrollments_with_review = @course.enrollments.reviewed
  end

  def new
    @course = Course.new
    authorize @course
  end

  def edit
    authorize @course
  end

  def create
    @course = Course.new(course_params)
    authorize @course
    @course.user = current_user

    respond_to do |format|
      if @course.save
        format.html { redirect_to course_url(@course), notice: 'Course was successfully created.' }
        format.json { render :show, status: :created, location: @course }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @course
    respond_to do |format|
      if @course.update(course_params)
        format.html { redirect_to course_url(@course), notice: 'Course was successfully updated.' }
        format.json { render :show, status: :ok, location: @course }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @course.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @course
    if @course.destroy
      respond_to do |format|
        format.html { redirect_to courses_url, notice: 'Course was successfully destroyed.' }
        format.json { head :no_content }
      end
    else
      redirect_to @course, alert: 'Course has enrollments. Cat not be destroyed.'
    end
  end

  def purchased
    @ransack_path = purchased_courses_path
    @q = Course.ransack(params[:q])
    @pagy, @courses = pagy(Course.joins(:enrollments).where(enrollments: { user_id: current_user.id }))
    render 'index'
  end

  def pending_review
    @ransack_path = pending_review_courses_path
    @q = Course.ransack(params[:q])
    @pagy, @courses = pagy(Course.joins(:enrollments).merge(Enrollment.pending_review.where(user_id: current_user.id)))
    render 'index'
  end

  def created
    @ransack_path = created_courses_path
    @q = Course.ransack(params[:q])
    @pagy, @courses = pagy(Course.where(user_id: current_user.id))
    render 'index'
  end

  def approve
    authorize @course, :approve?
    @course.update_attribute(:approved, true)
    redirect_to @course, notice: 'Course approved and visible!'
  end

  def unapprove
    authorize @course, :approve?
    @course.update_attribute(:approved, false)
    redirect_to @course, notice: 'Course unapproved and hidden!'
  end

  def for_admin_all
    @ransack_path = for_admin_all_courses_path
    @q = Course.ransack(params[:q])
    @pagy, @courses = pagy(Course.all)
    render 'index'
  end

  def analytics
    authorize @course, :owner?
  end

  private

  def set_course
    @course = Course.find(params[:id])
  end

  def course_params
    params.require(:course).permit(:title, :description, :short_description, :price, :language, :level, :image,
                                   :published)
  end
end
