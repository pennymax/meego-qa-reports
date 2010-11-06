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

require 'drag_n_drop_uploaded_file'

class UploadController < ApplicationController
  
  before_filter :authenticate_user!
  
  def upload_form
    @test_session = MeegoTestSession.new
    default_version = params[:release_version]
    default_type = params[:testtype]
    default_target = params[:target]
    default_hwproduct = params[:hwproduct]

    @test_session.target = if @test_session.target.present?
      @test_session.target
    elsif default_target.present?
      default_target
    elsif current_user.default_target.present?
      current_user.default_target
    else
      "Core"
    end

    @test_session.release_version = if @test_session.release_version.present?
      @test_session.release_version
    elsif default_version.present?
      default_version
    else
      @selected_release_version
    end
    
    @test_session.testtype = if @test_session.testtype.present?
      @test_session.testtype
    elsif default_type.present?
      default_type
    end

    @test_session.hwproduct = if @test_session.hwproduct.present?
      @test_session.hwproduct
    elsif default_hwproduct.present?
      default_hwproduct
    end

    init_form_values
  end

  def upload_attachment
    raw_filename = env['HTTP_X_FILE_NAME']
    extension = File.extname(raw_filename)
    fileid = env['HTTP_X_FILE_ID']
    raw_filename_wo_extension = File.basename(env['HTTP_X_FILE_NAME'], extension)

    # TODO: Temp files needs to be deleted periodically
    url      = "/reports/tmp/#{raw_filename_wo_extension.parameterize}#{extension}"
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
    current_user.update_attribute(:default_target, @test_session.target) if @test_session.target.present?

    @test_session.generate_defaults!

    # See if there is a previous report with the same test target and type
    prev = @test_session.prev_session

    if prev
      @test_session.objective_txt = prev.objective_txt
      @test_session.build_txt = prev.build_txt
      @test_session.qa_summary_txt = prev.qa_summary_txt
      @test_session.issue_summary_txt = prev.issue_summary_txt
    end

    @test_session.author = current_user
    @test_session.editor = current_user

    if @test_session.save
      session[:preview_id] = @test_session.id
      expire_action :controller => "index", :action => "filtered_list", :release_version => params[:meego_test_session][:release_version], :target => params[:meego_test_session][:target], :testtype => params[:meego_test_session][:testtype], :hwproduct => params[:meego_test_session][:hwproduct]
      expire_action :controller => "index", :action => "filtered_list", :release_version => params[:meego_test_session][:release_version], :target => params[:meego_test_session][:target], :testtype => params[:meego_test_session][:testtype]
      expire_action :controller => "index", :action => "filtered_list", :release_version => params[:meego_test_session][:release_version], :target => params[:meego_test_session][:target]
      redirect_to :controller => 'reports', :action => 'preview'
    else
      init_form_values
      render :upload_form
    end
  end

private

  def init_form_values
    @targets = MeegoTestSession.list_targets @selected_release_version
    @types = MeegoTestSession.list_types @selected_release_version
    @hardware = MeegoTestSession.list_hardware @selected_release_version
    @release_versions = MeegoTestSession.release_versions
    @no_upload_link = true
  end
end

