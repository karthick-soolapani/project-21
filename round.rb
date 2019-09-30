require_relative 'deck'

class Round
  include UXAmplifiers
  @@round_number = 0

  attr_reader :deck, :player, :dealer, :scorecard, :winner
  private :deck, :player, :dealer, :scorecard

  def initialize(player, dealer, scorecard)
    @player = player
    @dealer = dealer
    @scorecard = scorecard
    @winner = nil
    @@round_number += 1
    reset_participants
  end

  def play
    setup_deck
    deal_initial_cards
    player_turn
    dealer_turn unless player.busted?

    set_winner
    display_clear_screen
    show_cards(dealer_hidden: false)
    display_divider
    display_result
  end

  def self.reset_round_number
    @@round_number = 0
  end

  private

  def setup_deck
    @deck = Deck.new
  end

  def deal_initial_cards
    2.times do
      player.cards << deck.deal_one
      dealer.cards << deck.deal_one
    end

    player.total = player.calculate_total
    dealer.total = dealer.calculate_total
  end

  # rubocop:disable Metrics/AbcSize
  def player_turn
    until player.stay? || player.busted?
      display_clear_screen
      display_round_number
      scorecard.display_scorecard
      show_cards
      display_player_aide

      player.choose_move
      next display_player_stay_message if player.stay?

      hit!(player)
      display_player_hit_message
    end
  end
  # rubocop:enable Metrics/AbcSize

  def dealer_turn
    until dealer.stay? || dealer.busted?
      dealer.choose_move
      next display_dealer_stay_message if dealer.stay?

      hit!(dealer)
      display_dealer_hit_message
    end
  end

  def display_round_number
    width = 32
    puts "[ROUND - #{@@round_number}]".center(width)
  end

  def show_cards(dealer_hidden: true)
    player_cards = player.cards
    dealer_cards = dealer.cards

    size = [player_cards.size, dealer_cards.size].max

    player_cards_formatted = format_cards(player_cards, size)
    dealer_cards_formatted = format_cards(dealer_cards, size)

    hide_one_dealer_card(dealer_cards_formatted) if dealer_hidden

    formatted_cards = player_cards_formatted.zip(dealer_cards_formatted)
    hand_grid = form_hand_grid(formatted_cards)

    adjust_total(hand_grid) if dealer_hidden
    puts hand_grid
  end

  def format_cards(cards, size)
    width = TwentyOneGame::SHOW_CARDS_WIDTH

    formatted_cards = Array.new(size) { String.new.ljust(width) }
    cards.each_with_index do |card, idx|
      num = "#{idx + 1}. "
      if card.ace?
        formatted_cards[idx] = num + card.to_s.ljust(width - 3).blue
      else
        formatted_cards[idx] = num + card.to_s.ljust(width - 3).send(card.color)
      end
    end
    formatted_cards
  end

  # rubocop:disable Metrics/AbcSize
  def form_hand_grid(cards)
    width = TwentyOneGame::SHOW_CARDS_WIDTH

    [nil,
     "Your hand".ljust(width) + '| ' + "Dealer's hand",
     ''.ljust(width, '-') + "+" + ''.ljust(width, '-'),
     cards.map { |arr| arr.join('| ') },
     ''.ljust(width, '=') + "+" + ''.ljust(width, '='),
     "Total = #{player.total}".ljust(width) + "| Total = #{dealer.total}",
     nil]
  end
  # rubocop:enable Metrics/AbcSize

  def hide_one_dealer_card(cards)
    cards[1] = "2. ??".ljust(TwentyOneGame::SHOW_CARDS_WIDTH)
  end

  def adjust_total(hand_grid)
    partial_total = dealer.partial_total
    start = TwentyOneGame::SHOW_CARDS_WIDTH + 10

    hand_grid[-2][start..-1] = "#{partial_total}+"
  end

  def display_player_aide
    player.display_safe_points_left

    remaining_cards = deck.cards + [dealer.cards[1]]
    player.display_bust_probability(remaining_cards)
  end

  def display_player_stay_message
    puts nil
    puts "#{player.name} has chosen to Stay"
    puts "Total hand value = #{player.total}".green
  end

  def display_dealer_stay_message
    puts nil
    puts "#{dealer.name} has chosen to Stay"
    puts "Total hand value = #{dealer.total}".red
  end

  def display_player_hit_message
    puts "#{player.name} has chosen to Hit"
  end

  def display_dealer_hit_message
    puts nil
    puts "#{dealer.name} has chosen to Hit"
    puts "Cards in #{dealer.name}'s hand = #{dealer.cards.size}"
    puts nil
  end

  def hit!(participant)
    participant.cards << deck.cards.shift
    participant.total = participant.calculate_total
  end

  def detect_win_method
    if player.busted?
      :player_busted
    elsif dealer.busted?
      :dealer_busted
    elsif player > dealer
      :player_wins
    elsif player < dealer
      :dealer_wins
    else
      :tie
    end
  end

  def set_winner
    case detect_win_method
    when :player_wins, :dealer_busted then @winner = :player
    when :dealer_wins, :player_busted then @winner = :dealer
    else                                   @winner = :tie
    end
  end

  def display_result
    pl_name = player.name
    dl_name = dealer.name

    case detect_win_method
    when :player_busted then puts "#{pl_name} BUSTED. #{dl_name} wins".red
    when :dealer_busted then puts "#{dl_name} BUSTED. #{pl_name} wins".green
    when :player_wins   then puts "#{pl_name} WINS!".green
    when :dealer_wins   then puts "#{dl_name} wins!".red
    when :tie           then puts "It's a tie".yellow
    end
  end

  def reset_participants
    player.reset
    dealer.reset
  end
end
