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

module ReportsHelper

  def edit_button
    if @editing
      '<a href="" class="edit">Edit</a>'.html_safe
    end
  end
  
  def back_to_top
    unless @email
      '<a href="#top">Back to top</a>'.html_safe
    end
  end
  
  def editable_txt(field)
  	html_field = field+'_html'
  	txt_field = field+'_txt'
  	html = '<div class="editcontent" id="' +txt_field+ '">' + \
  	  @report.send(html_field) + '</div>'
  	
  	if @editing
  	  html += '<div class="editmarkup" style="display:none;">' + \
  	    @report.send(txt_field) + '</div>'
  	end
  	
  	html.html_safe
  end
end
