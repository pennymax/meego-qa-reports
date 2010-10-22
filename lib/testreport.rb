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

module ReportSummary

  def total_cases
    meego_test_cases.count()
  end
  
  def total_passed
    meego_test_cases.count(:conditions => {:result => 1})
  end
  
  def total_failed
    meego_test_cases.count(:conditions => {:result => -1})
  end
  
  def total_na
    meego_test_cases.count(:conditions => {:result => 0})
  end
  
  def total_executed
    return total_passed + total_failed
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
    if not prev_summary or total_cases == prev_summary.total_cases
      "unchanged"
    elsif total_cases < prev_summary.total_cases
      "dec"
    else
      "inc"
    end
  end

  def passed_change_class
    if not prev_summary or total_passed == prev_summary.total_passed 
      "unchanged"
    elsif total_passed < prev_summary.total_passed
      "dec"
    else
      "inc"
    end
  end

  def failed_change_class
    if not prev_summary or total_failed == prev_summary.total_failed
      "unchanged"
    elsif total_failed < prev_summary.total_failed
      "dec"
    else
      "inc"
    end
  end

  def na_change_class
    if not prev_summary or total_na == prev_summary.total_na
      "unchanged"
    elsif total_na < prev_summary.total_na
      "dec"
    else
      "inc"
    end
  end
  
  
  def total_change
    if not prev_summary or total_cases == prev_summary.total_cases
      ""
    else
      "%+i" % (total_cases - prev_summary.total_cases)
    end
  end

  def passed_change
    if not prev_summary or total_passed == prev_summary.total_passed
      ""
    else
      "%+i" % (total_passed - prev_summary.total_passed)
    end
  end

  def failed_change
    if not prev_summary or total_failed == prev_summary.total_failed
      ""
    else
      "%+i" % (total_failed - prev_summary.total_failed)
    end
  end

  def na_change
    if not prev_summary or total_na == prev_summary.total_na
      ""
    else
      "%+i" % (total_na - prev_summary.total_na)
    end
  end
  
  def run_rate_change_class
    if not prev_summary or run_rate_value == prev_summary.run_rate_value
      "unchanged"
    elsif run_rate_value < prev_summary.run_rate_value
      "dec"
    else
      "inc"
    end
  end

  def total_pass_rate_change_class
    if not prev_summary or total_pass_rate_value == prev_summary.total_pass_rate_value
      "unchanged"
    elsif total_pass_rate_value < prev_summary.total_pass_rate_value
      "dec"
    else
      "inc"
    end
  end

  def executed_pass_rate_change_class
    if not prev_summary or executed_pass_rate_value == prev_summary.executed_pass_rate_value
      "unchanged"
    elsif executed_pass_rate_value < prev_summary.executed_pass_rate_value
      "dec"
    else
      "inc"
    end
  end
  
  def total_pass_rate_change
    if not prev_summary or total_pass_rate_value == prev_summary.total_pass_rate_value
      ""
    else
      "%+i%%" % (total_pass_rate_value - prev_summary.total_pass_rate_value)
    end
  end

  def executed_pass_rate_change
    if not prev_summary or executed_pass_rate_value == prev_summary.executed_pass_rate_value
      ""
    else
      "%+i%%" % (executed_pass_rate_value - prev_summary.executed_pass_rate_value)
    end
  end

  def run_rate_change
    if not prev_summary or run_rate_value == prev_summary.run_rate_value
      ""
    else
      "%+i%%" % (run_rate_value - prev_summary.run_rate_value)
    end
  end

end
