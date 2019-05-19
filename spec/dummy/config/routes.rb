# frozen_string_literal: true

Rails.application.routes.draw do
  resources :document_report, only: [] do
    get :error_status, on: :collection
  end
end
