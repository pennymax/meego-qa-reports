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

require 'testreport'

class MeegoTestSet < ActiveRecord::Base
  belongs_to :meego_test_session
   
  has_many :meego_test_cases, :dependent => :destroy
   
  include ReportSummary
   
  def prev_summary
    prevs = meego_test_session.prev_session
    if prevs
      prevs.meego_test_sets.find(:first, :conditions => {:feature => feature})
    else
      nil
    end
  end

  def name
    feature
  end

  def max_cases
    result = 0
    meego_test_session.meego_test_sets.each do |set|
      result = [result, set.total_cases].max
    end
    result
  end

  def graph_img_tag
    chart_size = "386x14"
    chart_type = "bhs:nda" # bar, horizontal, stacked
    chart_colors = "73a20c,ec4343,CACACA"
    chart_data = "t:%i|%i|%i" % [total_passed, total_failed, total_na]
    chart_scale = "0,%i" % ([max_cases,15].max)
    chart_margins = "0,0,0,0"
    chart_fill = "bg,s,ffffff00"
    chart_width = "14,0,0"

    url = "http://chart.apis.google.com/chart?cht=#{chart_type}&chs=#{chart_size}&chco=#{chart_colors}&chd=#{chart_data}&chds=#{chart_scale}&chma=#{chart_margins}&chf=#{chart_fill}&chbh=#{chart_width}"

    "<div class=\"bhs_wrap\"><img class=\"bhs\" src=\"#{url}\"/></div>".html_safe
  end

  def test_set_link
    return "#test-set-%i" % id
  end
  
end
