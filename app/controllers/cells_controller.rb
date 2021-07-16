class CellsController < ApplicationController

  def index
    render json: Cell.mines, except: [:created_at, :updated_at]
  end

  def show
    render json: Cell.returned_cells(params[:id]), except: [:created_at, :updated_at, :visited]
  end

  def create
    Cell.new_game
  end
end
