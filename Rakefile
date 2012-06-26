require 'rubygems'
require 'bundler'
Bundler.setup
Bundler.require
require './lib/sample_loader.rb'
require './lib/album'
require './lib/artist'
require './lib/track'

def find_or_create(klass, args)
  unless obj = klass.send(:find, args).first
    print '.'
    obj = klass.send(:create, args)
    yield obj if block_given?
  end
  obj
end

task :load_samples do
  %w{load_artists load_albums load_tracks load_collections load_inverse_collections}.each do |task|
    Rake::Task[task].execute
  end
end

task :load_artists do
  
  Ohm.connect
  
  puts "\nloading artists..."
  SampleLoader.entries do |entry|
    # load artists
    find_or_create Artist, :name => entry.sampled_artist
    find_or_create Artist, :name => entry.sampling_artist
  end
  
end

task :load_albums do
  
  Ohm.connect
  
  puts "\nloading albums..."
  SampleLoader.entries do |entry|
    # load albums
    sampled_artist = Artist.find(:name => entry.sampled_artist).first
    album = find_or_create(Album, :name => entry.sampled_album, :artist_id => sampled_artist.id)
    sampled_artist.albums.add(album) unless sampled_artist.albums.include?(album)
    
    sampling_artist = Artist.find(:name => entry.sampling_artist).first
    album = find_or_create(Album, :name => entry.sampling_album, :artist_id => sampling_artist.id)
    sampling_artist.albums.add(album) unless sampled_artist.albums.include?(album)
  end
  
end

task :load_tracks do
  
  Ohm.connect
  
  puts "\nloading tracks..."
  SampleLoader.entries do |entry|

    sampling_artist = Artist.find(:name => entry.sampling_artist).first
    album = sampling_artist.albums.find(:name => entry.sampling_album).first
    sampling_track = find_or_create(Track, :name => entry.sampling_track, :album_id => album.id)
    album.tracks.add(sampling_track) unless album.tracks.include?(sampling_track)

    sampled_artist = Artist.find(:name => entry.sampled_artist).first
    album = sampled_artist.albums.find(:name => entry.sampled_album).first
    sampled_track = find_or_create(Track, :name => entry.sampled_track, :album_id => album.id)
    album.tracks.add(sampled_track) unless album.tracks.include?(sampled_track)
    
    sampling_track.samples.add(sampled_track) unless sampling_track.samples.include?(sampled_track)
    sampled_track.sampled_by.add(sampling_track) unless sampled_track.sampled_by.include?(sampling_track)
  end
  
end

task :load_collections do
  puts "\nloading collections"
  Artist.all.each do |a|
    a.albums.each do |album|
      album.tracks.each do |track|
        track.samples.each do |t| 
          unless a.collection.include?(t.album)
            print '.'
            a.collection.add(t.album) 
          end
        end
      end
    end
  end
  puts
end

task :load_inverse_collections do
  puts "\nloading inverse collections"
  Artist.all.each do |artist|
    print '.'
    artist.collection.each do |album|
      album.in_collection_of.add(artist) unless album.in_collection_of.include?(artist)
    end
  end
  puts
end

task :score_collections do
  puts "\nscoring all collections"
  Artist.all.each do |artist|
    if artist.similar_ids.empty?
      scores = []
      Artist.all.each do |other_artist|
        next if other_artist == artist || other_artist.collection.empty?
        score = Jaccard.coefficient(artist.collection.ids, other_artist.collection.ids)
        artist.add_similar(score, other_artist)
      end
    end
    print '.'
  end
  puts
end

task :find_artist do
  a = Artist.find(:name => ENV['NAME']).first
  a.albums.each{ |a| puts a.name }
end

task :find_album do
  a = Album.find(:name => ENV['NAME']).first
  a.tracks.each do |t| 
    puts
    puts t.name
    unless t.samples.empty?
      t.samples.each do |s|
        puts "    #{s.name} by #{s.album.artist.name} on #{s.album.name}"
      end
    end
    unless t.sampled_by.empty?
      t.sampled_by.each do |s|
        puts "    #{s.name} by #{s.album.artist.name} on #{s.album.name}"
      end
    end
  end
  puts
end

task :find_collection do
  a = Artist.find(:name => ENV['NAME']).first
  rarity_score = 0
  a.collection.each do |album|
    puts "#{album.name} by #{album.artist.name} (#{album.in_collection_of.size})"
    rarity_score += album.in_collection_of.size.to_f
  end
  rarity_score /= a.collection.size
  puts "\nrarity score: #{rarity_score}"
  puts
end

task :find_similar do
  artist = Artist.find(:name => ENV['NAME']).first
  artist.similar(10).each do |other_artist| 
    overlap = (artist.collection.ids & other_artist.collection.ids).size
    puts "#{other_artist.name} (#{overlap})"
  end
end

task :find_overlap do
  a = Artist.find(:name => ENV['A']).first
  b = Artist.find(:name => ENV['B']).first
  albums = a.collection.to_a & b.collection.to_a
  albums.each do |album|
    puts "#{album.name} by #{album.artist.name}"
  end
end

task :in_collection_of do
  a = Album.find(:name => ENV['NAME']).first
  a.in_collection_of.each do |artist|
    puts artist.name
  end
end

task :clear do
  Artist.all.each { |a| a.delete }
  Album.all.each { |a| a.delete }
  Track.all.each { |t| t.delete }
end