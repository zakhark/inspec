control '1' do
  title 'title'
  desc '...'
  describe command('echo') do
	  its(:output) { should eq "\n" }
	end
end
