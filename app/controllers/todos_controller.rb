#require 'ruby-debug'


class TodosController < ApplicationController

  #put in a filthy hack to reload the patches to core redmine models.
  #If cache_classes is off, the patches are dropped when the classes reload on every request.
  #So, we reapply the patches here - for some reason it doesnt work in the Todo model.
  #TODO: you are very welcome to find a better way to do this!
  #unless Rails.configuration.cache_classes
  #unloadable
  #  Project.send(:include, TodosProjectPatch)
  #end
  
  #before_filter :find_project  #, :only => [:index] 
  before_filter :find_todo, :only => [:destroy, :show, :toggle_complete, :edit, :update]
  before_filter :authorize

  helper :todos
  
 #global string to use as the suffix for the element id for todo's <UL> 
  UL_ID = "todo-children-ul_"
  TODO_LI_ID = "todo_"
  
  def index
    find_project
    @todos = @project.todos.roots

    @allowed_to_edit = User.current.allowed_to?(:edit_todos, @project)
    
    @new_todo = parent_object.todos.new(:assigned_to => User.current) #Todo.new
   
  end
  #alias_method :index, :project_index

  def destroy
    #@todo = parent_object.todos.find(params[:id])
    
    if @todo.destroy
      flash[:todo] = l(:notice_successful_delete) unless request.xhr?
    else
      flash[:error] = l(:notice_unsuccessful_save) unless request.xhr?
    end
    render :text => @todo.errors.collect{|k,m| m}.join

  end

  def show    
    #begin
    #  @todo = Todo.for_project(@project.id).find(params[:id])
    #rescue ActiveRecord::RecordNotFound => ex
    #  raise ex, l(:todo_not_found_error)
    #end
    
    respond_to do |format|
      format.html { render }
      format.js { 
        @element_html = render_to_string :partial => 'todos/todo',
                                         :locals => {:todo => @todo, :editable => true}                 
        render :template => "todos/todo.rjs"
      }
    end

  end

  def new
    @todo = parent_object.todos.new
    @todo.parent_id = parent_object.todos.find(params[:parent_id]).id
    @todo.refers_to = Issue.find(params[:issue_id]) if params[:issue_id]
    @todo.assigned_to = User.current
    
    #@todo.todoable = parent_object
    
    render :partial => 'new_todo', :locals => { :todo => @todo}
  end
  
  def toggle_complete
    #@todo = Todo.for_project(@project.id).find(params[:id])
    @todo.set_done !@todo.done
    if (request.xhr?)
      @element_html = render_to_string :partial => 'todos/todo',
                                         :locals => {:todo => @todo, :editable => true}                 
      render :template => "todos/todo.rjs"
    else
      redirect_to :action => "index", :project_id => params[:project_id]
    end
  end



  def create
    @todo = parent_object.todos.new(params[:todo])
    #@todo.todoable = @project
    @todo.author = User.current
    
    
    if @todo.save
      if (request.xhr?)
        @element_html = render_to_string :partial => 'todos/todo_li',
                                         :locals => { :todo => @todo, :editable => true }
        render :template => "todos/create.rjs"    #using rjs
      else
        flash[:notice] = l(:notice_successful_create)

        redirect_to :action => "index", :project_id => params[:project_id]
      end
    else
      flash[:notice] = "fail! you suck."
      render :action => "index", :project_id => params[:project_id]
    end
  end
  
  #for the d&d sorting ajax helpers
  #TODO: this is pretty messy.
  def sort
    raise l(:todo_sort_no_project_error) if !parent_object
    
    #@todos = Todo.for_project(@project.id)
    @todos = parent_object.todos
    
    params.keys.select{|k| k.include? UL_ID }.each do |key|
      Todo.sort_todos(@todos,params[key])
    end
    
    render :nothing => true
    #render :action => "sort.rjs"
  end

  def update
    if @todo.update_attributes(params[:todo])
      if request.xhr?
        show
      else
        flash[:notice] = "Todo updated!"
        redirect_to :action => :index
      end
    else
      render :text => "Error in update"
    end
  end

  def edit
    if request.xhr?
      respond_to do |format|
        format.html { render :partial => "todos/inline_edit", :locals => {:todo => @todo} }
      end
    else
      raise "Non-ajax editing not supported..."
    end
    
      #if @todo.update_attributes(:text => params[:text])
      #  @allowed_to_edit = User.current.allowed_to?(:edit_todos, parent_object)
      #  respond_to do |format|
      #    format.html { render :partial => "todos/inline_edit.html", :locals => {:todo => @todo} }
          #format.js { render :action => 'update', :controller => :todos  }
          #format.js { render :partial => "todos/inline_edit.html", :locals => {:todo => @todo} }
      #  end
      #else
      #  flash.now[:error] =  @todo.errors.collect{|k,m| m}.join
      #  respond_to do |format|
          #format.html { redirect_to :action => 'index' }
      #    format.js { render :action => 'edit', :controller => :todos }
      #  end
      #end

  end

 protected

  
  
  #TODO: there may be a better way...
  def parent_object
    #todoable = 
    #  case
    #    when params[:user_id] then User.find(params[:user_id])
    #    when params[:project_id] then Project.find(params[:project_id])
    #    #when params[:todo_template_id] then TodoTemplate.find(params[:todo_template_id])
    #  end   
    todoable = Project.find(params[:project_id]) if params[:project_id]
    raise ActiveRecord::RecordNotFound, "TODO association not FOUND! " if !todoable
    
    return todoable
  end
  
  def find_todo
    @todo = parent_object.todos.find(params[:id])
    raise ActiveRecord::RecordNotFound, "TODO NOT FOUND! id:" + params[:id] unless @todo
  end
  
 private
  def find_project
    @project = Project.find(params[:project_id])
    raise ActiveRecord::RecordNotFound, l(:todo_project_not_found_error) + " id:" + params[:project_id] unless @project
  end
  
  def authorize
    find_project
    super
  end
end
