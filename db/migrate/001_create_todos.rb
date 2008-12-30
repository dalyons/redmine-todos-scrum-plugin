class CreateTodos < ActiveRecord::Migration
  def self.up
    #drop_table :todos
    create_table :todos do |t|
      t.column :due, :datetime
      t.column :priority, :int
      t.column :parent_id, :int
      t.column :text, :string
      t.column :author_id, :int
      t.column :assigned_to_id, :int
      t.column :project_id, :int
      t.column :issue_id, :int
      t.timestamps
    end
  end

  def self.down
    drop_table :todos
  end
end
