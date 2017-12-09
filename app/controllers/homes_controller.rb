class HomesController < ApplicationController

  def index
    @notice = Notice.all.order(created_at: :desc)
  end

end
