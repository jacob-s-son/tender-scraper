TenderScraper::Application.routes.draw do
  resources :tenders
  root :to => 'tenders#index'
end
