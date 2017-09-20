title 'major failing control'

control 'fail-majorly-1.0' do
  impact 0.5
  title 'Fail majorly'

  describe 'foo' do
    it { should eq 'bar' }
  end
end
