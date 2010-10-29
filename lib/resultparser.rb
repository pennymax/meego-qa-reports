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

require 'rubygems'
require 'date'
require 'nokogiri'

class TestResults
  def initialize(xml)
    @doc = Nokogiri::XML(xml) do |config|
      config.strict
    end
    @results = @doc.at_css('testresults')
  end
  
  def environment
    @results['environment'] || ""
  end
  
  def hwproduct
    @results['hwproduct'] || ""
  end
  
  def hwbuild
    @results['hwbuild'] || ""
  end
  
  def suites
    @results.css('suite').map do |suite|
      TestSuite.new(suite)
    end
  end
  
end

class TestSuite
  def initialize(node)
    @node = node
  end
  
  def name
    @node['name'] || ""
  end
  
  def domain
    @node['domain'] || ""
  end
  
  def sets
    @node.css('set').map do |set|
      TestSet.new(set)
    end
  end
  
end

class TestSet
  def initialize(node)
    @node = node
  end
  
  def name
    @node['name'] || ""
  end
  
  def description
    @node['description'] || ""
  end
  
  def feature
    @node['feature'] || ""
  end
  
  def environment
    @node['environment'] || ""
  end
  
  def cases
    @node.css('case').map do |case_|
      TestCase.new(case_)
    end
  end
  
end

class TestCase
  def initialize(node)
    @node = node
  end
  
  def name
    @node['name'] || ""
  end

  def description
    @node['description'] || ""
  end
  
  def manual?
    (@node['manual'] || "").downcase == "true"
  end
  
  def insignificant?
    (@node['insignificant'] || "").downcase == "true"
  end
  
  def result
    @node['result'] || ""
  end
  
  def subfeature
    @node['subfeature'] || ""
  end
  
  def level
    @node['level'] || ""
  end
  
  def steps
    @node.css('step').map do |step|
      TestStep.new(step)
    end
  end
  
  def comment
    @node['comment'] || ""
  end
  
  def failure_info
    @node['failure_info'] || ""
  end
  
end

class TestStep
  def initialize(node)
    @node = node
  end
  
  def command
    @node['command'] || ""
  end
  
  def result
    @node['result'] || ""
  end
  
  def expected_result
    element = @node.at_css('expected_result')
    if element
      element.content
    else
      ""
    end
  end
  
  def return_code
    element = @node.at_css('return_code')
    if element
      element.content
    else
      ""
    end
  end
  
  def start_time
    element = @node.at_css('start')
    if element
      DateTime.parse(element.content)
    else
      nil
    end
  end
  
  def end_time
    element = @node.at_css('end')
    if element
      DateTime.parse(element.content)
    else
      nil
    end
  end
  
  def stdout
    element = @node.at_css('stdout')
    if element
      element.content
    else
      ""
    end
  end
  
  def stderr
    element = @node.at_css('stderr')
    if element
      element.content
    else
      ""
    end
  end
  
  def failure_info
    @node['failure_info'] || ""
  end
  
end
