class Album < Ohm::Model
  
  attribute :name
  attribute :year
  reference :artist, :Artist
  set :tracks, :Track
  
  set :in_collection_of, :Artist
  
  index :name
  
end