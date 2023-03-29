Rails.application.routes.draw do
  post '/block' => 'block#create'
end
