# Redmine - project management software
# Copyright (C) 2006-2008  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require_dependency 'issues_controller'

module TodoIssuesControllerPatch
  module ClassMethods    
    def show_with_todo
      @allowed_to_edit_todos = User.current.allowed_to?(:edit_todos, @project)
      
      #find all todos that relate to this issue... but only collect the 'highest' ones, as we dont want to double render. 
      #consider a nested todo list, A -> B -> [C,D]  where B and D both refer to the issue.
      #We only want to show B, the highest related todo.
      
      #get all the issue todos, highest first.
      all_issue_todos = @project.todos.find_all_by_issue_id(@issue.id).sort{|a,b| a.ancestors.length <=> b.ancestors.length}
      
      @todos = all_issue_todos.inject(Set.new) do |highest, todo|
        ancestors = Set.new(todo.ancestors)
        if highest.intersection(ancestors).empty?  
          highest.add todo
        end
        highest
      end
      
      @todos = @todos.to_a
      
      #@todos = @project.todos.roots.find(:all, :conditions => ["issue_id = ?", @issue.id])
      show_without_todo
    end

    def show_todos
       render_to_string :partial => 'todos', :locals => { :todos => @todos }
    end
  end

  def self.included(base) # :nodoc:
    base.send(:include, ClassMethods)
    base.extend(ClassMethods)
    # Same as typing in the class
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      helper :todos
      alias_method_chain(:show, :todo) unless method_defined?(:show_without_todo)
    end
  end
end
