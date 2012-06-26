class Track < Ohm::Model
  
  attribute :name
  reference :album, :Album
  set :sampled_by, :Track
  set :samples, :Track
  
  index :name
  index :album_id
  
end