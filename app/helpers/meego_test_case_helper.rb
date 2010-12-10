module MeegoTestCaseHelper

  def result_html(model)
    if model==nil
      return "N/A"
    end
    case model.result
      when 1
        "Pass"
      when -1
        "Fail"
      else
        "N/A"
    end
  end

  def hide_passing(model)
    if model==nil
      return ""
    end
    if model.result == 1
      "display:none;"
    else
      ""
    end
  end


  def result_class(model, prefix = "")
    if model==nil
      return prefix + "na"
    end

    case model.result
      when 1
        prefix + "pass"
      when -1
        prefix + "fail"
      else
        prefix + "na"
    end
  end

  def comment_html(model)
    if model==nil
      return nil
    end
    model.comment ? MeegoTestReport::format_txt(model.comment).html_safe : nil
  end
end
