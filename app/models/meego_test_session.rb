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
require 'testreport'
require 'csv'
require 'bitly'
require 'trimmer'

require 'validation/date_time_validator'

#noinspection Rails3Deprecated
class MeegoTestSession < ActiveRecord::Base
  include Trimmer

  has_many :meego_test_sets, :dependent => :destroy
  has_many :meego_test_cases

  belongs_to :author, :class_name => "User"
  belongs_to :editor, :class_name => "User"

  validates_presence_of :title, :target, :testtype, :hwproduct
  validates_presence_of :uploaded_files, :on => :create

  validates :tested_at, :date_time => true

  validate :allowed_filename_extensions, :on => :create
  validate :save_uploaded_files, :on => :create

  #after_create :save_uploaded_files
  after_destroy :remove_uploaded_files

  attr_reader :parsing_failed, :parse_errors

  scope :published, :conditions => { :published => true }

  XML_DIR = "public/reports"

  include ReportSummary

  def target=(target)
    target = target.try(:downcase)
    write_attribute(:target, target)
  end

  def target
    read_attribute(:target).try(:capitalize)
  end

  def testtype=(testtype)
    testtype = testtype.try(:downcase)
    write_attribute(:testtype, testtype)
  end

  def testtype
    read_attribute(:testtype).try(:capitalize)
  end

  def hwproduct=(hwproduct)
    hwproduct = hwproduct.try(:downcase)
    write_attribute(:hwproduct, hwproduct)
  end

  def hwproduct
    read_attribute(:hwproduct).try(:capitalize)
  end

  def prev_summary
    prev_session
  end

  def self.import(attributes, files, user)
    attr = attributes.merge!({:uploaded_files => files})
    result = MeegoTestSession.new(attr)
    result.tested_at = result.tested_at || Time.now
    result.import_report(user, true)
    result.save!
    result
  end

  def self.release_versions
    # Add new release versions to the beginning of the array.
    ["1.2", "1.1", "1.0"]
  end

  def self.latest_release_version
    release_versions[0]
  end

  def self.filters_exist?(target, testtype, hwproduct)
    filters_exist = false

    if target.present?
      filters_exist = find_by_target(target.downcase).present?

      if testtype.present?
        filters_exist &= find_by_testtype(testtype.downcase).present?
      end

      if testtype.present? && hwproduct.present?
        filters_exist &= find_by_hwproduct(hwproduct.downcase).present?
      end
    end

    return filters_exist
  end

  def self.all_lowercase(options = {})
    options[:conditions].each do |key, value|
      options[:conditions][key] = value.downcase if value.kind_of? String
    end
    all(options)
  end

  class << self
    def by_release_version_target_test_type_product(release_version, target, testtype, hwproduct)
      target = target.downcase
      testtype = testtype.downcase
      hwproduct = hwproduct.downcase
      published.where(:release_version => release_version, :target => target, :testtype => testtype, :hwproduct => hwproduct).order("tested_at DESC")
    end

    def published_by_release_version_target_test_type(release_version, target, testtype)
      target = target.downcase
      testtype = testtype.downcase
      published.where(:release_version => release_version, :target => target, :testtype => testtype).order("tested_at DESC")
    end

    def published_by_release_version_target(release_version, target)
      target = target.downcase
      published.where(:release_version => release_version, :target => target).order("tested_at DESC")
    end
  end

  ###############################################
  # List category tags                          #
  ###############################################
  def self.list_targets(release_version)
    (published.all_lowercase(:select => 'DISTINCT target', :conditions=>{:release_version => release_version}).map{|s| s.target.gsub(/\b\w/){$&.upcase}}).uniq
  end

  def self.list_types(release_version)
    (published.all_lowercase(:select => 'DISTINCT testtype', :conditions=>{:release_version => release_version}).map{|s| s.testtype.gsub(/\b\w/){$&.upcase}}).uniq
  end

  def self.list_types_for(release_version, target)
    (published.all_lowercase(:select => 'DISTINCT testtype', :conditions => {:target => target, :release_version => release_version}).map{|s| s.testtype.gsub(/\b\w/){$&.upcase}}).uniq
  end

  def self.list_hardware(release_version)
    (published.all_lowercase(:select => 'DISTINCT hwproduct', :conditions=>{:release_version => release_version}).map{|s| s.hwproduct.gsub(/\b\w/){$&.upcase}}).uniq
  end

  def self.list_hardware_for(release_version, target, testtype)
    (published.all_lowercase(:select => 'DISTINCT hwproduct', :conditions => {:target => target, :testtype=> testtype, :release_version => release_version}).map{|s| s.hwproduct.gsub(/\b\w/){$&.upcase}}).uniq
  end


  ###############################################
  # Test session navigation                     #
  ###############################################
  def prev_session
    time = tested_at || Time.now
    MeegoTestSession.find(:first, :conditions => [
        "tested_at < ? AND target = ? AND testtype = ? AND hwproduct = ? AND published = ? AND release_version = ?", time, target.downcase, testtype.downcase, hwproduct.downcase, true, release_version
      ],
      :order => "tested_at DESC")
  end

  def next_session
    MeegoTestSession.find(:first, :conditions => [
        "tested_at > ? AND target = ? AND testtype = ? AND hwproduct = ? AND published = ? AND release_version = ?", tested_at, target.downcase, testtype.downcase, hwproduct.downcase, true, release_version
      ],
      :order => "tested_at ASC")
  end

  ###############################################
  # Utility methods for viewing a report        #
  ###############################################
  def formatted_date
    tested_at ? tested_at.strftime("%Y-%m-%d") : 'n/a'
  end


  ###############################################
  # Chart visualization methods                 #
  ###############################################
  def graph_img_tag(format_email)
    values = [0,0,total_passed,0,0,total_failed,0,0,total_na]
    labels = ["","","Current"]
    totals = [0,0,total_cases]
    prev = prev_session
    if prev
      values[1] = prev.total_passed
      values[4] = prev.total_failed
      values[7] = prev.total_na
      labels[1] = prev.formatted_date
      totals[1] = prev.total_cases
      pp = prev.prev_session
      if pp
        values[0] = pp.total_passed
        values[3] = pp.total_failed
        values[6] = pp.total_na
        labels[0] = pp.formatted_date
        totals[0] = prev.total_cases
      end
    end
    scale = [totals.max, 10].max
    step = scale/9.0
    step = (step.to_i/5)*5
    if (scale % 45) != 0
      step += 5
    end
    scale = (scale/step+1)*step
    chart_size = "385x200"
    chart_type = "bvs" # bar, vertical, stacked
    chart_colors = "BCCD98|BCCD98|73a20c,E7ABAB|E7ABAB|ec4343,DBDBDB|DBDBDB|CACACA"
    chart_data = "t:%i,%i,%i|%i,%i,%i|%i,%i,%i" % values
    chart_scale = "0,%i" % scale
    #chart_margins = "0,0,0,0"
    chart_fill = "bg,s,ffffffff"
    chart_width = "90,30,30"
    chart_axis = "x,y"
    chart_labels = "%s|%s|%s" % labels
    chart_range = "1,0,%i,%i" % [scale,step]

    #url = "http://chart.apis.google.com/chart?cht=#{chart_type}&chs=#{chart_size}&chco=#{chart_colors}&chd=#{chart_data}&chds=#{chart_scale}&chma=#{chart_margins}&chf=#{chart_fill}&chbh=#{chart_width}&chxt=#{chart_axis}&chl=#{chart_labels}&chxr=#{chart_range}"
    url = "http://chart.apis.google.com/chart?cht=#{chart_type}&chs=#{chart_size}&chco=#{chart_colors}&chd=#{chart_data}&chds=#{chart_scale}&chf=#{chart_fill}&chbh=#{chart_width}&chxt=#{chart_axis}&chl=#{chart_labels}&chxr=#{chart_range}"

    if ( format_email )
      Bitly.use_api_version_3
      bitly = Bitly.new("leonidasoy", "R_b1aca98d073e7a78793eec01f3340fb4")
      url = bitly.shorten(url).short_url
    end

    "<div class=\"bvs_wrap\"><img class=\"bvs\" src=\"#{url}\"/></div>".html_safe
  end

  def small_graph_img_tag(max_cases)
    chart_size = "386x14"
    chart_type = "bhs:nda" # bar, horizontal, stacked
    chart_colors = "73a20c,ec4343,CACACA"
    chart_data = "t:%i|%i|%i" % [total_passed, total_failed, total_na]
    chart_scale = "0,%i" % ([max_cases,15].max)
    chart_margins = "0,0,0,0"
    chart_fill = "bg,s,ffffff00"
    chart_width = "14,0,0"

    url = "http://chart.apis.google.com/chart?cht=#{chart_type}&chs=#{chart_size}&chco=#{chart_colors}&chd=#{chart_data}&chds=#{chart_scale}&chma=#{chart_margins}&chf=#{chart_fill}&chbh=#{chart_width}"

    "<div class=\"bhs_wrap\"><img class=\"bhs\" src=\"#{url}\"/></div>".html_safe
  end

  ###############################################
  # Text data html formatting                   #
  ###############################################
  def objective_html
    txt = objective_txt
    if txt == ""
      "No objective filled in yet"
    else
      MeegoTestReport::format_txt(txt)
    end
  end

  def tested_at_html
    tested_at.strftime("%Y-%m-%d")
  end

  def tested_at_txt
    tested_at.strftime("%Y-%m-%d")
  end

  def build_html
    txt = build_txt
    if txt == ""
      "No build details filled in yet"
    else
      MeegoTestReport::format_txt(txt)
    end
  end

  def environment_html
    txt = environment_txt
    if txt == ""
      "No environment description filled in yet"
    else
      MeegoTestReport::format_txt(txt)
    end
  end

  def qa_summary_html
    txt = qa_summary_txt
    if txt == ""
      "No quality summary filled in yet"
    else
      MeegoTestReport::format_txt(txt)
    end
  end

  def issue_summary_html
    txt = issue_summary_txt
    if txt == ""
      "No issue summary filled in yet"
    else
      MeegoTestReport::format_txt(txt)
    end
  end


  ###############################################
  # Small utility functions                     #
  ###############################################
  def updated_by(user)
    self.editor = user
    self.save
  end

  def generate_defaults!
    time = tested_at || Time.now
    self.title = "%s Test Report: %s %s %s" % [target, hwproduct, testtype, time.strftime('%Y-%m-%d')]
    self.environment_txt = "* Hardware: " + hwproduct
  end

  def format_date
    tested_at.strftime("%d.%m")
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

  def sanitize_filename(f)
    filename = if f.respond_to?(:original_filename)
      f.original_filename
    else
      f.path
    end
    just_filename = File.basename(filename)
    just_filename.gsub(/[^\w\.\_\-]/, '_')
  end


 ###############################################
  # File upload handlers                        #
  ###############################################
  def uploaded_files=(files)
    @files = files
  end

  def uploaded_files
    @files
  end

  def allowed_filename_extensions
    @files.each do |f|
      filename = if f.respond_to?(:original_filename)
        f.original_filename
      elsif f.respond_to?(:path)
        f.path
      else
        f.gsub(/\#.*/, '')
      end
      filename = filename.downcase.strip
      if filename == ""
        errors.add :uploaded_files, "can't be blank"
        return
      end
      unless filename =~ /\.csv$/ or filename =~ /\.xml$/
        errors.add :uploaded_files, "You can only upload files with the extension .xml or .csv"
        return
      end
    end if @files
  end

  def save_uploaded_files
    @parsing_failed = false
    return unless @files
    MeegoTestSession.transaction do
      filenames = []
      @parse_errors = []
      @files.each do |f|
        datepart = Time.now.strftime("%Y%m%d")
        dir = File.join(XML_DIR, datepart)

        begin
          f = if f.respond_to?(:original_filename)
            f
          elsif f.respond_to?(:path)
            f
          else
              File.new(f.gsub(/\#.*/, ''))
          end          
        rescue
          errors.add :uploaded_files, "can't be blank"
          return
        end

        filename = sanitize_filename(f)

        origfn = File.basename(filename)
        filename = ("%06i-" % Time.now.usec) + filename
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
        begin
          if filename =~ /.csv$/
            parse_csv_file(path_to_file)
          else
            parse_xml_file(path_to_file)
          end
        rescue
          logger.error "ERROR in file parsing"
          logger.error $!, $!.backtrace
          errors.add :uploaded_files, "Incorrect file format for #{origfn}"
        end
      end
      @xmlpath = filenames.join(',')
      #save
    end
  end

  def remove_uploaded_files
    # TODO
  end

  def to_csv
    common_fields = [
      tested_at.to_date.to_s,
      release_version,
      target,
      testtype,
      hwproduct,
      title
    ]

    rows = meego_test_cases.map do |test_case|
      test_case.meego_test_set.feature #category
      test_case.name # test case name
      test_case.result # result
    end
  end

  def import_report(user, published = false)
      generate_defaults!
      user.update_attribute(:default_target, self.target) if self.target.present?

      # See if there is a previous report with the same test target and type
      prev = self.prev_session
      if prev
        self.objective_txt = prev.objective_txt
        self.build_txt = prev.build_txt
        self.qa_summary_txt = prev.qa_summary_txt
        self.issue_summary_txt = prev.issue_summary_txt
      end

      self.author = user
      self.editor = user
      self.published = published
   end

private

  ###############################################
  # Uploaded data parsing                       #
  ###############################################
  def parse_csv_file(filename)
    prev_category = nil
    test_set = nil

    rows = CSV.read(filename);
    rows.shift
    rows.each do |row|
      category = row[0].toutf8.strip
      summary = row[1].toutf8.strip
      comments = row[2].toutf8.strip if row[2]
      passed = row[3]
      failed = row[4]
      na = row[5]
      if category != prev_category
        prev_category = category
        test_set = self.meego_test_sets.build(
          :feature => category
        )
      end
      if passed
        result = 1
      elsif failed
        result = -1
      else
        result = 0
      end
      if summary == ""
        raise "Missing test case name in CSV"
      end
      test_case = test_set.meego_test_cases.build(
        :name => summary,
        :result => result,
        :comment => comments || "",
        :meego_test_session => self
      )
    end
  end

  def parse_xml_file(filename)
    r = TestResults.new(File.open(filename))

    sets = {}

    r.suites.each do |suite|
      suite.sets.each do |set|
        if sets.has_key? set.feature
          set_model = sets[set.feature]
        else
          set_model = self.meego_test_sets.build(
            :feature => set.feature
          )
          sets[set.feature] = set_model
        end
        set.cases.each do |testcase|
          case_model = set_model.meego_test_cases.build(
            :name => testcase.name,
            :result => MeegoTestSession.map_result(testcase.result),
            :comment => testcase.comment,
            :meego_test_session => self
          )
        end
      end
    end
  end
end
