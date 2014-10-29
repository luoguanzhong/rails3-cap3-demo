Demo::Application.routes.draw do
  get 'test', :to => "test#index", :as => "test_index"
end
