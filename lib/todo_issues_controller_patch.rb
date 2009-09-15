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
      @todos = Todo.for_project(@project.id).roots.find(:all, :conditions => ["issue_id = ?", @issue.id])
      show_without_todo
    end

    def show_todos
       render :partial => 'todos', :locals => { :todos => @todos }
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
