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

require 'open-uri'
require 'drag_n_drop_uploaded_file'

class ReportsController < ApplicationController
  before_filter :authenticate_user!, :only => ["upload", "upload_form", "edit", "delete", "update", "update_txt",
                                               "update_title", "update_case_comment", "update_case_result"]
  caches_page :print
  caches_page :index, :upload_form, :email, :filtered_list
  caches_page :view, :if => proc {|c|!c.just_published?}
  caches_action :fetch_bugzilla_data,
                :cache_path => Proc.new { |controller| controller.params },
                :expires_in => 1.hour

  def preview
    @preview_id = session[:preview_id] || params[:id].to_i
    @editing = true
    @wizard = true
    
    unless @preview_id
      redirect_to :action => :upload_form
      return
    end
    
    @test_session = MeegoTestSession.find(@preview_id)
    @report = @test_session
    @no_upload_link = true

    render :layout => "report"
  end
  
  def update_txt
    @preview_id = params[:id].to_i
    @test_session = MeegoTestSession.find(@preview_id)
    
    field = params[:meego_test_session]
    field = field.keys()[0]
    @test_session.update_attribute(field, params[:meego_test_session][field]);
    @test_session.updated_by(current_user)
    expire_caches_for(@test_session)
    
    sym = field.sub("_txt", "_html").to_sym
    
    render :text => @test_session.send(sym) 
  end
  
  def update_title
    @preview_id = params[:id].to_i
    @test_session = MeegoTestSession.find(@preview_id)
    
    field = params[:meego_test_session]
    field = field.keys()[0]
    @test_session.update_attribute(field, params[:meego_test_session][field]);
    @test_session.updated_by(current_user)
    expire_caches_for(@test_session)
    expire_index_for(@test_session)

    render :text => "OK" 
  end
  
  def update_case_comment
  	case_id = params[:id]
  	comment = params[:comment]
  	testcase = MeegoTestCase.find(case_id)
  	testcase.update_attribute(:comment, comment)

    test_session = test_case.meego_test_session
    test_session.updated_by(current_user)
    expire_caches_for(test_session)

  	render :text => "OK"
  end
  
  def update_case_result
  	case_id = params[:id]
  	result = params[:result]
  	testcase = MeegoTestCase.find(case_id)
  	testcase.update_attribute(:result, result.to_i)
    
    test_session = testcase.meego_test_session
    test_session.updated_by(current_user)
    expire_caches_for(test_session, true)
    
    render :text => "OK"
  end
  
  def publish
    report_id = params[:report_id]
    test_session = MeegoTestSession.find(report_id)
    test_session.update_attribute(:published, true)

    expire_caches_for(test_session, true)
    expire_index_for(test_session)
    
    redirect_to :action => 'view', :id => report_id
  end
  
  def view
    @report_id = params[:id].try(:to_i)
    unless @report_id
      redirect_to :action => :index
      return
    end
    preview_id = session[:preview_id]
    if preview_id == @report_id
      session[:preview_id] = nil
      @published = true
    else
      @published = false
    end
    @test_session = MeegoTestSession.find(@report_id)
    @target = @test_session.target
    @testtype = @test_session.testtype
    @hwproduct = @test_session.hwproduct
    
    @report = @test_session
    @editing = false
    @wizard = false
    
    render :layout => "report"
  end
  
  def print
    @report_id = params[:id].to_i
    unless @report_id
      redirect_to :action => :index
      return
    end
    @test_session = MeegoTestSession.find(@report_id)
    
    @report = @test_session
    @editing = false
    @wizard = false
    @email = true
    
    render :layout => "report"
  end
  
  def edit
    id = params[:id].to_i
    @editing = true
    @wizard = false
    
    unless id
      redirect_to :action => :index
      return
    end
    
    @test_session = MeegoTestSession.find(id)
    @report = @test_session
    @no_upload_link = true
    
    render :layout => "report"
  end
  
  def fetch_bugzilla_data
    ids = params[:bugids]
    searchUrl = "http://bugs.meego.com/buglist.cgi?bugidtype=include&columnlist=short_desc%2Cbug_status%2Cresolution&query_format=advanced&ctype=csv&bug_id=" + ids.join(',')
    data = open(searchUrl)
    render :text => data.read(), :content_type => "text/csv"
  end
  
  def delete
    id = params[:id]

    test_session = MeegoTestSession.find(id)

    expire_caches_for(test_session, true)
    expire_index_for(test_session)
    
    test_session.destroy
    
    redirect_to :controller => :index, :action => :index
  end
  
protected

  def just_published?
    @published
  end  

  def expire_index_for(test_session)
    expire_page  :controller => 'index', :action => :index
    expire_page  :controller => 'upload', :action => :upload_form
    expire_page  :controller => 'index', :action => :filtered_list, :target => test_session.target, :testtype => test_session.testtype, :hwproduct => test_session.hwproduct
    expire_page  :controller => 'index', :action => :filtered_list, :target => test_session.target, :testtype => test_session.testtype
    expire_page  :controller => 'index', :action => :filtered_list, :target => test_session.target
  end

  def expire_caches_for(test_session, results=false)
    expire_page :controller => 'reports', :action => 'view', :id => test_session.id
    expire_page :controller => 'reports', :action => 'print', :id => test_session.id
    
    if results
      prev = test_session.prev_session
      if prev
        expire_page  :controller => 'reports', :action => 'view', :id => prev.id
        expire_page  :controller => 'reports', :action => 'print', :id => prev.id
      end
      next_ = test_session.next_session
      if next_
        expire_page  :controller => 'reports', :action => 'view', :id => next_.id
        expire_page  :controller => 'reports', :action => 'print', :id => next_.id
        next_ = next_.next_session
        if next_
          expire_page  :controller => 'reports', :action => 'view', :id => next_.id
          expire_page  :controller => 'reports', :action => 'print', :id => next_.id
        end
      end
    end
  end
  
  
end
