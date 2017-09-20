title 'critcal failing control'

control 'fail-critically-1.0' do
  impact 1.0
  title 'Fail critically'

  describe 'foo' do
    it { should eq 'bar' }
  end
end
