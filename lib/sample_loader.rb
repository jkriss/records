require 'digest/md5'

class SampleLoader
  
  def self.entries
    # Rollins, Sonny  Sonny Rollins with the Modern Jazz Quartet  Mambo Bounce  1953  Digable Planets Time & Space  Reachin' (A New Refutation Of Time And Space) 1993  jazz

    File.open('./data/samples+genres.txt').each_line do |line|
      begin
        entry = line.split("\t")
      rescue => e
        warn line
        raise e
      end
      data = {
        :sampled_artist => normalize_name(entry[0]),
        :sampled_album => normalize_album(entry[1], entry[2]),
        :sampled_track => entry[2],
        :sampled_album_release_year => entry[3],
        :sampling_artist => entry[4],
        :sampling_track => entry[5],
        :sampling_album => normalize_album(entry[6], entry[5]),
        :sampling_album_release_year => entry[7],
        :sampled_album_genre => entry[8]
      }
      yield Hashie::Mash.new(data)
    end
  end
  
  def self.normalize_name(name)
    # undo Last, First form
    if matches = /([^,()]+), ([^()]*+)/.match(name)
      "#{matches[2]} #{matches[1]}"
    else
      name
    end
  end
  
  def self.normalize_album(album, track)
    album == "" || album == "single" ? track : album
  end
  
end