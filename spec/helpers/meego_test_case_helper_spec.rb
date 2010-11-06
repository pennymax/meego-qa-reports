require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the MeegoTestCaseHelper. For example:
#
# describe MeegoTestCaseHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end

describe MeegoTestCaseHelper do
  it "should give proper html for test case result" do
    [
        [1, "Pass"],
        [-1, 'Fail']
    ].each do |result_code, str|
      t_case = MeegoTestCase.new(:result => result_code)
      result_html(t_case).should == str
    end
  end

  it "should give proper, escaped html for test case comment" do
    t_case = MeegoTestCase.new(:comment => '<script>mah buckit</script>')
    comment_html(t_case).should == '&lt;script&gt;mah buckit&lt;/script&gt;<br/>'
  end
end
