class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :confirmable

  ONLINE_PERIOD = 5.minutes

  scope :online, -> { where('updated_at > ?', ONLINE_PERIOD.ago)}

  rolify

  has_many :courses

  def to_s
    email
  end

  after_create :assign_default_role

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

  private

  def must_have_a_role
    unless roles.any?
      errors.add(:roles, 'Must have at least one role')
    end
  end

end
