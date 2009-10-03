class RemoveOldTodoAssociations < ActiveRecord::Migration
  def self.up
    
    #turn existing project associated todos into proper Project todos
    Todo.find(:all,:conditions => 'project_id is not null').each do |todo|
      todo.update_attributes!(:todoable_type => 'Project', :todoable_id => todo.project_id)
    end
    
    #Turn personal todos(authored, no project) into proper User todos
    Todo.find(:all,:conditions => 'project_id is null').each do |todo|
      todo.update_attributes!(:todoable => todo.author)
    end
    
    remove_column :todos, :project_id

  end

  def self.down
    add_column :todos, :project_id, :integer

  end
end
