class Artist < Ohm::Model
  
  attribute :name
  set :albums, :Album
  set :collection, :Album
  
  index :name
  
end