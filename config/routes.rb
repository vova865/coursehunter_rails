# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users
  resources :enrollments do
    get :my_students, on: :collection
  end
  resources :courses do
    get :purchased, :pending_review, :created, on: :collection
    resources :lessons
    resources :enrollments, only: %i[new create]
  end
  resources :users, only: %i[index edit destroy show update]
  root to: 'static_pages#landing_page'
  get 'privacy_policy', to: 'static_pages#privacy_policy'
  get 'static_pages/activity'
  get 'analytics', to: 'static_pages#analytics'

  namespace :charts do
    get 'users_per_day'
    get 'money_makers'
  end
end
