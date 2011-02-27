class Player < ActiveRecord::Base
  belongs_to :country
  validates_associated :country
  validates_presence_of :display_name
  validates_presence_of :short_name
  validates_presence_of :role
  has_many :batting_score_cards do
    def score
      total_score = 0
      find_all.each {|match| total_score += match.score.to_i}
      total_score
    end

    def fours
      total_fours = 0
      find_all.each {|match| total_fours += match.fours.to_i}
      total_fours
    end

    def sixes
      total_sixes = 0
      find_all.each {|match| total_sixes += match.sixes.to_i}
      total_sixes
    end
  end

  has_many :bowling_score_cards do
    def wickets
      total_wickets = 0
      find_all.each {|match| total_wickets += match.wickets.to_i}
      total_wickets
    end

    def maidens
      total_maidens = 0
      find_all.each {|match| total_maidens += match.maidens.to_i}
      total_maidens
    end

    def overs
      total_overs = 0
      find_all.each {|match| total_overs += match.overs.to_i}
      total_overs
    end

    def extras
      total_extras = 0
      find_all.each {|match| total_extras += match.extras.to_i}
      total_extras
    end
  end

  has_many :player_match_points do 
    def total
      total_points = 0
      find_all.each {|match| total_points += match.points} 
      total_points
    end
  end

  def self.played_match_country_one(match_id)
    Player.find_by_sql(["select * from players p where p.id in (select player_id from batting_score_cards b where b.match_id = ?) and p.country_id = (select m.country_one_id from matches m where m.id = ?)", match_id, match_id])
  end

  def self.played_match_country_two(match_id)
    Player.find_by_sql(["select * from players p where p.id in (select player_id from batting_score_cards b where b.match_id = ?) and p.country_id = (select m.country_two_id from matches m where m.id = ?)", match_id, match_id])
  end
end
