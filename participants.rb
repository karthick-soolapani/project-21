class Participant
  include UXAmplifiers

  VALID_CHOICES = %w[hit stay]

  attr_reader :name, :cards, :choice
  attr_accessor :total

  def initialize
    set_name
    @cards = []
  end

  def calculate_total(cards = self.cards)
    num_of_aces = cards.count(&:ace?)
    total = cards.map(&:value).sum

    num_of_aces.times { total -= 10 if total > TwentyOneGame::SAFE_LIMIT }
    total
  end

  def stay?
    choice == 'stay'
  end

  def busted?
    total > TwentyOneGame::SAFE_LIMIT
  end

  def >(other)
    total > other.total
  end

  def <(other)
    total < other.total
  end

  def ==(other)
    total == other.total
  end

  def reset
    @cards = []
    @choice = nil
  end
end

class Player < Participant
  PLAYER_THRESHOLD = 17
  CRITICAL_BUST_PERCENTAGE = 65
  RISKY_BUST_PERCENTAGE = 50

  def choose_move
    player_choice = nil
    loop do
      prompt("Do you want to (h)it or (s)tay?")
      player_choice = gets.chomp

      break if valid_choice?(player_choice.strip.downcase)
      puts "'#{player_choice}' is not a valid choice"
    end

    @choice = retrieve_valid(player_choice.strip.downcase)
  end

  def display_safe_points_left
    difference = TwentyOneGame::SAFE_LIMIT - total

    if total >= PLAYER_THRESHOLD
      puts "Safe points left = #{difference.to_s.red}"
    else
      puts "Safe points left = #{difference.to_s.green}"
    end
  end

  def display_bust_probability(remaining_cards)
    probability = calculate_bust_probability(remaining_cards)
    percentage = probability * 100
    formatted_percentage = format_number(percentage)

    if percentage >= CRITICAL_BUST_PERCENTAGE
      puts "Probability of bust = #{"#{formatted_percentage}%".red}"
    elsif percentage >= RISKY_BUST_PERCENTAGE
      puts "Probability of bust = #{"#{formatted_percentage}%".yellow}"
    else
      puts "Probability of bust = #{"#{formatted_percentage}%".green}"
    end

    puts nil
  end

  private

  def set_name
    prompt("How would you like me to call you?")
    answer = gets.chomp

    if answer.strip.empty?
      answer = %w[Dovahkiin Neo Samus Rambo Achilles].sample
      puts "Alright, we will call you #{answer.green} then..."
      sleep(1)
    else
      puts "Hello, #{answer.strip.capitalize.green}"
    end

    @name = answer.strip.capitalize.green
  end

  def calculate_bust_probability(remaining_cards)
    bust_arr = remaining_cards.map do |card|
      new_cards = cards + [card]
      cards_total = calculate_total(new_cards)
      cards_total > TwentyOneGame::SAFE_LIMIT ? 1 : 0
    end

    (bust_arr.sum.to_f / bust_arr.size).round(4)
  end

  def valid_choice?(player_choice)
    return false if player_choice.empty?
    VALID_CHOICES.any? { |choice| choice.start_with?(player_choice) }
  end

  def retrieve_valid(player_choice)
    VALID_CHOICES.each do |choice|
      return choice if choice.start_with?(player_choice)
    end
  end
end

class Dealer < Participant
  DEALERS = %w[GLaDOS Pikachu YoRHa-2B HAL-9000 Alita]
  DEALER_THRESHOLD = 17

  def choose_move
    puts nil
    print "#{name} is thinking"

    2.times do
      print '...'
      sleep(1)
    end
    puts nil

    @choice = total < DEALER_THRESHOLD ? 'hit' : 'stay'
  end

  def partial_total
    cards[0].value
  end

  private

  def set_name
    @name = DEALERS.sample.red
  end
end
