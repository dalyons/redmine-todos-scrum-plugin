class AddCompletedAtToTodos < ActiveRecord::Migration
  def self.up
    add_column :todos, :completed_at, :datetime
  end

  def self.down
    remove_column :todos, :completed_at
  end
end
