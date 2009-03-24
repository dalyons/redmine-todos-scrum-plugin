#require 'ruby-debug'

class MytodosController < ApplicationController

  #put in a filthy hack to reload the patches to core redmine models.
  #If cache_classes is off, the patches are dropped when the classes reload on every request.
  #So, we reapply the patches here - for some reason it doesnt work in the Todo model.
  #TODO: you are very welcome to find a better way to do this!
  #unless Rails.configuration.cache_classes
  #  unloadable
  #  User.send(:include, TodosUserPatch)
  #end


  before_filter :authorize

  def index
    #get all the root level todos belonging to current user
    #@todos = User.current.todos.select{|t| t.parent_id == nil }
    @personal_todos = Todo.personal_todos.for_user(User.current.id).roots

    @project_todos = Todo.project_todos.for_user(User.current.id).roots

    #group the results by project, into a hash keyed on project.
    #this line is so beautiful it nearly made me cry!
    @grouped_project_todos = Set.new(@project_todos).classify{|t| t.project } 
    
    
    @new_todo = Todo.new(:author_id => User.current.id)
  end
  
  def new
    @todo = Todo.new
    @todo.parent_id = Todo.find(params[:parent_id]).id
    @todo.assigned_to = User.current
    render :partial => 'new_todo',
       :locals => { :todo => @todo, :update_target => params['update_target']}
  end
  
  def create
    @todo = Todo.new(params[:todo])
    @todo.author = User.current
    
    #debugger
    if @todo.save
    
      if (request.xhr?)
        render :partial => 'todos/todo', :locals => { :todo => @todo, :editable => true }
      else
        flash[:notice] =  @todo.errors.collect{|k,m| m}.join
        redirect_to :action => "index"
      end
    else
      render :text => @todo.errors.collect{|k,m| m}.join
    end
  end
  
  def destroy
    @todo = Todo.find_by_user(params[:id], User.current.id)
    
    if @todo.destroy
      render :text => ""
    else
      render :text => @todo.errors.collect{|k,m| m}.join
    end
  end
  
  def toggle_complete
    @todo = Todo.for_user(User.current.id).find(params[:id])
    @todo.set_done !@todo.done
    if (request.xhr?)
      render :partial => 'todos/todo', :locals => {:todo => @todo, :editable => true}
    else
      redirect_to :action => "index", :project_id => params[:project_id]
    end
  end
  
  def sort
    
    @todos = Todo.for_user(User.current.id)
    
    params.keys.select{|k| k.include? "todo-children-ul_" }.each do |key|
      Todo.sort_todos(@todos,params[key])
    end

    render :nothing => true
  end
  
 private
  def authorize
    action = {:controller => params[:controller], :action => params[:action]}
    allowed = User.current.allowed_to?(action, project = nil, options={:global => true})
    allowed ? true : deny_access
  end
  
end
