# frozen_string_literal: true

module CoursesHelper
  def enrollment_button(course)
    if current_user
      if course.user == current_user
        link_to 'You created this course. View analytics', analytics_course_path(course)
      elsif course.enrollments.where(user: current_user).any?
        link_to course_path(course) do
          if course.lessons_count > 0
            "<i class='fa fa-spinner'></i>".html_safe + " " +
              number_to_percentage(course.progress(current_user), precision: 0)
          end
        end
      elsif course.price.positive?
        link_to number_to_currency(course.price), new_course_enrollment_path(course), class: 'btn btn-md btn-success'
      else
        link_to 'Free', new_course_enrollment_path(course), class: 'btn btn-md btn-success'
      end
    else
      link_to 'Check price', course_path(course), class: 'btn btn-md btn-success'
    end
  end

  def review_button(course)
    user_course = course.enrollments.where(user: current_user)
    if current_user
      if user_course.any?
        if user_course.pending_review.any?
          link_to edit_enrollment_path(user_course.first) do
            'Add a review'
          end
        else
          link_to enrollment_path(user_course.first) do
            "<i class='fa fa-check'></i>".html_safe + " " +
              'Thanks for reviewing! Your review'
          end
        end
      end
    end
  end

  def certificate_button(course)
    user_course = course.enrollments.where(user: current_user)
    if current_user
      if user_course.any?
        if @course.progress(current_user) == 100
          link_to 'Certificate', certificate_enrollment_path(user_course.first, format: :pdf), class: 'btn btn-sm btn-danger'
        else
          'Complete the course to view certificate'
        end
      end
    end
  end

end
