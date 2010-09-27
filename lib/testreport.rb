#
# This file is part of meego-test-reports
#
# Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
#
# Authors: Sami Hangaslammi <sami.hangaslammi@leonidasoy.fi>
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public License
# version 2.1 as published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
# 02110-1301 USA
#

module MeegoTestReport

  class Session
    attr_reader :summary
    attr_accessor :prev_report
    
    def initialize(test_session_model, summary=true, prev=true)
      @session = test_session_model
      @categories = {}
      prev_session = @session.prev_session
      if prev and prev_session
        @prev_report = Session.new(prev_session, true, false)
        pp_session = prev_session.prev_session
        if pp_session
          @pp_report = Session.new(pp_session, true, false)
        end
      else
        @prev_report = nil
        @pp_report = nil
      end
      if summary
        @summary = build_summary
      end
    end
    
    def title
      @session.title
    end
    
    
    # Editable text fields
    def objective_txt
      @session.objective_txt || ""
    end
    
    def objective_html
      txt = objective_txt
      if txt == ""
        "No objective filled in yet"
      else
        MeegoTestReport::format_txt(txt)
      end
    end
    
    def build_txt
      @session.build_txt || ""
    end
    
    
    
    def build_html
      txt = build_txt
      if txt == ""
        "No build details filled in yet"
      else
        MeegoTestReport::format_txt(txt)
      end
    end
    
    def environment_txt
      @session.environment_txt || ""
    end
    
    def environment_html
      txt = environment_txt
      if txt == ""
        "No environment description filled in yet"
      else
        MeegoTestReport::format_txt(txt)
      end
    end
    
    def qa_summary_txt
      @session.qa_summary_txt || ""
    end
    
    def qa_summary_html
      txt = qa_summary_txt
      if txt == ""
        "No quality summary filled in yet"
      else
        MeegoTestReport::format_txt(txt)
      end
    end
    
    def issue_summary_txt
      @session.issue_summary_txt || ""
    end
    
    def issue_summary_html
      txt = issue_summary_txt
      if txt == ""
        "No issue summary filled in yet"
      else
        MeegoTestReport::format_txt(txt)
      end
    end
    
    def categories
      @categories.values
    end
    
    def formatted_date
      @session.created_at.strftime("%Y-%m-%d")
    end
    
    def graph_img_tag(format_email)
      values = [0,0,@summary.total_passed,0,0,@summary.total_failed,0,0,@summary.total_na]
      labels = ["","","Current"]
      totals = [0,0,@summary.total_cases]
      if @prev_report
        prev = @prev_report.summary
        values[1] = prev.total_passed
        values[4] = prev.total_failed
        values[7] = prev.total_na
        labels[1] = @prev_report.formatted_date
        totals[1] = prev.total_cases
        if @pp_report
          pp = @pp_report.summary
          values[0] = pp.total_passed
          values[3] = pp.total_failed
          values[6] = pp.total_na
          labels[0] = @pp_report.formatted_date
          totals[0] = prev.total_cases
        end
      end
      scale = [totals.max, 10].max
      step = scale/9.0
      step = (step.to_i/5)*5
      if (scale % 45) != 0
        step += 5
      end
      scale = (scale/step+1)*step
      chart_size = "385x200"
      chart_type = "bvs" # bar, vertical, stacked
      chart_colors = "BCCD98|BCCD98|73a20c,E7ABAB|E7ABAB|ec4343,DBDBDB|DBDBDB|CACACA"
      chart_data = "t:%i,%i,%i|%i,%i,%i|%i,%i,%i" % values
      chart_scale = "0,%i" % scale
      #chart_margins = "0,0,0,0"
      chart_fill = "bg,s,ffffffff"
      chart_width = "90,30,30"
      chart_axis = "x,y"
      chart_labels = "%s|%s|%s" % labels
      chart_range = "1,0,%i,%i" % [scale,step]
    
      #url = "http://chart.apis.google.com/chart?cht=#{chart_type}&chs=#{chart_size}&chco=#{chart_colors}&chd=#{chart_data}&chds=#{chart_scale}&chma=#{chart_margins}&chf=#{chart_fill}&chbh=#{chart_width}&chxt=#{chart_axis}&chl=#{chart_labels}&chxr=#{chart_range}"
      url = "http://chart.apis.google.com/chart?cht=#{chart_type}&chs=#{chart_size}&chco=#{chart_colors}&chd=#{chart_data}&chds=#{chart_scale}&chf=#{chart_fill}&chbh=#{chart_width}&chxt=#{chart_axis}&chl=#{chart_labels}&chxr=#{chart_range}"

      if ( format_email )
        Bitly.use_api_version_3
        bitly = Bitly.new("leonidasoy", "R_b1aca98d073e7a78793eec01f3340fb4")
        url = bitly.shorten(url).short_url
      end
      
      "<div class=\"bvs_wrap\"><img class=\"bvs\" src=\"#{url}\"/></div>".html_safe
    end
    
    
  private
  
    def build_summary
      s = Summary.new
      s.total_cases = @session.meego_test_cases.size
      max_cases = 0
      @session.meego_test_cases.each do |c|
        category_name = c.meego_test_set.feature
        if @categories.has_key? category_name
          category = @categories[category_name]
        else
          category = Category.new(category_name)
          @categories[category_name] = category
          category.setid = c.meego_test_set.id
        end
        
        category.summary.total_cases += 1
        max_cases = [max_cases, category.summary.total_cases].max
        if c.result == 1
          s.total_passed += 1
          category.summary.total_passed += 1
        elsif c.result == -1
          s.total_failed += 1
          category.summary.total_failed += 1
        else
          s.total_na += 1
          category.summary.total_na+= 1
        end
      end
      
      @categories.each_value do |c|
        c.max_cases = max_cases 
      end
      
      if @prev_report
        s.prev = @prev_report.summary
      end
      s
    end
  end
  
  class Summary
    attr_accessor :total_cases, :total_passed, :total_failed, :total_na, :prev
    
    def initialize
      @total_cases = 0
      @total_passed = 0
      @total_failed = 0
      @total_na = 0
      @prev = nil
    end
    
    def total_executed
      return @total_passed + @total_failed
    end
    
    def run_rate
      "%i%%" % run_rate_value
    end
    
    def total_pass_rate
      "%i%%" % total_pass_rate_value
    end
    
    def executed_pass_rate
      "%i%%" % executed_pass_rate_value
    end
    
    def run_rate_value
      (total_executed*100.0/total_cases)      
    end
    
    def total_pass_rate_value
      (total_passed*100.0/total_cases)  
    end
    
    def executed_pass_rate_value
      (total_passed*100.0/total_executed)
    end
    
    def total_change_class
      if not @prev or total_cases == @prev.total_cases
        "unchanged"
      elsif total_cases < @prev.total_cases
        "dec"
      else
        "inc"
      end
    end

    def passed_change_class
      if not @prev or total_passed == @prev.total_passed 
        "unchanged"
      elsif total_passed < @prev.total_passed
        "dec"
      else
        "inc"
      end
    end

    def failed_change_class
      if not @prev or total_failed == @prev.total_failed
        "unchanged"
      elsif total_failed < @prev.total_failed
        "dec"
      else
        "inc"
      end
    end

    def na_change_class
      if not @prev or total_na == @prev.total_na
        "unchanged"
      elsif total_na < @prev.total_na
        "dec"
      else
        "inc"
      end
    end
    
    
    def total_change
      if not @prev or total_cases == @prev.total_cases
        ""
      else
        "%+i" % (total_cases - @prev.total_cases)
      end
    end

    def passed_change
      if not @prev or total_passed == @prev.total_passed
        ""
      else
        "%+i" % (total_passed - @prev.total_passed)
      end
    end

    def failed_change
      if not @prev or total_failed == @prev.total_failed
        ""
      else
        "%+i" % (total_failed - @prev.total_failed)
      end
    end

    def na_change
      if not @prev or total_na == @prev.total_na
        ""
      else
        "%+i" % (total_na - @prev.total_na)
      end
    end
    
    def run_rate_change_class
      if not @prev or run_rate_value == @prev.run_rate_value
        "unchanged"
      elsif run_rate_value < @prev.run_rate_value
        "dec"
      else
        "inc"
      end
    end

    def total_pass_rate_change_class
      if not @prev or total_pass_rate_value == @prev.total_pass_rate_value
        "unchanged"
      elsif total_pass_rate_value < @prev.total_pass_rate_value
        "dec"
      else
        "inc"
      end
    end

    def executed_pass_rate_change_class
      if not @prev or executed_pass_rate_value == @prev.executed_pass_rate_value
        "unchanged"
      elsif executed_pass_rate_value < @prev.executed_pass_rate_value
        "dec"
      else
        "inc"
      end
    end
    
    def total_pass_rate_change
      if not @prev or total_pass_rate_value == @prev.total_pass_rate_value
        ""
      else
        "%+i%%" % (total_pass_rate_value - @prev.total_pass_rate_value)
      end
    end

    def executed_pass_rate_change
      if not @prev or executed_pass_rate_value == @prev.executed_pass_rate_value
        ""
      else
        "%+i%%" % (executed_pass_rate_value - @prev.executed_pass_rate_value)
      end
    end

    def run_rate_change
      if not @prev or run_rate_value == @prev.run_rate_value
        ""
      else
        "%+i%%" % (run_rate_value - @prev.run_rate_value)
      end
    end

  end
  
  class Category
    attr_accessor :name, :summary, :max_cases, :setid
    
    def initialize(name)
      @name = name
      @summary = Summary.new
    end
    
    def graph_img_tag
      chart_size = "386x14"
      chart_type = "bhs:nda" # bar, horizontal, stacked
      chart_colors = "73a20c,ec4343,CACACA"
      chart_data = "t:%i|%i|%i" % [@summary.total_passed, @summary.total_failed, @summary.total_na]
      chart_scale = "0,%i" % ([max_cases,15].max)
      chart_margins = "0,0,0,0"
      chart_fill = "bg,s,ffffff00"
      chart_width = "14,0,0"

      server = setid % 10

      url = "http://chart.apis.google.com/chart?cht=#{chart_type}&chs=#{chart_size}&chco=#{chart_colors}&chd=#{chart_data}&chds=#{chart_scale}&chma=#{chart_margins}&chf=#{chart_fill}&chbh=#{chart_width}"

      "<div class=\"bhs_wrap\"><img class=\"bhs\" src=\"#{url}\"/></div>".html_safe
    end

    def test_set_link
      return "#test-set-%i" % setid
    end
    
  end
  
  def MeegoTestReport.find_bugzilla_ids(txt)
    ids = Set()
    txt.scan /http\:\/\/bugs.meego.com\/show_bug\.cgi\?id=(\d+)/.each do |match|
      ids << match[0]
    end
    txt.scan /\[\[(\d+)\]\]/.each do |match|
      ids << match[0]
    end
    
    ids
  end
  
  def MeegoTestReport.format_txt(txt)
    html = []
    ul = false
    txt.gsub! '&', '&amp;'
    txt.gsub! '<', '&lt;'
    txt.gsub! '>', '&gt;'
    
    txt.each_line do |line|
      line.strip!
      if ul and not line =~ /^\*/
        html << "</ul>"
        ul = false
      elsif line == ''
        html << "<br/>"
      end
      if line == ''
        next
      end
      line.gsub! /'''''(.+?)'''''/, "<b><i>\\1</i></b>"
      line.gsub! /'''(.+?)'''/, "<b>\\1</b>"
      line.gsub! /''(.+?)''/, "<i>\\1</i>"
      line.gsub! /http\:\/\/bugs.meego.com\/show_bug\.cgi\?id=(\d+)/, "<a class=\"bugzilla fetch\" href=\"http://bugs.meego.com/show_bug.cgi?id=\\1\">\\1</a>"
      line.gsub! /\[\[(http:\/\/.+?) (.+?)\]\]/, "<a href=\"\\1\">\\2</a>"
      line.gsub! /\[\[(\d+)\]\]/, "<a class=\"bugzilla fetch\" href=\"http://bugs.meego.com/show_bug.cgi?id=\\1\">\\1</a>"
      #line.gsub! /\[\[(\d+)\]\]/, "<a class=\"bugzilla\" href=\"http://bugs.meego.com/show_bug.cgi?id=\\1\">\\1</a>"
      
      if line =~ /^====\s*(.+)\s*====$/
        html << "<h5>#{$1}</h5>"
      elsif line =~ /^===\s*(.+)\s*===$/
        html << "<h4>#{$1}</h4>"
      elsif line =~ /^==\s*(.+)\s*==$/
        html << "<h3>#{$1}</h3>"
      elsif line =~ /^\*(.+)$/
        if not ul
          html << "<ul>"
          ul = true
        end
        html << "<li>#{$1}</li>"
      else
        html << "#{line}<br/>"
      end 
    end
    
    (html.join '').html_safe
  end
  
end