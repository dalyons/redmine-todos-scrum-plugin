# Hooks to attach to the Redmine Todos List in the issue view.

class TodoIssuesHook < Redmine::Hook::ViewListener

  # Renders an additional table to the issue details bottom
  #
  # Context:
  # * :issue => Current issue
  #
  render_on :view_issues_show_description_bottom, :partial => 'todos', :locals => { :todos => @todos }

  def view_layouts_base_html_head(context = {})
    project = context[:project]
    return '' unless project
    controller = context[:controller]
    return '' unless controller
    action_name = controller.action_name
    return '' unless action_name

    if (controller.class.name == 'ProjectsController' and action_name == 'activity')
      o = ""
      o << stylesheet_link_tag('todos', :plugin => 'redmine_todos_plugin')
      return o
    end
  end
end
