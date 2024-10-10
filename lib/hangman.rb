require_relative 'game'

game = Game.new
game.show_ui
until game.game_over?
  input = game.gets_input
  game.evaluate(input)
  game.show_ui
end
