# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations', omniauth_callbacks: 'users/omniauth_callbacks'
  }
  resources :enrollments do
    get :my_students, on: :collection
    get :certificate, on: :member
  end
  resources :courses, except: [:edit] do
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
    resources :course_wizard, controller: 'courses/course_wizard'
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
