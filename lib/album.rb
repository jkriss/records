class Album < Ohm::Model
  
  attribute :name
  attribute :year
  reference :artist, :Artist
  set :tracks, :Track
  
  index :name
  
end