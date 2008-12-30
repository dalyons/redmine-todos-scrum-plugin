class Todo < ActiveRecord::Base
	acts_as_tree :order => "created_at"
	
	belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
	belongs_to :assigned_to, :class_name => 'User', :foreign_key => 'assigned_to_id'
	
	belongs_to :project
	belongs_to :refers_to, :class_name => 'Issue', :foreign_key => 'issue_id'
	
	validates_presence_of :project, :author
	
	def done=(v)
		super(v)
		self.children.each{|c| c.done = v}
		self.completed_at = Time.now
		self.save
	end
	
	def possible_issues
		if self.project
			self.project.issues.find(:all, :order => "id DESC").reject{|i| i.closed?} 
		else
			[]
		end
	end
	
	def self::group_by_project(todos)
		res = Hash.new{|h,k| h[k] = []}
		todos.each{|todo| res[todo.project_id] << todo}
		return res
	end
end
