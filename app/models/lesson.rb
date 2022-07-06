class Lesson < ApplicationRecord
  include PublicActivity::Model
  tracked owner: Proc.new{ |controller, model| controller.current_user }

  belongs_to :course
  validates :title, :content, :course, presence: :true

  def to_s
    title
  end
end
