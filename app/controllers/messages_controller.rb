class MessagesController < ApplicationController
  before_action :set_room

  def index
    @pagy, @messages = pagy(:keyset, @room.messages.newest_first.includes(:user), limit: Message::HISTORY_LENGTH)
  end

  def create
    @message = @room.messages.new(message_params.merge(user: Current.user))

    if @message.save
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("new_message", partial: "messages/form", locals: { room: @room, message: @room.messages.new }) }
        format.html { redirect_to @room }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("new_message", partial: "messages/form", locals: { room: @room, message: @message }), status: :unprocessable_content }
        format.html { redirect_to @room, alert: @message.errors.full_messages.to_sentence }
      end
    end
  end

  private

  def set_room
    @room = Current.user.rooms.find(params[:room_id])
  end

  def message_params
    params.expect(message: [ :body ])
  end
end
