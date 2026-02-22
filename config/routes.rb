Rails.application.routes.draw do
  devise_for :users,
    path: "",
    path_names: {
      sign_in: "api/login",
      sign_out: "api/logout"
    },
    controllers: {
      sessions: "sessions"
    }

  namespace :api do
    resources :users, only: [ :create ]
    resources :master_products
    resources :shops do
      resources :products
      resources :orders
    end
  end
end
