Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users, only: %i[index update]
    end

    namespace :v2 do
      resources :users, only: %i[index update]
    end
  end
end
