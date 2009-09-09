module TodosHelper

  def sortable_todo_list()
    
  end

  def render_todo_text(todo, options={})
    content = ''
    editable = options[:editable]
    links = []
    if !todo.text.blank?
      todos_controller = (controller.controller_name == 'issues') ? 'todos' : controller.controller_name
      links << link_to_in_place_text_editor(image_tag('edit.png'), "todo-#{todo.id}-text",
                                             { :controller => todos_controller, :action => 'edit', :id => todo, :project_id => todo.project_id },
                                                :title => l(:button_edit)) if editable
    end
    content << content_tag('span', links.join(' '), :class => 'todo-controls') unless links.empty?
    content << textilizable(todo, :text)
    content_tag('span', content, :id => "todo-#{todo.id}-text")
  end

  def link_to_in_place_text_editor(text, field_id, url, options={})
    onclick = "new Ajax.Request('#{url_for(url)}', {asynchronous:true, evalScripts:true, method:'get'}); return false;"
    link_to text, '#', options.merge(:onclick => onclick)
  end

end
