Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    resources :products, except: %i[new edit]
    resources :categories, except: %i[new edit]
  end
end
