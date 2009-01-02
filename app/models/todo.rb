class Todo < ActiveRecord::Base
	acts_as_tree :order => "position"
	acts_as_list :scope => :parent_id
	
	belongs_to :author, :class_name => 'User', :foreign_key => 'author_id'
	belongs_to :assigned_to, :class_name => 'User', :foreign_key => 'assigned_to_id'
	
	belongs_to :project
	belongs_to :refers_to, :class_name => 'Issue', :foreign_key => 'issue_id'
	
	validates_presence_of :project, :author
	
	
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
			#	puts "siblings done"
			#	#self.parent.update_attribute(:done,  true)
			#	self.parent.set_done(false, false)
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
	
	def self::group_by_project(todos)
		res = Hash.new{|h,k| h[k] = []}
		todos.each{|todo| res[todo.project_id] << todo}
		return res
	end
end
