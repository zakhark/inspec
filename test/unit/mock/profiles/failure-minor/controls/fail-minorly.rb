title 'minor failing control'

control 'fail-minorly-1.0' do
  impact 0.1
  title 'Fail minorly'

  describe 'foo' do
    it { should eq 'bar' }
  end
end
