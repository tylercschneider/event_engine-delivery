Rails.application.routes.draw do
  mount EventEngine::Engine => "/event_engine"
end
