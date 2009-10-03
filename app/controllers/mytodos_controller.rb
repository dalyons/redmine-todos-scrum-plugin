#require 'ruby-debug'

#Inherits from the Todos controller to save repition of all the todo methods.
#Since todos attach through the Todoable interface, all you have to do is override
#the parent_object method, which finds/loads the object that the todos belong to (User/Project/etc).
#TODO: This could be done as a mixin module, something like 'acts_as_todoable'.
class MytodosController < TodosController



  before_filter :authorize
  before_filter :set_user

  def index
    #@user = User.current
  
    #get all the root level todos belonging to current user
    #@todos = User.current.todos.select{|t| t.parent_id == nil }
    @personal_todos = @user.todos.roots

    #find the roots of any project todo that belongs to or was authored by the user
    #(The root itself may not belong to the user, but we still want to display it!)
    @project_todos = Todo.project_todos.for_user(@user.id).collect{|t| t.root}.uniq

    #group the results by project, into a hash keyed on project.
    #this line is so beautiful it nearly made me cry!
    @grouped_project_todos = Set.new(@project_todos).classify{|t| t.todoable } 
    
    
    @new_todo = @user.todos.new(:author_id => @user.id)
  end
  

 protected
  def parent_object
    todoable = User.current   #you can only ever view your own mytodos.
    raise ActiveRecord::RecordNotFound, "TODO association not FOUND! " if !todoable
    
    return todoable
  end
  
 private
  #override the usual authenitcation to something more appropriate for global, personal todos.
  def authorize
    action = {:controller => params[:controller], :action => params[:action]}
    allowed = User.current.allowed_to?(action, project = nil, options={:global => true})
    allowed ? true : deny_access
  end
  
  def set_user
    @user = parent_object
  end
  
  
end
