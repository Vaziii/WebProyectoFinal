Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    post "users/register", to: "users#register"

    resources :products, except: %i[new edit]
    resources :categories, except: %i[new edit]
  end
end