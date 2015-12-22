describe command('echo') do
	its(:stdout) { should eq "not this\n" }
end
