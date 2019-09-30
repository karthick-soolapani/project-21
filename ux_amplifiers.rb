module UXAmplifiers
  def prompt(msg)
    puts "=> #{msg}".blue
  end

  def display_divider
    40.times { print '-' }
    puts nil
  end

  def display_clear_screen
    puts "\e[H\e[2J"
  end

  def enter_to_next_round
    puts nil
    prompt('Press enter/return to go to next round...')
    gets
  end

  def format_number(num)
    num = format('%.2f', num)
    num.to_f == num.to_i ? format('%g', num) : num
  end
end