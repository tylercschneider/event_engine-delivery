module EventEngine
  module Delivery
    class ApplicationRecord < ActiveRecord::Base
      self.abstract_class = true
    end
  end
end
