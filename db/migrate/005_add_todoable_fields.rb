class AddTodoableFields < ActiveRecord::Migration
  def self.up
    add_column :todos, :todoable_id, :integer
    add_column :todos, :todoable_type, :string
  end

  def self.down
    remove_column :todos, :todoable_id
    remove_column :todos, :todoable_type
  end
end
