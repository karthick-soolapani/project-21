class Deck
  attr_reader :cards

  def initialize
    @cards = []
    total_cards = Card::SUITS.product(Card::CARD_VALUES.keys)
    total_cards.each { |suit, number| @cards << Card.new(suit, number) }
    @cards.shuffle!
  end

  def deal_one
    @cards.pop
  end
end

class Card
  CARD_VALUES = { '2' => 2, '3' => 3, '4' => 4, '5' => 5, '6' => 6, '7' => 7,
                  '8' => 8, '9' => 9, '10' => 10, 'J' => 10, 'Q' => 10,
                  'K' => 10, 'A' => 11 }
  SUITS = %w[Spade Hearts Diamond Clubs]
  COLORS = { 'Spade' => :light_black, 'Hearts' => :red, 'Diamond' => :red,
             'Clubs' => :light_black }

  attr_reader :suit, :number, :value, :symbol, :color
  private :suit, :number, :symbol

  def initialize(suit, number)
    @suit = suit
    @number = number
    @value = CARD_VALUES[number]
    @symbol = determine_symbol
    @color = COLORS[suit]
  end

  def determine_symbol
    case suit
    when 'Spade'    then "\u2660".unicode_normalize
    when 'Hearts'   then "\u2665".unicode_normalize
    when 'Diamond'  then "\u2666".unicode_normalize
    when 'Clubs'    then "\u2663".unicode_normalize
    end
  end

  def ace?
    @number == 'A'
  end

  def to_s
    "#{number} #{symbol}"
  end
end
