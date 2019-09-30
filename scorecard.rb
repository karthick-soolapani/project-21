class Scorecard
  include UXAmplifiers
  attr_reader :score

  def initialize(player, dealer)
    @player = player
    @dealer = dealer
    @score = { player: 0, dealer: 0, tie: 0 }
    @round_number = 1
  end

  def update_score(winner)
    @score[winner] += 1
  end

  def display_scorecard
    win_score = TwentyOneGame::WIN_SCORE
    score_array = ["#{@player.name} - #{score[:player]}/#{win_score}",
                   "#{@dealer.name} - #{score[:dealer]}/#{win_score}",
                   "#{'Tie'.yellow} - #{score[:tie]}"]
    formatted_scores = score_array.join(' | ')

    puts formatted_scores
  end
end
