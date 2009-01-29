#require 'ruby-debug'


class TodosController < ApplicationController

	
	before_filter :authorize#, :except => [:my_todos] #????
	before_filter :find_project, :except => [:my_todos]
	
	
  def index
  	@todos = @project.todos.find_all_by_parent_id(nil,:order => 'position', :include => [:project, :assigned_to])
  	
  	@new_todo = Todo.new
  end
  
	#def update
    #@customer = Customer.find_by_id(params[:customer_id])
  #  if @customer.update_attributes(params[:customer])
  #    flash[:notice] = l(:notice_successful_update)
  #    redirect_to :action => "list", :id => params[:id]
  #  else
  #    render :action => "edit", :id => params[:id]
  #  end
  #end
  
  def my_todos
  	@todos = Todo.find_all_by_parent_id(nil, 
  						:conditions => ["author_id = :id OR assigned_to_id = :id",{:id => User.current.id}],
  						:order => "project_id, position" )
  	
  	#group the results by project, into a hash keyed on project.
  	#this line is so beautiful it nearly made me cry!
  	@grouped_todos = Set.new(@todos).classify{|t| t.project } 
  	
  end

  def destroy
    @todo = @project.todos.find(params[:id])
    
    if @todo.destroy
      flash[:todo] = l(:notice_successful_delete)
    else
      flash[:error] = l(:notice_unsuccessful_save)
    end
    render :text => @todo.errors.collect{|k,m| m}.join

  end
  
  def new
    @todo = Todo.new
    @todo.parent_id = @project.todos.find(params[:parent_id]).id
    @todo.project = @project
    @todo.assigned_to = User.current
    render :partial => 'new_todo', :locals => { :todo => @todo}
  end
  
  def toggle_complete
    @todo = @project.todos.find(params[:id])
    @todo.set_done !@todo.done
    redirect_to :action => "index", :project_id => params[:project_id]
  end

  def create
    @todo = Todo.new(params[:todo])
    @todo.project = @project
    @todo.author = User.current
    
    if @todo.save
      if (request.xhr?)
        render :partial => 'todo', :locals => { :todo => @todo }
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
		raise "cant sort without a project!" if !@project
		
		@todos = @project.todos.find_all_by_project_id(@project.id)
		
		##tree mode - prototype helps pass in the todo tree like so:
		# "todo-children-ul_"=>{ 
		# 	"0"=>{"id"=>"96"}, 
		#		"1"=>{"0"=>{"id"=>"93"}, "id"=>"68", "1"=>{"id"=>"92"}, "2"=>{"id"=>"94"}},
		#		"2"=>{"id"=>"55"}, etc.. }
		#so make a recursive reordering function for that structure.
		reorder = lambda { |order_hash_array, parent_id| 
			
			order_hash_array.each{|position,children_hash|
				id = children_hash["id"].to_i
				@todos.select{|t| t.id == id }.first.update_attributes(:parent_id => parent_id, :position => position)
				
				children_hash.delete("id")
				reorder.call( children_hash, id )
			}
		}
		params.keys.select{|k| k.include? "todo-children-ul_" }.each do |key|
			reorder.call( params[key], params[:parent_id])
		end
		
    render :nothing => true
  end
  
 private
  def find_project
  	@project = Project.find(params[:project_id])
  	raise ActiveRecord::RecordNotFound, "Project not found! With id:" + params[:project_id] unless @project
  end
end
