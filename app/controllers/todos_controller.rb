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

  before_filter :find_project
  before_filter :authorize

  helper :todos

  #global string to use as the suffix for the element id for todo's <UL> 
  UL_ID = "todo-children-ul_"
  TODO_LI_ID = "todo_"
  
  def index
    @todos = Todo.for_project(@project.id).roots

    @allowed_to_edit = User.current.allowed_to?(:edit_todos, @project)
    
    @new_todo = Todo.new
  end
  

  def destroy
    @todo = Todo.for_project(@project.id).find(params[:id])
    
    if @todo.destroy
      flash[:todo] = l(:notice_successful_delete) unless request.xhr?
    else
      flash[:error] = l(:notice_unsuccessful_save) unless request.xhr?
    end
    render :text => @todo.errors.collect{|k,m| m}.join

  end

  def show    
    begin
      @todo = Todo.for_project(@project.id).find(params[:id])
    rescue ActiveRecord::RecordNotFound => ex
      raise ex, l(:todo_not_found_error)
    end
    
    if @todo
      respond_to do |format|
        format.html { render }
        #format.js { render :action => 'show' }
      end
    else
      flash.now[:error] = @todo.errors.collect{|k,m| m}.join
      respond_to do |format|
        format.html { redirect_to :action => 'index' }
        #format.js { render :action => 'edit' }
      end
    end
  end

  def new
    @todo = Todo.new
    @todo.parent_id = Todo.for_project(@project.id).find(params[:parent_id]).id
    @todo.issue_id = Issue.find(params[:issue_id]).id
    @todo.project = @project
    @todo.assigned_to = User.current
    render :partial => 'new_todo', :locals => { :todo => @todo}
  end
  
  def toggle_complete
    @todo = Todo.for_project(@project.id).find(params[:id])
    @todo.set_done !@todo.done
    if (request.xhr?)
      @element_html = render_to_string :partial => 'todos/todo',
                                         :locals => {:todo => @todo, :editable => true}                 
      render :action => "todo.rjs"
    else
      redirect_to :action => "index", :project_id => @project
    end
  end



  def create
    @todo = Todo.new(params[:todo])
    @todo.project = @project
    @todo.author = User.current
    
    if @todo.save
      if (request.xhr?)
        @element_html = render_to_string :partial => 'todo_li',
                                         :locals => { :todo => @todo, :editable => true }
        render :action => "create.rjs"   #using rjs
      else
        flash[:notice] = l(:notice_successful_create)
        redirect_to :action => "index", :project_id => @project
      end
    else
      flash.now[:error] =  @todo.errors.collect{|k,m| m}.join
      respond_to do |format|
        format.html { redirect_to :action => "index" }
        format.js { render :action => 'create' }
      end
    end
  end

  #for the d&d sorting ajax helpers
  #TODO: this is pretty messy.
  def sort
    raise l(:todo_sort_no_project_error) if !@project
    
    @todos = Todo.for_project(@project.id)
    
    params.keys.select{|k| k.include? UL_ID }.each do |key|
      Todo.sort_todos(@todos,params[key])
    end
    
    render :nothing => true

  end

  def edit
    if request.post?
      @todo = Todo.for_project(@project.id).find(params[:id])
      if @todo.update_attributes(:text => params[:text])
        @allowed_to_edit = User.current.allowed_to?(:edit_todos, @project)
        respond_to do |format|
          format.html { redirect_to :action => 'index' }
          format.js { render :action => 'update' }
        end
      else
        flash.now[:error] =  @todo.errors.collect{|k,m| m}.join
        respond_to do |format|
          format.html { redirect_to :action => 'index' }
          format.js { render :action => 'edit' }
        end
      end
    end
  end

 private
  def find_project
    @project = Project.find(params[:project_id])
    raise ActiveRecord::RecordNotFound, l(:todo_project_not_found_error) + " id:" + params[:project_id] unless @project
  end
end
