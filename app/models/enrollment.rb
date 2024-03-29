class Enrollment < ApplicationRecord
  belongs_to :course, counter_cache: true
  # Course.find_each { |course| Course.reset_counters(course.id, :enrollments) }
  belongs_to :user, counter_cache: true
  # User.find_each { |user| User.reset_counters(user.id, :enrollments) }

  validates :user, :course, presence: true

  validates_presence_of :rating, if: :review?
  validates_presence_of :review, if: :rating?

  validates_uniqueness_of :user_id, scope: :course_id
  validates_uniqueness_of :course_id, scope: :user_id

  validate :cant_subscribe_to_own_course

  scope :pending_review, -> { where(rating: [0, nil, ''], review: [0, nil, '']) }
  scope :reviewed, -> { where.not(review: [0, nil, '']) }

  after_save do
    unless rating.nil? || rating.zero?
      course.update_rating
    end
  end

  after_destroy do
    course.update_rating
  end

  after_create :calculate_balance
  after_destroy :calculate_balance

  def calculate_balance
    course.calculate_income
    user.calculate_enrollment_expences
  end

  protected

  def cant_subscribe_to_own_course
    if self.new_record?
      if self.user_id.present?
        if user_id == course.user_id
          errors.add(:base, "You can't subscribe to your own course")
        end
      end
    end
  end
end
