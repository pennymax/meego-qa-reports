module MeegoTestCaseHelper

  def result_html(model)
    case model.result
    when 1
      "Pass"
    when -1
      "Fail"
    else
      "N/A"
    end
  end

  def result_class(model)
    case model.result
    when 1
      "pass"
    when -1
      "fail"
    else
      "na"
    end
  end

  def comment_html(model)
    model.comment ? MeegoTestReport::format_txt(model.comment).html_safe : nil
  end
end
