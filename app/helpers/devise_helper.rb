module DeviseHelper
  def devise_error_messages!
    return "" if resource.errors.empty?

    # "Email in use" is reported twice by devise (for some unknown reason). The "uniq" call below is to filter
    # that second error message from the view. Fix properly when there's time. If this causes problems at some point,
    # pls let me know. :) -Tommi
    messages = resource.errors.full_messages.map { |msg| content_tag(:li, msg) }.uniq.join
    html = <<-HTML
    <div id="error">
      <ul>
        #{messages}
      </ul>
    </div>

    HTML

    html.html_safe
  end
end
