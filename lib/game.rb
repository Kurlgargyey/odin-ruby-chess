# frozen_string_literal: true

require_relative 'board'
require_relative 'piece'

class Game
  SAVE_PATH = './saves/save.dat'

  attr_reader :history, :players, :active_player, :board

  def initialize
    Dir.mkdir './saves' unless Dir.exist?('./saves')
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
      puts @history
      board.print_board
      process_turn(turn)
      turn += 1 if @active_player.zero?
      save_game
    end
  end

  def process_turn(turn)
    puts "It is #{%w[white black][active_player]}'s turn."
    exit if over?
    move = process_move
    @history << "#{turn}." if @active_player.zero?
    @history << "#{map_move_to_notation(move)} "
    board.print_board
    @active_player = @players.rotate![0]
  end

  def process_move
    save_game
    moved_piece = input_move
    while check?(@active_player)
      puts 'Try a different move.'
      load_game
      moved_piece = input_move
    end
    moved_piece
  end

  def load_prompt
    puts 'Would you like to load the game from savedata?'
    load_game if input_yesno
  end

  def check?(team)
    king = board.pieces_in_play[team].select do |e|
      e.is_a?(King)
    end[0]
    if king.check?(board)
      puts 'Your king is in check.'
      return true
    end
    false
  end

  def over?
    return true if checkmate?(active_player)
    return true if stalemate?(active_player)
    return true if insufficient_material?

    false
  end

  def checkmate?(team)
    king = board.pieces_in_play[team].select do |e|
      e.is_a?(King)
    end[0]
    if king.checkmate?(board)
      puts 'Your king is in checkmate.'
      return true
    end
    false
  end

  def stalemate?(team)
    board.pieces_in_play[team].each do |piece|
      return false unless piece.position.children.empty?
    end
    puts "You have no legal moves. It's a Stalemate!"
    true
  end

  def insufficient_material?
    material = list_material
    return true if material.empty?
    return true if material.length == 1 && material[0].is_a?(Bishop)
    return true if material.length == 1 && material[0].is_a?(Knight)

    false
  end

  def list_material
    material = []
    @players.each do |team|
      board.pieces_in_play[team].each do |piece|
        material.push(piece)
      end
    end
    material.filter! { |piece| !piece.is_a?(King) }
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
    return move_handler(piece, destination)
  end

  def move_handler(piece, destination)
    check = rochade_check(piece, destination)
    return check if check

    board.move_piece(destination, piece)
  end

  def rochade_check(piece, destination)
    return unless piece.is_a?(King)

    case (piece.position.value[1] - destination[1])
    when -2
      piece.small_rochade(board)
    when 2
      piece.big_rochade(board)
    end
  end

  def input_destination(piece)
    puts 'Where would you like to move?'
    destination = input_square
    return destination if piece.square_legal?(destination)

    puts "The #{piece.class.name} can't move to that square."
    input_destination(piece)
  end

  def input_piece
    puts 'From which square would you like to move?'
    origin = input_square
    content = board[origin]
    return content if content && content.team == @active_player

    puts "You don't have a piece on that square."
    input_piece
  end

  def input_type
    piece_types = [Pawn, Rook, Knight, Bishop, Queen, King]
    chosen_type = gets.chomp until piece_types.any? { |type| type.name.downcase == chosen_type.downcase }
    piece_types.select { |type| type.name.downcase == chosen_type.downcase }
  end

  def input_square
    files = ('a'..'h').to_a
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
    regex = Regexp.new('[a-h][1-8]')
    regex.match input
  end

  def match_rochade(input)
    return true if input == 'o-o'
    return true if input == 'O-O'

    false
  end

  def map_square_to_coords(square)
    files = ('a'..'h').to_a
    rank = square[0]
    file = square[1]
    "#{files[file]}#{rank + 1}"
  end

  def map_move_to_notation(piece_input)
    piece_map = {
      'Pawn' => '',
      'Rook' => 'R',
      'Knight' => 'N',
      'Bishop' => 'B',
      'Queen' => 'Q',
      'King' => 'K'
    }
    return piece_input if match_rochade(piece_input)

    "#{piece_map[piece_input.class.name]}#{map_square_to_coords(piece_input.position.value)}"
  end
end
