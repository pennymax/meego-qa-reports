module CsvGenerator
  def self.generate_csv(release_version, target, testtype, hwproduct)
    csv = "Test execution date;MeeGo release;Profile;Test type;Hardware;Test report name;Category;Test case;Pass;Fail;N/A;Notes;Author;Last modified by\n"

    sql = <<-END
      select mts.tested_at, mts.release_version, mts.target, mts.testtype, mts.hwproduct, mts.title,
        mtset.feature, mtc.name, if(mtc.result = 1,1,0) as passes, if(mtc.result = -1,1,0) as fails,
        if(mtc.result = 0,1,0) as nas, mtc.comment, author.name, editor.name
      from meego_test_sessions mts
        join users as author on (mts.author_id = author.id)
        join users as editor on (mts.editor_id = editor.id)
        join meego_test_cases as mtc on (mtc.meego_test_session_id = mts.id)
        join meego_test_sets as mtset on (mtc.meego_test_set_id = mtset.id)
    END

    conditions = []
    conditions << "mts.hwproduct = '#{hwproduct}'" if hwproduct
    conditions << "mts.target = '#{target}'" if target
    conditions << "mts.testtype = '#{testtype}'" if testtype
    conditions << "mts.release_version = '#{release_version}'" if release_version

    sql += " where " + conditions.join(" and ") + ";"

    result = ActiveRecord::Base.connection.execute(sql)
    result.each do |row|
      csv += row.map { |item|
        item.include?("\n") ? "\"#{item}\"" : item
      }.join(";") + "\n"
    end

    csv
  end
end