# &#128163; -> unicode for bomb
# &#128681; -> unicode for flag

class Cell < ApplicationRecord

  BOMB = "&#128163;"
  FLAG = "&#128681;"
  @@board = []

  def self.new_game
    @@board = []
    @@mines = []
    self.all.each do |cell|
      cell.bomb = false
      cell.number = 0
      cell.visited = false
      cell.save
    end
    pick_mines
    fill_contents
    game_board
  end

  def self.pick_mines
    @@mines = Cell.all.sample(15)
    mines.each do |cell|
      cell.bomb = true
      cell.save
    end
  end

  def self.give_location
    game_board.each_with_index do |row, row_number|
      row.each_with_index do |cell, column_number|
        cell.location = "#{row_number}-#{column_number}"
        cell.save
      end
    end
  end

  def self.fill_contents
    mines.each do |cell|
      row_number = cell.location.split("-")[0].to_i
      column_number = cell.location.split("-")[1].to_i

      if row_number == 0
        #check only below
        if column_number == 0
          #check only below and to the right
          game_board[0][1].number += 1
          game_board[1][0].number += 1
          game_board[1][1].number += 1
        elsif column_number > 0 && column_number < 9
          #check below and both sides
          game_board[0][column_number + 1].number += 1
          game_board[0][column_number - 1].number += 1
          game_board[1][column_number].number += 1
          game_board[1][column_number + 1].number += 1
          game_board[1][column_number - 1].number += 1
        elsif column_number == 9
          #check only below and to the left
          game_board[0][8].number += 1
          game_board[1][9].number += 1
          game_board[1][8].number += 1
        end
      elsif row_number > 0 && row_number < 9
        #check above and below
        if column_number == 0
          #check above and below only to the right

          #checks directly to the right
          game_board[row_number][column_number + 1].number += 1
          #checks down and diagonal to the right
          game_board[row_number + 1][column_number + 1].number += 1
          game_board[row_number + 1][column_number].number += 1
          #checks up and diagonal to the right
          game_board[row_number - 1][column_number + 1].number += 1
          game_board[row_number - 1][column_number].number += 1
        elsif column_number > 0 && column_number < 9
          #check above and below and both sides

          #checks directly to the left and right
          game_board[row_number][column_number - 1].number += 1
          game_board[row_number][column_number + 1].number += 1
          #checks down and diagonal
          game_board[row_number + 1][column_number - 1].number += 1
          game_board[row_number + 1][column_number + 1].number += 1
          game_board[row_number + 1][column_number].number += 1
          #checks up and diagonal
          game_board[row_number - 1][column_number - 1].number += 1
          game_board[row_number - 1][column_number + 1].number += 1
          game_board[row_number - 1][column_number].number += 1
        elsif column_number == 9
          #check above and below only to the left

          #checks directly to the left
          game_board[row_number][column_number - 1].number += 1
          #checks down and diagonal to the left
          game_board[row_number + 1][column_number - 1].number += 1
          game_board[row_number + 1][column_number].number += 1
          #checks up and diagonal to the left
          game_board[row_number - 1][column_number - 1].number += 1
          game_board[row_number - 1][column_number].number += 1
        end
      elsif row_number == 9
        #check only above
        if column_number == 0
          #check only above and to the right
          game_board[9][1].number += 1
          game_board[8][0].number += 1
          game_board[8][1].number += 1
        elsif column_number > 0 && column_number < 9
          #check above and both sides
          game_board[9][column_number + 1].number += 1
          game_board[9][column_number - 1].number += 1
          game_board[8][column_number].number += 1
          game_board[8][column_number + 1].number += 1
          game_board[8][column_number - 1].number += 1
        elsif column_number == 9
          #check only above and to the left
          game_board[9][8].number += 1
          game_board[8][9].number += 1
          game_board[8][8].number += 1
        end
      end
      game_board.each do |row|
        row.each do |cell|
          if cell.number > 0
            cell.save
          end
        end
      end
    end
  end

  def self.mines
    if @@mines.empty?
      @@mines = Cell.where(bomb: true)
    else
      @@mines
    end
  end

  def self.game_board
    if @@board.empty?
      counter = 1

      10.times do
        inner_array = []
        10.times do
          inner_array.push(Cell.find_by_id(counter))
          counter += 1
        end
        @@board.push(inner_array)
      end
      @@board
    else
      @@board
    end
  end

  def self.returned_cells(location)
    startingCell = Cell.find_by(location: location)
    if startingCell.bomb
      return self.mines
    elsif startingCell.number > 0
      return startingCell
    else
      self.floodFill(startingCell)
    end
  end

  def self.floodFill(startingCell, returned_cells = [], queue = [])
    # binding.pry
    startingCell.visited = true
    startingCell.save
    returned_cells.push(startingCell) unless returned_cells.include?(startingCell)
    if startingCell.number == 0
      row_number = startingCell.location.split("-")[0].to_i
      column_number = startingCell.location.split("-")[1].to_i
      up = row_number - 1
      down = row_number + 1
      left = column_number - 1
      right = column_number + 1
      # binding.pry
      if row_number == 0
        #check only below
        if column_number == 0
          #check only below and to the right
          r = game_board[row_number][right]
          below = game_board[down][column_number]
          below_r = game_board[down][right]
          returned_cells.push(r) unless returned_cells.include?(r)
          queue.push(r) unless r.visited || queue.include?(r)
          returned_cells.push(below) unless returned_cells.include?(below)
          queue.push(below) unless below.visited || queue.include?(below)
          returned_cells.push(below_r) unless returned_cells.include?(below_r)
          queue.push(below_r) unless below_r.visited || queue.include?(below_r)
        elsif column_number > 0 && column_number < 9
          #check below and both sides
          l = game_board[row_number][left]
          r = game_board[row_number][right]
          below = game_board[down][column_number]
          below_r = game_board[down][right]
          below_l = game_board[down][left]
          returned_cells.push(r) unless returned_cells.include?(r)
          queue.push(r) unless r.visited || queue.include?(r)
          returned_cells.push(l) unless returned_cells.include?(l)
          queue.push(l) unless l.visited || queue.include?(l)
          returned_cells.push(below) unless returned_cells.include?(below)
          queue.push(below) unless below.visited || queue.include?(below)
          returned_cells.push(below_r) unless returned_cells.include?(below_r)
          queue.push(below_r) unless below_r.visited || queue.include?(below_r)
          returned_cells.push(below_l) unless returned_cells.include?(below_l)
          queue.push(below_l) unless below_l.visited || queue.include?(below_l)
        elsif column_number == 9
          #check only below and to the left
          l = game_board[row_number][left]
          below = game_board[down][column_number]
          below_l = game_board[down][left]
          returned_cells.push(l) unless returned_cells.include?(l)
          queue.push(l) unless l.visited || queue.include?(l)
          returned_cells.push(below) unless returned_cells.include?(below)
          queue.push(below) unless below.visited || queue.include?(below)
          returned_cells.push(below_l) unless returned_cells.include?(below_l)
          queue.push(below_l) unless below_l.visited || queue.include?(below_l)
        end
      elsif row_number > 0 && row_number < 9
        #check above and below
        if column_number == 0
          #check above and below only to the right
          r = game_board[row_number][right]
          below = game_board[down][column_number]
          below_r = game_board[down][right]
          above = game_board[up][column_number]
          above_r = game_board[up][right]
          #checks directly to the right
          returned_cells.push(r) unless returned_cells.include?(r)
          queue.push(r) unless r.visited || queue.include?(r)
          #checks down and diagonal to the right
          returned_cells.push(below) unless returned_cells.include?(below)
          queue.push(below) unless below.visited || queue.include?(below)
          returned_cells.push(below_r) unless returned_cells.include?(below_r)
          queue.push(below_r) unless below_r.visited || queue.include?(below_r)
          #checks up and diagonal to the right
          returned_cells.push(above) unless returned_cells.include?(above)
          queue.push(above) unless above.visited || queue.include?(above)
          returned_cells.push(above_r) unless returned_cells.include?(above_r)
          queue.push(above_r) unless above_r.visited || queue.include?(above_r)
        elsif column_number > 0 && column_number < 9
          #check above and below and both sides
          r = game_board[row_number][right]
          l = game_board[row_number][left]
          below = game_board[down][column_number]
          below_r = game_board[down][right]
          below_l = game_board[down][left]
          above = game_board[up][column_number]
          above_r = game_board[up][right]
          above_l = game_board[up][left]
          #checks directly to the left and right
          returned_cells.push(r) unless returned_cells.include?(r)
          queue.push(r) unless r.visited || queue.include?(r)
          returned_cells.push(l) unless returned_cells.include?(l)
          queue.push(l) unless l.visited || queue.include?(l)
          #checks down and diagonal
          returned_cells.push(below) unless returned_cells.include?(below)
          queue.push(below) unless below.visited || queue.include?(below)
          returned_cells.push(below_r) unless returned_cells.include?(below_r)
          queue.push(below_r) unless below_r.visited || queue.include?(below_r)
          returned_cells.push(below_l) unless returned_cells.include?(below_l)
          queue.push(below_l) unless below_l.visited || queue.include?(below_l)
          #checks up and diagonal
          returned_cells.push(above) unless returned_cells.include?(above)
          queue.push(above) unless above.visited || queue.include?(above)
          returned_cells.push(above_r) unless returned_cells.include?(above_r)
          queue.push(above_r) unless above_r.visited || queue.include?(above_r)
          returned_cells.push(above_l) unless returned_cells.include?(above_l)
          queue.push(above_l) unless above_l.visited || queue.include?(above_l)
        elsif column_number == 9
          #check above and below only to the left
          l = game_board[row_number][left]
          below = game_board[down][column_number]
          below_l = game_board[down][left]
          above = game_board[up][column_number]
          above_l = game_board[up][left]
          #checks directly to the left
          returned_cells.push(l) unless returned_cells.include?(l)
          queue.push(l) unless l.visited || queue.include?(l)
          #checks down and diagonal to the left
          returned_cells.push(below) unless returned_cells.include?(below)
          queue.push(below) unless below.visited || queue.include?(below)
          returned_cells.push(below_l) unless returned_cells.include?(below_l)
          queue.push(below_l) unless below_l.visited || queue.include?(below_l)
          #checks up and diagonal to the left
          returned_cells.push(above) unless returned_cells.include?(above)
          queue.push(above) unless above.visited || queue.include?(above)
          returned_cells.push(above_l) unless returned_cells.include?(above_l)
          queue.push(above_l) unless above_l.visited || queue.include?(above_l)
        end
      elsif row_number == 9
        #check only above
        if column_number == 0
          #check only above and to the right
          r = game_board[row_number][right]
          above = game_board[up][column_number]
          above_r = game_board[up][right]
          returned_cells.push(r) unless returned_cells.include?(r)
          queue.push(r) unless r.visited || queue.include?(r)
          returned_cells.push(above) unless returned_cells.include?(above)
          queue.push(above) unless above.visited || queue.include?(above)
          returned_cells.push(above_r) unless returned_cells.include?(above_r)
          queue.push(above_r) unless above_r.visited || queue.include?(above_r)
        elsif column_number > 0 && column_number < 9
          #check above and both sides
          r = game_board[row_number][right]
          l = game_board[row_number][left]
          above = game_board[up][column_number]
          above_r = game_board[up][right]
          above_l = game_board[up][left]
          returned_cells.push(r) unless returned_cells.include?(r)
          queue.push(r) unless r.visited || queue.include?(r)
          returned_cells.push(l) unless returned_cells.include?(l)
          queue.push(l) unless l.visited || queue.include?(l)
          returned_cells.push(above) unless returned_cells.include?(above)
          queue.push(above) unless above.visited || queue.include?(above)
          returned_cells.push(above_r) unless returned_cells.include?(above_r)
          queue.push(above_r) unless above_r.visited || queue.include?(above_r)
          returned_cells.push(above_l) unless returned_cells.include?(above_l)
          queue.push(above_l) unless above_l.visited || queue.include?(above_l)
        elsif column_number == 9
          #check only above and to the left
          l = game_board[row_number][left]
          above = game_board[up][column_number]
          above_l = game_board[up][left]
          returned_cells.push(l) unless returned_cells.include?(l)
          queue.push(l) unless l.visited || queue.include?(l)
          returned_cells.push(above) unless returned_cells.include?(above)
          queue.push(above) unless above.visited || queue.include?(above)
          returned_cells.push(above_l) unless returned_cells.include?(above_l)
          queue.push(above_l) unless above_l.visited || queue.include?(above_l)
        end
      end
    end
    # binding.pry
    self.floodFill(queue.shift, returned_cells, queue) unless queue.empty?
    # binding.pry
    returned_cells
  end

end
