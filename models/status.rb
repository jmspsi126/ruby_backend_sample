class Status
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: 'status'

end
