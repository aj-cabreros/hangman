class Game
  attr_reader :solution
  attr_accessor :tries

  def initialize
    puts 'Welcome to hangman!'
    random = Random.new
    random_line = random.rand(9893) # Because apparently the txt file isn't 10k words
    @solution = IO.readlines('google-10000-english-no-swears.txt')[random_line].upcase.chomp
    @guess_array = [] # @solution.chars
    @tries = 7

    @solution.length.times { @guess_array.push '_' }
  end

  def show_ui
    word_ui = @guess_array.join(' ')
    puts "\n===================\n"
    puts "[#{word_ui.upcase}]"
    puts "tries left: #{@tries}"
    puts "Guess a letter or the #{solution.length} letter word"
  end

  def gets_input
    input = gets.upcase.chomp
    input = gets.upcase.chomp until valid?(input)
    input
  end

  def valid?(input)
    if input.empty? || input.nil?
      puts 'Nothing was entered'
      return false
    elsif input.match?(/\W/) || input.match?(/\d/)
      puts 'Only english alphabet characters allowed'
      return false
    elsif input.length != 1 && input.length != @solution.length
      puts 'Input length is not 1 nor same length of the word'
      return false
    end
    true
  end

  def evaluate(input)
    if input.length == 1
      input_is_char(input)
    elsif input.length == solution.length
      input_is_str(input)
    end
  end

  def input_is_char(char)
    if solution.match?(char)
      solution.each_char.with_index do |letter, index|
        @guess_array[index] = char if letter.eql?(char)
      end
    else
      puts "There is no '#{char}' in the solution"
      @tries -= 1
    end
  end

  def input_is_str(str)
    puts solution.eql?(str)
    if solution.eql?(str)
      solution.each_char.with_index do |letter, index|
        @guess_array[index] = letter
      end
    else
      "The word '#{str}' is not the solution"
      @tries -= 1
    end
  end

  def game_over?
    if solution.eql?(@guess_array.join)
      puts "\n=====YOU WIN=====\n"
      true
    elsif tries.zero?
      puts "\n=====YOU LOSE====="
      puts "solution: #{@solution}\n\n"
      true
    else
      false
    end
  end
end
