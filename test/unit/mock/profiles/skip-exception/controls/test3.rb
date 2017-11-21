control "xinetd-control" do
  describe.one do
    describe xinetd_conf.services("chargen-dgram") do
      it { should be_disabled }
    end
    describe package("xinetd") do
      it { should_not be_installed }
    end
  end
end
