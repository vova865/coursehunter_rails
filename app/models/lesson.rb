# frozen_string_literal: true

class Lesson < ApplicationRecord
  include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller.current_user }

  has_many :user_lessons

  belongs_to :course, counter_cache: true
  # Course.find_each { |course| Course.reset_counters(course.id, :lessons) }
  validates :title, :content, :course, presence: true

  has_rich_text :content

  def to_s
    title
  end

  def viewed(user)
    self.user_lessons.where(user: user).present?
  end
end