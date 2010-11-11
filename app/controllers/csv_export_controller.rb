class CsvExportController < ApplicationController
  def export
    @target = params[:target]
    @testtype = params[:testtype]
    @hwproduct = params[:hwproduct]

    csv = "Test execution date;MeeGo release;Profile;Test type;Hardware;Test report name;Category;Test case;Pass;Fail;N/A;Notes;Author;Last modified by\n"

    sql = <<-END
      select mts.tested_at, mts.release_version, mts.target, mts.testtype, mts.hwproduct, mts.title,
        mtset.feature, mtc.name, sum(if(mtc.result = 1,1,0)) as passes,
        sum(if(mtc.result = -1,1,0)) as fails, sum(if(mtc.result = 0,1,0)) as nas, '', author.name, editor.name
      from meego_test_sessions mts
        join users as author on (mts.author_id = author.id)
        join users as editor on (mts.editor_id = editor.id)
        join meego_test_cases as mtc on (mtc.meego_test_session_id = mts.id)
        join meego_test_sets as mtset on (mtc.meego_test_set_id = mtset.id)
      where mts.hwproduct = '#{@hwproduct}'
      and mts.target = '#{@target}'
      and mts.testtype = '#{@testtype}'
      and mts.release_version = '#{@selected_release_version}'
      group by mts.tested_at, mts.release_version, mts.target, mts.testtype, mts.hwproduct, mts.title, mtset.feature, mtc.name
      ;
    END

    result = ActiveRecord::Base.connection.execute(sql)
    result.each do |row|
      csv += row.join(";") + "\n"
    end

    send_data csv, :type => "text/plain", :filename=>"entries.csv", :disposition => 'attachment'
  end
end
