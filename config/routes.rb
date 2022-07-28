# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  resources :enrollments do
    get :my_students, on: :collection
  end
  resources :courses do
    get :purchased, :pending_review, :created, :for_admin_all, on: :collection
    member do
      get :analytics
      patch :approve
      patch :unapprove
    end
    resources :lessons do
      member do
        delete :delete_video
      end
    end
    resources :enrollments, only: %i[new create]
  end
  resources :users, only: %i[index edit destroy show update]
  root to: 'static_pages#landing_page'
  get 'privacy_policy', to: 'static_pages#privacy_policy'
  get 'static_pages/activity'
  get 'analytics', to: 'static_pages#analytics'
  resources :youtube, only: :show

  namespace :charts do
    get 'users_per_day'
    get 'money_makers'
  end
end
