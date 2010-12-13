#
# This file is part of meego-test-reports
#
# Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
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

class ApiController < ApplicationController
  before_filter :authenticate_user!

  def import_data
    data = request.request_parameters    
    data[:uploaded_files] = collect_files("report")
    attachments = collect_files("attachment")

    data[:tested_at] = data[:tested_at] || Time.now

    @test_session = MeegoTestSession.new(data)
    @test_session.import_report(current_user, true)
    begin
      @test_session.save!
      render :json => {:ok => '1'}
    rescue ActiveRecord::RecordInvalid => invalid
      render :json => {:ok => '0', :errors => invalid.record.errors}
    end
  end

  def collect_files(name)
    parameters = request.request_parameters
    results = []    
    results << parameters.delete(name)
    20.times{|i| results << parameters.delete(name + "." + i.to_s)}
    results.compact
  end
end
