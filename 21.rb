$stdout.sync = true # To display output immediately on windows

require 'colorize'

require_relative 'ux_amplifiers'
require_relative 'participants'
require_relative 'round'
require_relative 'scorecard'

class TwentyOneGame
  include UXAmplifiers

  WIN_SCORE = 3
  SAFE_LIMIT = 21
  SHOW_CARDS_WIDTH = 15

  attr_reader :player, :dealer, :scorecard, :current_round
  private :player, :dealer, :scorecard, :current_round

  def initialize
    display_welcome_message
    setup_participants
  end

  # rubocop:disable Metrics/AbcSize
  def play
    setup_scorecard

    loop do
      setup_round

      current_round.play

      scorecard.update_score(current_round.winner)
      scorecard.display_scorecard
      display_divider

      break display_game_winner_message if game_won?
      enter_to_next_round
    end

    reset
    play_again? ? play : display_goodbye_message
  end
  # rubocop:enable Metrics/AbcSize

  private

  def display_welcome_message
    display_clear_screen
    puts <<~welcome
    Let's play a simplified version of blackjack called 21
    The first to win #{"#{WIN_SCORE} ROUNDS".red.underline} is the CHAMPION
    welcome
    puts nil
  end

  def setup_participants
    @player = Player.new
    @dealer = Dealer.new
  end

  def setup_scorecard
    @scorecard = Scorecard.new(player, dealer)
  end

  def setup_round
    @current_round = Round.new(player, dealer, scorecard)
  end

  def game_won?
    player_score = scorecard.score[:player]
    dealer_score = scorecard.score[:dealer]

    player_score >= WIN_SCORE || dealer_score >= WIN_SCORE
  end

  def display_game_winner_message
    puts nil
    if scorecard.score[:player] >= WIN_SCORE
      puts "#{player.name} is crowned as the champion"
    else
      puts 'Take that. You messed with the wrong person'
    end
    puts nil
  end

  def reset
    Round.reset_round_number
  end

  def play_again?
    prompt('Do you want to play again? (y or n)')
    loop do
      play_again = gets.chomp

      return true if %w[y yes].include?(play_again.strip.downcase)
      return false if %w[n no].include?(play_again.strip.downcase)

      prompt("Sorry, '#{play_again}' is invalid. Answer with y or n")
    end
  end

  def display_goodbye_message
    puts nil
    puts "Thank you for playing Twenty-One. Have a nice day"
    puts nil
  end
end

TwentyOneGame.new.play
