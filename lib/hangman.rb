require_relative 'game'

puts 'Welcome to Hangman!'
game = Game.new

until game.game_over?
  game.show_ui
  input = game.gets_input
  game.evaluate(input)

end
