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

    unless MeegoTestSession.filters_exist?(@target, @testtype, @hwproduct)
      return render_404      
    end

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
   
    chosen, days = find_trend_sessions(sessions)

    if chosen.length > 0 
      @trend_graph_url_abs = generate_trend_graph(chosen, days, false)
      @trend_graph_url_rel = generate_trend_graph(chosen, days, true)
    end


    @max_cases = 0

    sessions.each do |s|
      @max_cases = s.total_cases if s.total_cases > @max_cases
      header = s.tested_at.strftime("%B %Y")
      unless @sessions.has_key? header
        @headers << header
        (@sessions[header] = []) << s
      else
        @sessions[header] << s
      end
    end
    
  end
  
private

  def find_trend_sessions(sessions)
    chosen = []
    days = []

    if sessions.size == 0
      return chosen, days
    end

    first = sessions[0].tested_at.yday
    prev_day = nil
    
    sessions.each do |s|
      day = (first - s.tested_at.yday)*2
      if day == prev_day
        next
      end
      prev_day = day
      chosen << s
      days << day
      if chosen.size >= 30
        break
      end
    end
    return chosen, days
  end

  def generate_trend_graph(sessions, days, relative=false)
    passed = []
    failed = []
    na = []
    total = []
    
    sessions.each do |s|
      if relative
        rpass = s.total_passed*100/s.total_cases
        rfail = s.total_failed*100/s.total_cases
        passed << rpass
        failed << rpass + rfail
        na << 100
      else
        total << s.total_cases
        passed << s.total_passed
        failed << s.total_failed + s.total_passed
        na << s.total_na + s.total_failed + s.total_passed
      end
    end
    total_days = days[-1]
    if total_days == 0
      total_days = 1
    end
    
    if relative
      max_total = 100
    else
      max_total = total.max
    end
    
    chart_type = 'cht=lxy'
    colors = '&chco=CACACA,ec4343,73a20c'
    size = '&chs=700x120'
    legend = '&chdl=na|fail|pass'
    legend_pos = '&chdlp=b'
    axes = '&chxt=y,r,x'
    axrange = "&chxr=0,0,#{max_total}|1,0,#{max_total}"
    if total_days < 60
      prc = total_days/60.0
      midn = [0, (prc*20).to_int-1].max
      endn = [0, 20-midn-1].max
      mid_fill = "|"*midn
      end_fill = "|"*endn
      axlabel = "&chxl=2:|#{sessions[-1].format_date}#{mid_fill}|#{sessions[0].format_date}#{end_fill}"
    else
      axlabel = "&chxl=2:|#{sessions[-1].format_date}|#{sessions[0].format_date}"
    end
    linefill = '&chm=b,CACACA,0,1,0|b,ec4343,1,2,0|B,73a20c,2,0,0'
    #linefill = '&chm=B,CACACA,0,0,0'

    data = '&chd=s:' + encode(days, passed, failed, na, max_total, total_days)
    
    "http://chart.apis.google.com/chart?" + chart_type + size + colors + legend + legend_pos + axes + axrange + linefill + data + axlabel
  end

  def encode(days, passed, failed, na, max, max_days)
    result = []

    data = []
    days.reverse_each do |v|
      if max_days < 60
        data << simple_encode(max_days-v, 60)
      else
        data << simple_encode(max_days-v,max_days)
      end
    end
    daydata = data.join('')

    data = []
    na.reverse_each do |v|
      data << simple_encode(v,max)
    end
    result << daydata
    result << data.join('')
    
    data = []
    failed.reverse_each do |v|
      data << simple_encode(v,max)
    end
    result << daydata
    result << data.join('')

    data = []
    passed.reverse_each do |v|
      data << simple_encode(v,max)
    end
    result << daydata
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
