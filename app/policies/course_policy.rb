# frozen_string_literal: true

class CoursePolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.all
    end
  end

  def show?
    @record.published && @record.approved || @user.present? && @user.has_role?(:admin) ||
      @record.user_id == @user.id && @user.present? ||
      @user.present? && @record.bought(@user)
  end

  def edit?
    @record.user_id == @user.id
  end

  def destroy?
    @user.has_role?(:admin) || @record.user_id == @user.id
  end

  def update?
    @record.user_id == @user.id
  end

  def create?
    @user.has_role?(:teacher)
  end

  def new?
    @user.has_role?(:teacher)
  end

  def approve?
    @user.has_role?(:admin)
  end

  def owner?
    @record.user_id == @user.id
  end
end
