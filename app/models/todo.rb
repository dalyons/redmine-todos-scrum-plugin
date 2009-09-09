
class Todo < ActiveRecord::Base
      
        ##junk for trying to patch redmine classes - dosent work in dev
  
  #require_dependancy 'patch_redmine_classes' 
  #include TodosProjectPatch
  #include TodosUserPatch
  #Project.send(:include, TodosProjectPatch)
  #Dispatcher.to_prepare {
#    Project.send(:include, TodosProjectPatch)
#  }
  #unless Rails.configuration.cache_classes
  #  raise "Sorry, cant run with reloading models. " +
  #        "Change config.cache_classes to 'true' or run in production mode!"
  #end

  acts_as_tree :order => "position"
  acts_as_list :scope => :parent_id
  
  belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
  belongs_to :assigned_to, :class_name => 'User', :foreign_key => 'assigned_to_id'
  
  belongs_to :project
  belongs_to :refers_to, :class_name => 'Issue', :foreign_key => 'issue_id'
  
  named_scope :roots, :conditions => {:parent_id => nil }
  named_scope :personal_todos, :conditions => {:project_id => nil}
  named_scope :project_todos, :conditions => ["project_id is not null"]
  named_scope :for_project, lambda {|*args| {:conditions => {:project_id => args.first}} }
  named_scope :for_user, lambda {|*args|
    { :conditions => ["author_id = ? OR assigned_to_id = ?",args.first, args.first] }
  } 


  validates_presence_of  :author
  validates_length_of :text, :within => 1..255
  
  
  #for some reason, running under Passenger in production, changing all the todo tree&order 
  #positions doesnt work. For some reason, rails doesnt write the parent_id of some records 
  #because it doesnt think they have changed when they actually have - the partial_updates feature 
  #from rails is fucked for this scenario.
  #I tried all sorts of reloads - the only thing that works is this bad boy.
  self.partial_updates = false
  
  def set_done(val, cascade_to_children = true)
    self.done = val
    
    #3debugger
    
    self.children.each{|c| c.set_done val} if cascade_to_children
    
    self.completed_at = Time.now
    self.save
    
    if self.parent
      #if we are being marked as undone, we have to undo our parent aswell
      if !val 
        self.parent.set_done(false, false)
      end 
    
      #if all our siblings are done, mark parent as done 
      ##Actually, I dont think this is a desireable feature.
      #if self.done && !parent.done && self.siblings.inject(true){|result, sibling| result = result && sibling.done} 
      #  puts "siblings done"
      #  #self.parent.update_attribute(:done,  true)
      #  self.parent.set_done(false, false)
      #end
      
    end
    
    
  end
  
  def possible_issues
    if self.project
      self.project.issues.find(:all, :order => "id DESC").reject{|i| i.closed?} 
    else
      []
    end
  end
  
  def parent_or_root_id
    if self.project
      (parent_id || 'project-' + self.project.id.to_s).to_s
    else
      (parent_id || 'personal').to_s
    end
    return (parent_id || 'root').to_s
  end
  
  def self_and_ancestors 
    self.ancestors.unshift self
  end
  
  
  #complicated ugly method that sorts todos based on the nested param array passed in from
  #the Prototype sortable element helper.
  ###tree mode - prototype helps pass in the todo tree like so:
    # "todo-children-ul_"=>{ 
    #   "0"=>{"id"=>"96"}, 
    #    "1"=>{"0"=>{"id"=>"93"}, "id"=>"68", "1"=>{"id"=>"92"}, "2"=>{"id"=>"94"}},
    #    "2"=>{"id"=>"55"}, etc.. }
    #so make a recursive reordering function for that structure.
  def self::sort_todos(valid_todos, todos_position_tree = {}) #element_identifier = "todo-children-ul_", params = {})
    
    #logger.info "sorting!" + todos_position_tree.inspect
    
    reorder = lambda { |order_hash_array, parent_id| 
      
      order_hash_array.each{|position,children_hash|
        
        id = children_hash["id"].to_i
        todo = valid_todos.select{|t| t.id == id }.first
        #todo.reload
        logger.debug "id:#{todo.id} n:#{todo.text} parent:#{parent_id} position:#{position}"
        
        todo.update_attributes!(:parent_id => parent_id, :position => position) unless todo.nil?
        
        children_hash.delete("id")
        reorder.call( children_hash, id )
      }
    }

    reorder.call(todos_position_tree, nil)
    
  end
  
  def self::group_by_project(todos)
    res = Hash.new{|h,k| h[k] = []}
    todos.each{|todo| res[todo.project_id] << todo}
    return res
  end
  
  #find a todo by id, but return null if the user didnt author it or is not assigned to it
  def self::find_by_user(todo_id, user_id)
    self.find(todo_id, :conditions => ["author_id = :id OR assigned_to_id = :id",{:id => User.current.id}] )
  end
end
