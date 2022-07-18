# frozen_string_literal: true

Rails.application.routes.draw do
  resources :enrollments
  devise_for :users
  resources :courses do
    get :purchased, :pending_review, on: :collection
    resources :lessons
    resources :enrollments, only: %i[new create]
  end
  resources :users, only: %i[index edit destroy show update]
  root to: 'static_pages#landing_page'
  get 'privacy_policy', to: 'static_pages#privacy_policy'
  get 'static_pages/activity'
end
