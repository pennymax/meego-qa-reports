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

require 'resultparser'
require 'csv'

class MeegoTestSession < ActiveRecord::Base
  has_many :meego_test_suites, :dependent => :destroy
  has_many :meego_test_sets, :through => :meego_test_suites
  has_many :meego_test_cases
  
  validates_presence_of :title
  validates_presence_of :target
  validates_presence_of :testtype
  validates_presence_of :hwproduct
  validates_presence_of :uploaded_files

  after_create :save_uploaded_files
  after_destroy :remove_uploaded_files
  
  XML_DIR = "public/reports"
  
  def self.list_targets(seed=[])
    (seed + MeegoTestSession.find(:all, :select => 'DISTINCT target', :conditions=>{:published=>true}).map{|s| s.target.gsub(/\b\w/){$&.upcase}}).uniq
  end

  def self.list_types(seed=[])
    (seed + MeegoTestSession.find(:all, :select => 'DISTINCT testtype', :conditions=>{:published=>true}).map{|s| s.testtype.gsub(/\b\w/){$&.upcase}}).uniq
  end

  def self.list_types_for(target, seed=[])
    (seed + MeegoTestSession.find(:all, :select => 'DISTINCT testtype', :conditions => {:target => target, :published => true}).map{|s| s.testtype.gsub(/\b\w/){$&.upcase}}).uniq
  end
  
  def self.list_hardware(seed=[])
    (seed + MeegoTestSession.find(:all, :select => 'DISTINCT hwproduct', :conditions=>{:published=>true}).map{|s| s.hwproduct.gsub(/\b\w/){$&.upcase}}).uniq
  end
  
  def self.list_hardware_for(target, testtype, seed=[])
    (seed + MeegoTestSession.find(:all, :select => 'DISTINCT hwproduct', :conditions => {:target => target, :testtype=> testtype, :published=>true}).map{|s| s.hwproduct.gsub(/\b\w/){$&.upcase}}).uniq
  end
  
  def uploaded_files=(files)
    @files = files
  end
  
  def uploaded_files
    return @files
  end
  
  def save_uploaded_files
    MeegoTestSession.transaction do
      filenames = []
      @files.each do |f|
        datepart = Time.now.strftime("%Y%m%d")
        dir = File.join(XML_DIR, datepart)
        filename = sanitize_filename(f.original_filename)
        filename = ("%05i-" % self.id.to_s) + filename
        path_to_file = File.join(dir, filename)
        filenames << path_to_file
        if !File.exists?(dir)
          Dir.mkdir(dir)
        end
        if f.respond_to? :read
          File.open(path_to_file, "wb") { |outf| outf.write(f.read) }
        else
          FileUtils.copy(f.local_path, path_to_file)
        end
        if filename =~ /.csv$/
          parse_csv_file(path_to_file)
        else
          parse_xml_file(path_to_file)
        end
      end
      @xmlpath = filenames.join(',')
      save
    end
  end
  
  def remove_uploaded_files
    # TODO
  end
  
  def generate_defaults!
    self.title = target + " Test Report: " + hwproduct + " " + testtype + " " + Time.now.strftime("%Y-%m-%d")
    self.environment_txt = "* Hardware: " + hwproduct
  end
  
  def format_date
    created_at.strftime("%d.%m")
  end
  
  def parse_csv_file(filename)
    suite = meego_test_suites.create(
      :name => "",
      :domain => ""
    )
    prev_category = nil
    test_set = nil

    rows = CSV.read(filename);
    rows.shift
    rows.each do |row|
      category = row[0].toutf8
      summary = row[1].toutf8
      comments = row[2].toutf8 if row[2]
      passed = row[3]
      failed = row[4]
      na = row[5]
      if category != prev_category
        prev_category = category
        test_set = suite.meego_test_sets.create(
          :name => "",
          :description => "",
          :environment => "",
          :feature => category.strip
        )
      end
      if passed
        result = 1
      elsif failed
        result = -1
      else
        result = 0
      end
      test_case = test_set.meego_test_cases.create(
        :name => summary.strip,
        :description => "",
        :manual => true,
        :insignificant => false,
        :result => result,
        :subfeature => "",
        :comment => (comments || "").strip,
        :meego_test_session => self
      )
    end
  end
  
  def parse_xml_file(filename)
    r = TestResults.new(File.open(filename))
    
    self.environment = r.environment
    #self.hwproduct = r.hwproduct, # This is set manually in the upload form
    self.hwbuild = r.hwbuild
    
    r.suites.each do |suite|
      suite_model = meego_test_suites.create(
        :name => suite.name,
        :domain => suite.domain
      )
      suite.sets.each do |set|
        set_model = suite_model.meego_test_sets.create(
          :name => set.name,
          :description => set.description,
          :environment => set.environment,
          :feature => set.feature
        )
        set.cases.each do |testcase|
          case_model = set_model.meego_test_cases.create(
            :name => testcase.name,
            :description => testcase.description,
            :manual => testcase.manual?,
            :insignificant => testcase.insignificant?,
            :result => MeegoTestSession.map_result(testcase.result),
            :subfeature => testcase.subfeature,
            :comment => testcase.comment,
            :meego_test_session => self
          )
        end
      end
    end
  end
  
  def prev_session
    time = created_at
    if not time
      time = Time.now
    end
    MeegoTestSession.find(:first, :conditions => [
        "created_at < ? AND target = ? AND testtype = ? AND hwproduct = ? AND published = ?", time, target, testtype, hwproduct, true
      ],
      :order => "created_at DESC")
  end
  
  def next_session
    MeegoTestSession.find(:first, :conditions => [
        "created_at > ? AND target = ? AND testtype = ? AND hwproduct = ? AND published = ?", created_at, target, testtype, hwproduct, true
      ],
      :order => "created_at ASC")
  end
  
  def meego_test_cases
    cases = []
    meego_test_suites.each do |suite|
      suite.meego_test_sets.each do |set|
        cases += set.meego_test_cases
      end
    end
    cases
  end
  
  def self.map_result(result)
    result = result.downcase
    if result == "pass"
      1
    elsif result == "fail"
      -1
    else
      0
    end
  end  
  
private
  def sanitize_filename(filename)
    just_filename = File.basename(filename) 
    just_filename.gsub(/[^\w\.\_\-]/,'_') 
  end

end
