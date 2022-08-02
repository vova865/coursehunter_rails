# frozen_string_literal: true

class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :confirmable, :omniauthable, omniauth_providers: [:google_oauth2]

  ONLINE_PERIOD = 5.minutes

  scope :online, -> { where('updated_at > ?', ONLINE_PERIOD.ago) }

  rolify

  has_many :courses, dependent: :nullify
  has_many :enrollments, dependent: :nullify
  has_many :user_lessons, dependent: :nullify

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(email: data['email']).first

    # Uncomment the section below if you want users to be created if they don't exist
    if user
      user.name = access_token.info.name
      user.provider = access_token.provider
      user.uid = access_token.uid
      user.image = access_token.info.image
      user.token = access_token.credentials.token
      user.expires_at = access_token.credentials.expires_at
      user.expires = access_token.credentials.expires
      user.refresh_token = access_token.credentials.refresh_token
      user.save!
    else
      user = User.create(
        email: data['email'],
        password: Devise.friendly_token[0,20],
        confirmed_at: Time.now
      )
    end
    user
  end

  def to_s
    email
  end

  after_create :assign_default_role
  after_create do
    UserMailer.new_user(self).deliver_later
  end

  def assign_default_role
    if User.count == 1
      self.add_role(:admin) if self.roles.blank?
      self.add_role(:student)
    elsif self.roles.blank?
      self.add_role(:student)
      self.add_role(:teacher)
    end
  end

  validate :must_have_a_role, on: :update

  def online?
    updated_at > ONLINE_PERIOD.ago
  end

  def buy_course(course)
    self.enrollments.create(course: course, price: course.price)
  end

  def view_lesson(lesson)
    user_lesson = self.user_lessons.where(lesson: lesson)
    if user_lesson.any?
      user_lesson.first.increment!(:impressions)
    else
      self.user_lessons.create(lesson: lesson)
    end
  end

  def calculate_balance
    update_column :course_income, courses.map(&:income).sum
    update_column :enrollment_expences, enrollments.map(&:price).sum
    update_column :balance, (course_income - enrollment_expences)
  end

  private

  def must_have_a_role
    unless roles.any?
      errors.add(:roles, 'Must have at least one role')
    end
  end

end
