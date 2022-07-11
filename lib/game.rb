# frozen_string_literal: true

require_relative 'board'
require_relative 'piece'

class Game
  SAVE_PATH = '../../saves/save.dat'

  attr_reader :history, :players, :active_player, :board

  def initialize
    Dir.mkdir '../../saves' unless Dir.exist?('../../saves')
    setup
    load_prompt
  end

  def run
    game_loop
  end

  private

  def game_loop
    turn = 1
    loop do
      process_turn(turn)
      turn += 1 if @active_player.zero?
      save_game
      quit_prompt
    end
  end

  def check_check(player)

  end

  def process_turn(turn)
    colors = %w[white black]
    board.print_board
    @history << "#{turn}." if @active_player.zero?
    puts "It is #{colors[active_player]}'s turn."
    moved_piece = process_move
    @history << "#{map_move_to_notation(moved_piece, moved_piece.position.value)} "
    board.print_board
  end

  def process_move
    @active_player = @players.rotate![0]
    input_move
  end

  def load_prompt
    puts 'Would you like to load the game from savedata?'
    load_game if input_yesno
  end

  def load_game
    savedata = Marshal.load(File.binread(Game::SAVE_PATH))
    params = [savedata.history, savedata.players, savedata.active_player, savedata.board]
    setup(params)
  end

  def setup(params = [+'', [0, 1], 0, Board.new])
    @history = params[0]
    @players = params[1]
    @active_player = params[2]
    @board = params[3]
  end

  def quit_prompt
    puts 'Would you like to take a break?'
    exit if input_yesno
  end

  def save_game
    File.open(SAVE_PATH, 'wb') do |file|
      file.write(Marshal.dump(self))
    end
  end

  def input_move
    piece = input_piece
    destination = input_destination(piece)
    puts "You are moving the #{piece.class.name} on #{map_square_to_coords(piece.position.value)}."
    puts "It will move to #{map_square_to_coords(destination)}."
    puts 'Would you like to reconsider?'
    return board.move_piece(destination, piece) unless input_yesno

    input_move
  end

  def input_destination(piece)
    puts 'Where would you like to move?'
    destination = input_square
    return destination if piece.square_legal?(destination)

    puts "The #{piece.class.name} can't move to that square."
    input_destination
  end

  def input_piece
    puts 'From which square would you like to move?'
    origin = input_square
    content = board.square_content(origin)
    return content if content && content.team == @players[1]

    puts "You don't have a piece on that square."
    input_piece
  end

  def input_type
    piece_types = [Pawn, Rook, Knight, Bishop, Queen, King]
    chosen_type = gets.chomp until piece_types.any? { |type| type.name.downcase == chosen_type.downcase }
    piece_types.select { |type| type.name.downcase == chosen_type.downcase }
  end

  def input_square
    files = ('a'..'g').to_a
    square = gets.chomp until match_coords(square)
    rank = square[1].to_i - 1
    file = files.index(square[0])

    [rank, file]
  end

  def input_yesno
    ans = gets.chomp.downcase until %w[y n].include?(ans)
    return true if ans == 'y'

    false
  end

  def match_coords(input)
    regex = Regexp.new('[a-g][1-8]')
    regex.match input
  end

  def map_square_to_coords(square)
    files = ('a'..'g').to_a
    rank = square[0]
    file = square[1]
    "#{files[file]}#{rank + 1}"
  end

  def map_move_to_notation(piece, move)
    piece_map = {
      'Pawn' => '',
      'Rook' => 'R',
      'Knight' => 'N',
      'Bishop' => 'B',
      'Queen' => 'Q',
      'King' => 'K'
    }
    "#{piece_map[piece.class.name]}#{map_square_to_coords(move)}"
  end
end
