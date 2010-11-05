#
# This file is part of meego-test-reports
#
# Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
#
# Authors: Sami Hangaslammi <sami.hangaslammi@leonidasoy.fi>
#          Jarno Keskikangas <jarno.keskikangas@leonidasoy.fi>
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


class IndexController < ApplicationController
  #caches_page :index, :filtered_list
  caches_action :filtered_list, :layout => false

  def index
    @types = {}
    @types["Core"] = MeegoTestSession.list_types_for @selected_release_version, "Core"
    @types["Handset"] = MeegoTestSession.list_types_for @selected_release_version, "Handset"
    @types["Netbook"] = MeegoTestSession.list_types_for @selected_release_version, "Netbook"
    @types["IVI"] = MeegoTestSession.list_types_for @selected_release_version, "IVI"

    @hardware = MeegoTestSession.list_hardware @selected_release_version
    @target = params[:target]
    @testtype = params[:testtype]
    @hwproduct = params[:hwproduct]
  end

  def filtered_list
    @target = params[:target]
    @testtype = params[:testtype]
    @hwproduct = params[:hwproduct]

    if @hwproduct
      sessions = MeegoTestSession.by_release_version_target_test_type_product(@selected_release_version, @target, @testtype, @hwproduct)
    elsif @testtype
      sessions = MeegoTestSession.published_by_release_version_target_test_type(@selected_release_version, @target, @testtype)
    else
      sessions = MeegoTestSession.published_by_release_version_target(@selected_release_version, @target)
    end
    # .group_by{|s| s.created_at.beginning_of_month}
    
    @headers = []
    @sessions = {}
    
    #@trend_graph_url = generate_trend_graph(sessions[0,30])
    
    sessions.each do |s|
      header = s.created_at.strftime("%B %Y")
      unless @sessions.has_key? header
        @headers << header
        (@sessions[header] = []) << s
      else
        @sessions[header] << s
      end
    end
    
  end
  
private

  def generate_trend_graph(sessions)
    passed = []
    failed = []
    na = []
    total = []
    
    sessions.each do |s|
      total << s.total_cases
      passed << s.total_passed
      failed << s.total_failed
      na << s.total_na
    end
    
    max_total = total.max
    
    chart_type = 'cht=lc'
    colors = '&chco=CACACA,ec4343,73a20c'
    size = '&chs=700x120'
    legend = '&chdl=na|fail|pass'
    legend_pos = '&chdlp=b'
    axes = '&chxt=x,y,r'
    axrange = '&chxr=0,' + max_total.to_s
    linefill = '&chm=B,CACACA,0,0,0|B,ec4343,0,0,0|B,73a20c,0,0,0'
    data = '&chd=s:' + encode(passed,failed,na,max_total)
    
    "http://chart.apis.google.com/chart?" + chart_type + size + colors + legend + legend_pos + axes + axrange + linefill + data
  end

  def encode(passed, failed, na, max)
    result = []

    data = []
    na.each do |v|
      data << simple_encode(v,max)
    end
    result << data.join('')
    
    data = []
    failed.each do |v|
      data << simple_encode(v,max)
    end
    result << data.join('')

    data = []
    passed.each do |v|
      data << simple_encode(v,max)
    end
    result << data.join('')
    
    result.join(',')
  end

  def simple_encode(value, max)
    v = value*61/max
    if v <= 25
      ('A'[0] + v).chr
    elsif v <= 51
      ('a'[0] + v-26).chr
    elsif v <= 61
      ('0'[0] + v-52).chr
    else
      '_'
    end
  end

end
