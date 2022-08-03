# frozen_string_literal: true

class Course < ApplicationRecord
  include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller.current_user }

  validates :title, :short_description, :language, :price, :level, presence: true
  validates :description, presence: true, length: { minimum: 5 }
  validates :title, uniqueness: true
  validates :image, presence: true, content_type: %i[png jpg jpeg],
                    size: { less_than: 1.megabytes, message: 'size should be under 1 megabytes' }
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  belongs_to :user, counter_cache: true
  # User.find_each { |user| User.reset_counters(user.id, :courses) }
  has_many :lessons, dependent: :destroy, inverse_of: :course
  has_many :enrollments, dependent: :restrict_with_error
  has_many :user_lessons, through: :lessons
  accepts_nested_attributes_for :lessons, reject_if: :all_blank, allow_destroy: true

  has_rich_text :description

  has_one_attached :image

  scope :published, -> { where(published: true) }
  scope :unpublished, -> { where(published: false) }
  scope :approved, -> { where(approved: true) }
  scope :unapproved, -> { where(approved: false) }

  LANGUAGES = %i[English Spanish Russian]
  def self.languages
    LANGUAGES.map { |language| [language, language] }
  end

  LEVELS = %i[Beginner Intermediate Advanced]
  def self.levels
    LEVELS.map { |level| [level, level] }
  end

  def to_s
    title
  end

  def bought(user)
    self.enrollments.where(user_id: [user.id], course_id: [self.id]).empty?
  end

  def update_rating
    if enrollments.any? && enrollments.where.not(rating: nil)
      update_column :average_rating, enrollments.average(:rating).to_f.round(2)
    else
      update_column :average_rating, 0
    end
  end

  def progress(user)
    unless self.lessons_count == 0
      user_lessons.where(user: user).count / self.lessons_count.to_f * 100
    end
  end

  def calculate_income
    update_column :income, enrollments.map(&:price).sum
    user.calculate_balance
  end

end
