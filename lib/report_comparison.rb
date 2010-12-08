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
    @old_report = old_report
    @new_report = new_report
  end

  def changed_test_cases
    reference = Hash[*@new_report.meego_test_cases.collect { |test_case| [test_case.name, test_case] }.flatten]

    @old_report.meego_test_cases.map { |test_case|
      other = reference.delete(test_case.name)
      if other==nil || other.result != test_case.result
        test_case
      end
    }.compact.concat(reference.values())
  end

end