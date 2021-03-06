# frozen_string_literal: true

class Lesson < ApplicationRecord
  include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller.current_user }

  include RankedModel
  ranks :row_order, with_same: :course_id

  has_many :user_lessons, dependent: :destroy

  belongs_to :course, counter_cache: true
  # Course.find_each { |course| Course.reset_counters(course.id, :lessons) }
  validates :title, :content, :course, presence: true
  validates :video, content_type: ['video/mp4'], size: { less_than: 50.megabytes }
  validates :video_thumbnail, presence: true, if: :video_present?

  has_rich_text :content
  has_one_attached :video
  has_one_attached :video_thumbnail

  def video_present?
    self.video.present?
  end

  def to_s
    title
  end

  def viewed(user)
    self.user_lessons.where(user: user).present?
  end
end
