class AddCourseAttribute < ActiveRecord::Migration
  def change
    add_column :courses, :open, :boolean, default: true
  end
end
