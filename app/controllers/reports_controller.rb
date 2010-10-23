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

require 'testreport'
require 'open-uri'
require 'drag_n_drop_uploaded_file'

class ReportsController < ApplicationController
  before_filter :authenticate_user!, :only => ["upload", "upload_form", "edit", "delete", "update", "update_txt",
                                               "update_title", "update_case_comment", "update_case_result"]

  caches_page :index, :upload_form, :email, :filtered_list
  caches_page :view, :if => proc {|c|!c.just_published?}
  caches_action :fetch_bugzilla_data,
                :cache_path => Proc.new { |controller| controller.params },
                :expires_in => 1.hour

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
  
  def upload_form
    @test_session = MeegoTestSession.new
    @no_upload_link = true
    
    @targets = MeegoTestSession.list_targets ["Core","Handset","Netbook","IVI"]
    @types = MeegoTestSession.list_types ["Acceptance", "Sanity", "Weekly", "Milestone"]
    @hardware = MeegoTestSession.list_hardware ["N900", "Aava", "Aava DV2"]
  end

  def upload_attachment
    raw_filename = env['HTTP_X_FILE_NAME']
    extension = File.extname(raw_filename)
    fileid = env['HTTP_X_FILE_ID']
    raw_filename_wo_extension = File.basename(env['HTTP_X_FILE_NAME'], extension)

    url      = "/system/#{raw_filename_wo_extension.parameterize}#{extension}"
    filename = "#{Rails.root}/public#{url}"

    value = env['rack.input'].read()
    File.open(filename, 'wb') {|f| f.write( value ) }
    render :json => { :ok => '1', :fileid => fileid, :url => url }
  end
  
  def upload

    files = params[:meego_test_session][:uploaded_files] || []

    dnd = params[:drag_n_drop_attachments]
    if dnd
      dnd.each do |name|
        files.push( DragnDropUploadedFile.new("public" + name, "rb") )
      end
  
      params[:meego_test_session][:uploaded_files] = files
    end

    @test_session = MeegoTestSession.new(params[:meego_test_session])

    @test_session.generate_defaults!

  	# See if there is a previous report with the same test target and type
    prev = @test_session.prev_session

  	if prev
  		@test_session.objective_txt = prev.objective_txt
  		@test_session.build_txt = prev.build_txt
  		@test_session.qa_summary_txt = prev.qa_summary_txt
  		@test_session.issue_summary_txt = prev.issue_summary_txt
  	end

    if @test_session.save
      session[:preview_id] = @test_session.id
      redirect_to :action => :preview
    else
      @targets = MeegoTestSession.list_targets ["Core","Handset","Netbook","IVI"]
      @types = MeegoTestSession.list_types ["Acceptance", "Sanity", "Weekly", "Milestone"]
      @hardware = MeegoTestSession.list_hardware ["N900", "Aava", "Aava DV2"]
      @no_upload_link = true
      
      render :upload_form
    end
  end
  
  def preview
    @preview_id = session[:preview_id] || params[:id].to_i
    @editing = true
    @wizard = true
    
    unless @preview_id
      redirect_to :action => :upload_form
      return
    end
    
    @test_session = MeegoTestSession.find(@preview_id)
    @report = MeegoTestReport::Session.new(@test_session)
    @summary = @report.summary
    @no_upload_link = true

    render :layout => "report"
  end
  
  def update_txt
    @preview_id = params[:id].to_i
    @test_session = MeegoTestSession.find(@preview_id)
    
    field = params[:meego_test_session]
    field = field.keys()[0]
    @test_session.update_attribute(field, params[:meego_test_session][field]);
    expire_caches_for(@test_session)
    
    @report = MeegoTestReport::Session.new(@test_session, false)
    
    sym = field.sub("_txt", "_html").to_sym
    
    render :text => @report.send(sym) 
  end
  
  def update_title
    @preview_id = params[:id].to_i
    @test_session = MeegoTestSession.find(@preview_id)
    
    field = params[:meego_test_session]
    field = field.keys()[0]
    @test_session.update_attribute(field, params[:meego_test_session][field]);
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
    expire_caches_for(test_session)

  	render :text => "OK"
  end
  
  def update_case_result
  	case_id = params[:id]
  	result = params[:result]
  	testcase = MeegoTestCase.find(case_id)
  	testcase.update_attribute(:result, result.to_i)
    
    test_session = testcase.meego_test_session
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
    @report_id = params[:id] ? params[:id].to_i : nil
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
    
    @report = MeegoTestReport::Session.new(@test_session)
    @summary = @report.summary
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
    
    @report = MeegoTestReport::Session.new(@test_session)
    @summary = @report.summary
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
    @report = MeegoTestReport::Session.new(@test_session)
    @summary = @report.summary
    @no_upload_link = true
    
    render :layout => "report"
  end
  
  def just_published?
    @published
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
    
    redirect_to :action => :index
  end
  
protected

  def generate_trend_graph(sessions)
    summaries = sessions.map {|s| MeegoTestReport::Session.new(s, true, false) }
    
    passed = []
    failed = []
    na = []
    total = []
    
    summaries.each do |s|
      summary = s.summary
      total << summary.total_cases
      passed << summary.total_passed
      failed << summary.total_failed
      na << summary.total_na
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

  def expire_index_for(test_session)
    expire_page :action => :index
    expire_page :action => :upload_form
    expire_page :action => :filtered_list, :target => test_session.target, :testtype => test_session.testtype, :hwproduct => test_session.hwproduct
    expire_page :action => :filtered_list, :target => test_session.target, :testtype => test_session.testtype
    expire_page :action => :filtered_list, :target => test_session.target
  end

  def expire_caches_for(test_session, results=false)
    expire_page :action => 'view', :id => test_session.id
    expire_page :action => 'email', :id => test_session.id
    
    if results
      prev = test_session.prev_session
      if prev
        expire_page :action => 'view', :id => prev.id
        expire_page :action => 'email', :id => prev.id
      end
      next_ = test_session.next_session
      if next_
        expire_page :action => 'view', :id => next_.id
        expire_page :action => 'email', :id => next_.id
        next_ = next_.next_session
        if next_
          expire_page :action => 'view', :id => next_.id
          expire_page :action => 'email', :id => next_.id
        end
      end
    end
  end
  
  
end
