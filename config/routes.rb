# frozen_string_literal: true

Rails.application.routes.draw do
  root 'sessions#new'

  post 'sign_up', to: 'users#create'
  get 'sign_up', to: 'users#new'

  get 'account', to: 'users#show'

  get 'settings', to: 'users#edit'
  put 'settings', to: 'users#update'

  delete 'account', to: 'users#destroy'

  # confirmations POST   /confirmations(.:format)  confirmations#create
  # new_confirmation GET    /confirmations/new(.:format)  confirmations#new
  # edit_confirmation GET    /confirmations/:confirmation_token/edit(.:format)  confirmations#edit
  # The :param option overrides the default resource identifier :id
  # You can access that segment from your controller using params[<:param>].
  resources :confirmations, only: %i[create edit new], param: :confirmation_token

  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  get 'login', to: 'sessions#new'

  resources :passwords, only: %i[create edit new update], param: :password_reset_token

  # destroy_all_active_sessions DELETE /active_sessions/destroy_all(.:format)  active_sessions#destroy_all
  resources :active_sessions, only: [:destroy] do
    collection do
      delete 'destroy_all'
    end
  end
end
