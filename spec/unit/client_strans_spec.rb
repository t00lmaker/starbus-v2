describe :client_strans do
  context :get do
    it "should be called StransApi with same param and search nil" do
      client = double(:client_strans)
      expect(client).to receive(:get).with(:linhas, nil)
      strans = StransAPi.new(client)
      strans.get(:linhas)
    end

    it "should be call StransApi with same param and search" do
      client = double(:client_strans)
      expect(client).to receive(:get).with(:linhas, "busca")
      strans = StransAPi.new(client)
      strans.get(:linhas, "busca")
    end

    it "should be return nil if StansApi return nil" do
      client = double(:client_strans)
      allow(client).to receive(:get).with(:not_exists, nil).and_return(nil)
      strans = StransAPi.new(client)
      expect(strans.get(:not_exists)).to be_nil
    end

    it "should be return nil if StansApi raise Error" do
      client = double(:client_strans)
      allow(client).to receive(:get).with(:not_exists, nil).and_raise("Error")
      strans = StransAPi.new(client)
      expect(strans.get(:not_exists)).to be_nil
    end
  end

  context :stops_proximas do
    xit "" do
    end

    xit "" do
    end
  end
end
