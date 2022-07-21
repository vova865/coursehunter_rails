# frozen_string_literal: true

class Course < ApplicationRecord
  include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller.current_user }

  validates :title, :short_description, :language, :price, :level, presence: true
  validates :description, presence: true, length: { minimum: 5 }
  validates :title, uniqueness: true

  belongs_to :user, counter_cache: true
  # User.find_each { |user| User.reset_counters(user.id, :courses) }
  has_many :lessons, dependent: :destroy
  has_many :enrollments

  has_rich_text :description

  has_one_attached :image

  LANGUAGES = [:"English", :"Spanish", :"Russian"]
  def self.languages
    LANGUAGES.map { |language| [language, language] }
  end

  LEVELS = [:"Beginner", :"Intermediate", :"Advanced"]
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
      update_column :average_rating, enrollments.average(:rating).round(2).to_f
    else
      update_column :average_rating, 0
    end
  end
end
