# Hooks to attach to the Redmine Todos List in the issue view.

class TodoIssuesHook < Redmine::Hook::ViewListener

  # Renders an additional table to the issue details bottom
  #
  # Context:
  # * :issue => Current issue
  #
  def view_issues_show_description_bottom(context ={ })
    controller = context[:controller]
    controller.show_todos
  end  
end
