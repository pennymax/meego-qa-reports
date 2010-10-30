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

module ApplicationHelper
  def row_class(index)
    if (index % 2) == 0
      ' even '
    else
      ' odd '
    end
  end
  
  def hardware_for(target, testtype)
    MeegoTestSession.list_hardware_for(target, testtype)
  end

 def breadcrumbs
   html = '<div id="breadcrumb"><a href="' + url_for(:controller=>'index', :action=>'index') + '">Home</a>'
   if @target
     unless @testtype
       html += ' &rsaquo; <strong>' + @target + '</strong>'
     else
       html += ' &rsaquo; <a href="' +url_for(:controller=>'index', :action=>'filtered_list', :target=>@target, :testtype=>nil) + '">' + @target + '</a>'       
     end
   end
   if @testtype
     unless @hwproduct
       html += ' &rsaquo; <strong>' + @testtype + '</strong>'
     else
       html += ' &rsaquo; <a href="' +url_for(:controller=>'index', :action=>'filtered_list', :target=>@target, :testtype=>@testtype, :hwproduct=>nil) + '">' + @testtype + '</a>'       
     end
   end
   if @hwproduct
     unless @test_session
       html += ' &rsaquo; <strong>' + @hwproduct + '</strong>'
     else
       html += ' &rsaquo; <a href="' +url_for(:controller=>'index', :action=>'filtered_list', :target=>@target, :testtype=>@testtype, :hwproduct=>@hwproduct) + '">' + @hwproduct + '</a>'
     end
   end
   if @test_session
     html += ' &rsaquo; <strong>' + @test_session.title + '</strong>'
   end
   html += '</div>'
   html.html_safe
 end

  def release_version_navigation(current_version)
    html = '<ul class="clearfix">'
    link_text = ''
    @meego_releases.each_with_index do |release, index|
      if release == current_version
          html += '<li class="current">'
          link_text = "MeeGo v#{release}"
      else
          html += '<li>'
          link_text = "v#{release}"
      end

      html += link_to link_text, root_url + release
      html += '</li>'
    end
    
    html += '</ul>'
    html.html_safe
  end

  def format_date_to_human_readable(date)
    date.strftime('%d %B %Y')
  end
  

end
