class RoomsController < ApplicationController
  def index
    room = Current.user.default_room
    redirect_to room if room
  end

  def show
    @room = Current.user.rooms.find(params[:id])
    @rooms = Current.user.rooms.order(:name)
    @pagy, @messages = pagy(:keyset, @room.messages.newest_first.includes(:user), limit: Message::HISTORY_LENGTH)
    @message = @room.messages.new
  end
end
