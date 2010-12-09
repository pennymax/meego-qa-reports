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

class ReportComparison

  def initialize(old_report, new_report)
    @old_report      = old_report
    @new_report      = new_report
    @new_failing     = 0
    @new_passing     = 0
    @new_na          = 0
    @changed_to_pass = 0
    @changed_to_fail = 0
    @changed_to_na   = 0
  end

  def changed_to_fail
    format_result(@changed_to_fail)
  end

  def changed_to_pass
    format_result(@changed_to_pass)
  end

  def changed_to_na
    format_result(@changed_to_na)
  end

  def new_na
    format_result(@new_na)
  end

  def new_passing
    format_result(@new_passing)
  end

  def new_failing
    format_result(@new_failing)
  end

  def changed_test_cases
    reference = Hash[*@new_report.meego_test_cases.collect { |test_case| [test_case.name, test_case] }.flatten]

    @old_report.meego_test_cases.select { |test_case|
      update_summary(test_case, reference.delete(test_case.name))
    }.push(*reference.values.select { |test_case|
      update_summary(nil, test_case)
    })
  end

  def old_report
    @old_report
  end

  def new_report
    @new_report
  end

  private

  def format_result(result)
    if result==0
      result.to_s
    elsif result>0
      "+" + result.to_s
    else
      "-" + result.to_s
    end
  end

  def update_summary(old, new)
    if old == nil
      case new.result
        when -1 then
          @new_failing += 1
        when 0 then
          @new_na += 1
        when 1 then
          @new_passing += 1
        else
          throw :invalid_value
      end
      true
    elsif new.result!=old.result
      case new.result
        when 1 then
          @changed_to_pass += 1
        when 0 then
          @changed_to_na += 1
        when -1 then
          @changed_to_fail += 1
        else
          throw :invalid_value
      end
      true
    else
      false
    end
  end
end