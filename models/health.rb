class Health
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: 'health'

end
