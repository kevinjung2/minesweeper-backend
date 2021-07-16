class Score < ApplicationRecord
  belongs_to :user

  def self.leaderboards
    self.all.sort do |a,b|
      a.time.gsub(":", "").to_i <=> b.time.gsub(":", "").to_i
    end.slice(0..9)
  end
end
