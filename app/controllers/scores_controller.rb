class ScoresController < ApplicationController

  def index
    render json: Score.leaderboards, include: :user, except: [:created_at, :updated_at]
  end

  def create
    user = User.find_or_create_by(name: params[:user])
    score = Score.create(time: params[:score], user: user)
  end

end
