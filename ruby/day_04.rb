class Day04
  require 'digest'
  def self.hash(key, zeroes)
    num = 0
    zeroes = '0' * zeroes
    loop do
      num += 1
      return num if Digest::MD5.hexdigest(key + num.to_s).start_with?(zeroes)
    end
  end
end
