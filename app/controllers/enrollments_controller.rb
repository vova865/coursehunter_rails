class EnrollmentsController < ApplicationController
  before_action :set_enrollment, only: %i[show edit update destroy certificate]
  before_action :set_course, only: %i[new create]

  def index
    @enrollments = Enrollment.all
    authorize @enrollments
  end

  def show; end

  def new
    @enrollment = Enrollment.new
  end

  def edit
    authorize @enrollment
  end

  def create
    @enrollment = current_user.buy_course(@course)
    redirect_to course_path(@course), notice: 'You are enrolled!'
    EnrollmentMailer.student_enrollment(@enrollment).deliver_later
    EnrollmentMailer.teacher_enrollment(@enrollment).deliver_later
    # if @course.price.positive?
    #   flash[:alert] = 'You can not access paid course yet'
    #   redirect_to new_course_enrollment_path(@course)
    # else
    #   @enrollment = current_user.buy_course(@course)
    #   redirect_to course_path(@course), notice: 'You are enrolled!'
    # end
  end

  def update
    authorize @enrollment
    respond_to do |format|
      if @enrollment.update(enrollment_params)
        format.html { redirect_to enrollment_url(@enrollment), notice: 'Enrollment was successfully updated.' }
        format.json { render :show, status: :ok, location: @enrollment }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @enrollment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    authorize @enrollment
    @enrollment.destroy
    respond_to do |format|
      format.html { redirect_to enrollments_url, notice: 'Enrollment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def my_students
    @enrollments = Enrollment.joins(:course).where(courses: {user_id: current_user.id})
    render 'index'
  end

  def certificate
    authorize @enrollment, :certificate?
    respond_to do |format|
      format.pdf do
        render pdf: "#{@enrollment.course.title}, #{@enrollment.user.email}",
               page_size: 'A4',
               template: 'enrollments/certificate.pdf.haml'
      end
    end
  end

  private

  def set_course
    @course = Course.find(params[:course_id])
  end

  def set_enrollment
    @enrollment = Enrollment.find(params[:id])
  end

  def enrollment_params
    params.require(:enrollment).permit(:rating, :review)
  end
end
