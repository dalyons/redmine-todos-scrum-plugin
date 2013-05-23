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

  def create
    @todo = parent_object.todos.new(params[:todo])
    @todo.author = User.current

    if @todo.save
      if (request.xhr?)
        respond_to do |format|
          format.js {
            @personal_todos = @user.todos.roots
            render action: 'update_mytodo_ui'
          }
        end
      else
        flash[:notice] = l(:notice_successful_create)

        redirect_to :action => "index"
      end
    else
      flash[:notice] = "Error Occured"
      render :action => "index"
    end
  end

  def toggle_complete
    @todo = Todo.find(params[:id])
    @todo.set_done !@todo.done
    if (request.xhr?)
      @element_html = render_to_string :partial => 'todos/todo',
        :locals => {:todo => @todo, :editable => true}
      respond_to do |format|
        format.js {
          render action: 'update_mytodo_ui'
        }
      end
    else
      redirect_to :action => "index"
    end
  end

  def destroy
    @todo = Todo.find(params[:id])
    if @todo.destroy
      flash[:todo] = l(:notice_successful_delete) unless request.xhr?
    else
      flash[:error] = l(:notice_unsuccessful_save) unless request.xhr?
    end

    respond_to do |format|
      format.js {
        @personal_todos = @user.todos.roots
        render action: 'update_mytodo_ui'
      }
    end
  end

  def edit
    @todo = Todo.find(params[:id])
    if request.xhr?
      respond_to do |format|
        format.js {
          render action: 'update_mytodo_ui'
        }
      end
    else
      raise "Non-ajax editing not supported..."
    end
  end

  def update
    @todo = Todo.find(params[:id])
    if @todo.update_attributes(params[:todo])
      if request.xhr?
        respond_to do |format|
          format.js {
            render action: 'update_mytodo_ui'
          }
        end
      else
        flash[:notice] = "Todo updated!"
        redirect_to :action => :index
      end
    else
      render :text => "Error in update"
    end
  end

  def new
    @todo=Todo.new
    @parrent_id=params[:parent_id]
    @todo = parent_object.todos.new
    @todo.parent_id = parent_object.todos.find(params[:parent_id]).id
    @todo.refers_to = Issue.find(params[:issue_id]) if params[:issue_id]
    @todo.assigned_to = User.current
    #@todo.todoable = parent_object
    respond_to do |format|
      format.js {
        render action: 'update_mytodo_ui'
      }
    end
  end

  def show
    @todo = Todo.find(params[:id])
    respond_to do |format|
      format.html { render }
      format.js {
        render action: 'update_mytodo_ui'
      }
    end

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
