# frozen_string_literal: true

class LessonsController < ApplicationController
  before_action :set_lesson, only: %i[ show edit update destroy ]

  def index
    @lessons = Lesson.all
  end

  def show
    authorize @lesson
    current_user.view_lesson(@lesson)
    @lessons = @course.lessons.rank(:row_order)
  end

  def new
    @course = Course.find(params[:course_id])
    @lesson = @course.lessons.new
    authorize @lesson
  end

  def edit
    @course = Course.find(params[:course_id])
    authorize @lesson
  end

  def create
    @lesson = Lesson.new(lesson_params)
    @course = Course.find(params[:course_id])
    @lesson = @course.lessons.create(lesson_params)
    # @lesson.course_id = @course.id
    authorize @lesson
    respond_to do |format|
      if @lesson.save
        format.html { redirect_to course_lesson_path(@course, @lesson), notice: 'Lesson was successfully created.' }
        format.json { render :show, status: :created, location: @lesson }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @lesson.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    authorize @lesson
    respond_to do |format|
      if @lesson.update(lesson_params)
        format.html { redirect_to course_lesson_path(@course, @lesson), notice: 'Lesson was successfully updated.' }
        format.json { render :show, status: :ok, location: @lesson }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @lesson.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @lesson
    @lesson.destroy

    respond_to do |format|
      format.html { redirect_to course_path(@lesson.course), notice: 'Lesson was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_lesson
    @course = Course.find(params[:course_id])
    @lesson = Lesson.find(params[:id])
  end

  def lesson_params
    params.require(:lesson).permit(:title, :content, :course_id)
  end
end
