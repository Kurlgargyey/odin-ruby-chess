# frozen_string_literal: true

require_relative 'board'
require_relative 'piece'

class Game
  def initialize
    @history = +''
    @players = [0, 1]
    @active_player = 0
    @board = Board.new
  end

  def run
    turn = 1
    board.print_board
    moved_piece = process_turn
    @history << "#{turn}.#{map_move_to_notation(moved_piece, moved_piece.position.value)} "
    board.print_board
    moved_piece = process_turn
    @history << "#{map_move_to_notation(moved_piece, moved_piece.position.value)} "
    turn += 1
  end

  private

  attr_reader :board

  def process_turn
    @active_player = @players.rotate![0]
    input_move
  end

  def input_move
    piece = input_piece
    destination = input_destination(piece)
    puts "You are trying to move the #{piece.class.name} on #{map_square_to_coords(piece.position.value)}."
    puts "It will move to #{map_square_to_coords(destination)}."
    puts 'Would you like to reconsider?'
    ans = input_yesno
    return board.move_piece(destination, piece) unless ans

    input_move
  end

  def input_destination(piece)
    puts 'Where would you like to move?'
    validate_destination(piece)
  end

  def input_piece
    puts 'From which square would you like to move?'
    origin = input_square
    board.square_content(origin)
  end

  def validate_destination(piece)
    destination = input_square
    until piece.square_legal?(destination)
      puts "The #{piece.class.name} can't move to that square."
      destination = input_square
    end
    destination
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
