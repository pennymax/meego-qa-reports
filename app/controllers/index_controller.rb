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
  caches_page :index, :filtered_list

  def index
    @types = {}
    @types["Core"] = MeegoTestSession.list_types_for "Core", ["Sanity", "Core", "Milestone"]
    @types["Handset"] = MeegoTestSession.list_types_for "Handset", ["Acceptance", "Sanity", "Weekly", "Milestone"]
    @types["Netbook"] = MeegoTestSession.list_types_for "Netbook", ["Sanity", "Weekly", "System Functional"]
    @types["IVI"] = MeegoTestSession.list_types_for "IVI", []

    @hardware = MeegoTestSession.list_hardware ["N900", "Aava", "Aava DV2"]
  end
  
  def filtered_list
    @target = params[:target]
    @testtype = params[:testtype]
    @hwproduct = params[:hwproduct]
    
    if @hwproduct
      sessions = MeegoTestSession.where(['target = ? AND testtype = ? AND hwproduct = ? AND published = ?', @target, @testtype, @hwproduct, true]).order("created_at DESC")
    elsif @testtype
      sessions = MeegoTestSession.where(['target = ? AND testtype = ? AND published = ?', @target, @testtype, true]).order("created_at DESC")
    else
      sessions = MeegoTestSession.where(['target = ? AND published = ?', @target, true]).order("created_at DESC")
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
  
end