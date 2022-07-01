class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :trackable, :confirmable

  rolify

  has_many :courses

  def to_s
    email
  end

  after_create :assign_default_role

  def assign_default_role
    if User.count == 1
      self.add_role(:student) if self.roles.blank?
      self.add_role(:teacher)
      self.add_role(:student)
    else
      self.add_role(:student) if self.roles.blank?
      self.add_role(:teacher)
    end 
  end
end