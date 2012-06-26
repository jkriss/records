class Artist < Ohm::Model
  
  attribute :name
  set :albums, :Album
  set :collection, :Album
  
  index :name
  
  def similar=(scores_and_ids)
    scores_and_ids.each do |pair|
      add_similar(pair[0], pair[1])
    end
  end
  
  def add_similar(score, artist)
    Ohm.redis.zadd similar_key, score, artist.id if Ohm.redis.zscore(similar_key, artist.id).nil?
  end
  
  def similar_ids
    ids = Ohm.redis.zrange similar_key, 0, -1#, :with_scores => true
    ids.reverse!
  end
  
  def similar(max=10)
    similar_ids[0,max].collect{ |id| Artist[id] }
  end
  
  private
  def similar_key
    @similar_key ||= "artist:#{id}:similar"
  end
  
end