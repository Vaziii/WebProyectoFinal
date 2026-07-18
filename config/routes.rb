Rails.application.routes.draw do
  namespace :api, defaults: { format: :json } do
    post "users/register", to: "users#register"
    post "users/login", to: "auth#login"

    resources :users,
              only: %i[show update destroy]

    resources :products,
              except: %i[new edit]

    resources :categories,
              except: %i[new edit]

    get "receipts/user/:user_id",
        to: "receipts#by_user"

    resources :receipts,
              only: %i[
                create
                index
                show
                destroy
              ]
  end
end