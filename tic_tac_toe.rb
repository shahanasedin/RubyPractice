class TicTacToe
  def initialize
    @board = Array.new(3) { Array.new(3, " ") }
    @curr_player = 'X'
  end

  def play
    until winner || board_full?
      display_board
      puts "Player #{@curr_player}, enter your coordinates (row and col, 0-2):"
      row, col = gets.chomp.split.map(&:to_i)
      
      if valid_move?(row, col)
        make_move(row, col)
        switch_player
      else
        puts "Invalid move, try again."
      end
    end

    display_board
    if winner
      switch_player 
      puts "Player #{@curr_player} is the winner!"
    else
      puts "It's a draw!"
    end
  end

  def display_board
    @board.each_with_index do |row, i|
      puts "| #{row.join(" | ")} |"
      puts "---+---+---" unless i == 2
    end
  end

  def valid_move?(row, col)
    (0..2).include?(row) && (0..2).include?(col) && @board[row][col] == " "
  end

  def make_move(row, col)
    @board[row][col] = @curr_player
  end0 1

  def switch_player
    @curr_player = @curr_player == 'X' ? 'O' : 'X'
  end

  def winner
    row_winner || column_winner || diagonal_winner
  end

  def row_winner
    @board.each do |row|
      return row[0] if line_winner?(row)
    end
    nil
  end

  def column_winner
    (0..2).each do |i|
      column = @board.map { |row| row[i] }
      return column[0] if line_winner?(column)
    end
    nil
  end

  def diagonal_winner
    diag1 = [@board[0][0], @board[1][1], @board[2][2]] 
    diag2 = [@board[0][2], @board[1][1], @board[2][0]] 
    return diag1[0] if line_winner?(diag1)
    return diag2[0] if line_winner?(diag2)
    nil
  end

  def line_winner?(line)
    line.uniq.size == 1 && line[0] != " "
  end

  def board_full?
    @board.flatten.none? { |cell| cell == " " }
  end
end

game = TicTacToe.new
game.play
