require 'json'

class Game
  attr_accessor :solution, :guess_array, :already_guessed, :tries, :exit, :file_name

  def initialize
    random = Random.new
    random_line = random.rand(9893) # Because apparently the txt file isn't 10k words
    @file_name = ''
    @solution = IO.readlines('google-10000-english-no-swears.txt')[random_line].upcase.chomp
    @guess_array = [] # @solution.chars
    @already_guessed = []
    @tries = 7
    @exit = 0

    solution.length.times { @guess_array.push '_' }
  end

  def show_ui
    word_ui = guess_array.join(' ')
    already_guessed.sort!
    guesses_ui = already_guessed.join(' ')
    puts "\n===================\n"
    puts "[#{word_ui.upcase}]"
    puts "Type options: 'load', 'save', 'exit'"
    puts "tries left: #{tries}"
    puts "Guess a letter or the #{solution.length} letter word"
    puts "Already guessed: [#{guesses_ui.upcase}]"
  end

  def load_game
    loop do
      puts '++++++++++++++++++++++++'
      puts 'Type and enter one of following saves:'
      Dir.children('saves').each do |file|
        puts file[0...-5]
      end
      puts 'Or type and enter "q" to quit'

      input = gets.chomp.downcase
      return if input.eql?('q')

      @file_name = "#{input}.json"
      break if File.exist?("./saves/#{file_name}")
    end

    file = File.open("./saves/#{file_name}", 'r')
    hash = JSON.parse(file.read, { symbolize_names: true })
    self.solution = (hash[:solution])
    self.guess_array = (hash[:guess_array])
    self.already_guessed = (hash[:already_guessed])
    self.tries = (hash[:tries])
    file.close
    puts "#{file_name} loaded from 'saves' directory"
  end

  def save_game
    game_object = self
    Dir.mkdir('saves') unless Dir.exist?('saves')
    saves = Dir.new('saves')
    number =
      if Dir.empty?('saves')
        1
      else
        saves.children.max.scan(/[0-9]/).join('').to_i + 1
      end
    @file_name = "save_#{number}.json"
    File.open("./saves/#{file_name}", 'w') do |file|
      hash = game_object.as_json
      file.puts JSON.generate(hash)
    end
    puts "#{file_name} saved to 'saves' directory"
  end

  def as_json(*)
    { solution: solution,
      guess_array: guess_array,
      already_guessed: already_guessed,
      tries: tries,
      exit: 0 }
  end

  def exit_game
    @exit = 1
  end

  def gets_input
    input = gets.upcase.chomp
    input = gets.upcase.chomp until valid?(input)
    input
  end

  def valid?(input)
    if input.eql?('SAVE') || input.eql?('LOAD') || input.eql?('EXIT')
      return true
    elsif input.empty? || input.nil?
      puts 'Nothing was entered'
      return false
    elsif input.match?(/\W/) || input.match?(/\d/)
      puts 'Only english alphabet characters allowed'
      return false
    elsif input.length != 1 && input.length != solution.length
      puts 'Input length is not 1 nor same length of the word'
      return false
    end

    true
  end

  def evaluate(input)
    if input.eql?('SAVE')
      save_game
    elsif input.eql?('LOAD')
      load_game
    elsif input.eql?('EXIT')
      exit_game
    elsif input.length == 1
      input_is_char(input)
    elsif input.length == solution.length
      input_is_str(input)
    end
  end

  def input_is_char(char)
    if already_guessed.any?(char)
      puts "#{char} has already been guessed"
    elsif solution.match?(char)
      solution.each_char.with_index do |letter, index|
        guess_array[index] = char if letter.eql?(char)
      end
    else
      puts "There is no '#{char}' in the solution"
      @tries -= 1
    end
    already_guessed.push char unless already_guessed.any?(char)
  end

  def input_is_str(str)
    puts solution.eql?(str)
    if solution.eql?(str)
      solution.each_char.with_index do |letter, index|
        guess_array[index] = letter
      end
    else
      puts "The word '#{str}' is not the solution"
      @tries -= 1
    end
    already_guessed.push str unless already_guessed.any?(str)
  end

  def game_over?
    if solution.eql?(guess_array.join)
      show_ui
      puts "\n=====YOU WIN=====\n"
      true
    elsif tries.zero?
      show_ui
      puts "\n=====YOU LOSE====="
      puts "solution: #{solution}\n\n"
      true
    elsif !exit.zero?
      puts "\n====EXIT EARLY===="
      true
    else
      false
    end
  end
end
