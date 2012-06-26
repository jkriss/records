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
    ids = Ohm.redis.zrevrange similar_key, 0, 9#, :with_scores => true
  end
  
  def similar(max=10)
    similar_ids[0,max].collect{ |id| Artist[id] }
  end
  
  def trim_similar(max=10)
    Ohm.redis.zremrangebyrank similar_key, 0, ((max+1)*-1)
  end
  
  def clear_similar
    Ohm.redis.zrange(similar_key, 0,-1).each do |element|
      Ohm.redis.zrem similar_key, element
    end
  end
  
  private
  def similar_key
    @similar_key ||= "artist:#{id}:similar"
  end
  
end