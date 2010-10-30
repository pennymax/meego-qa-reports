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


class UploadController < ApplicationController
  
  before_filter :authenticate_user!
  
  def upload_form
    @test_session = MeegoTestSession.new
    @no_upload_link = true
    @test_session.target = if @test_session.target.present?
      @test_session.target
    elsif current_user.default_target.present?
      current_user.default_target
    else
      "Core"
    end
    
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

    # TODO: quick hack done because mysql doesn't obey the :default => "" given in migration - for some reason
    params[:meego_test_session].reverse_merge!(
      :objective_txt => "",
      :build_txt => "",
      :qa_summary_txt => "",
      :issue_summary_txt => "",
      :environment_txt => ""
    )

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

    @test_session.tested_at = Time.now
    @test_session.author = current_user
    @test_session.editor = current_user

    if @test_session.save
      session[:preview_id] = @test_session.id
      redirect_to :controller => 'reports', :action => 'preview'
    else
      @targets = MeegoTestSession.list_targets ["Core","Handset","Netbook","IVI"]
      @types = MeegoTestSession.list_types ["Acceptance", "Sanity", "Weekly", "Milestone"]
      @hardware = MeegoTestSession.list_hardware ["N900", "Aava", "Aava DV2"]
      @no_upload_link = true
      render :upload_form
    end
  end
  
end
