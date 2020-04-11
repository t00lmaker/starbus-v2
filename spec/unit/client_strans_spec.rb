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
    before(:all) do
      Stop.create(code: "1", description: "A", address: "A", lat: "-5.062577", long: "-42.795527")
      Stop.create(code: "2", description: "B", address: "B", lat: "-5.062454", long: "-42.793862")
      Stop.create(code: "3", description: "C", address: "C", lat: "-5.05895", long: "-42.795047")
    end

    after(:all) do
      truncate(Stop)
    end

    it "should be not return all stops in to distance." do
      lat, long, dist = -5.062793.to_f, -42.795623.to_f, 500.to_f
      result = StransAPi.instance.stops_proximas(long, lat, dist)
      expect(result.size).to eq(3)
    end

    it "should be not return stops if not stops in raio." do
      lat, long, dist = -5.062793.to_f, -42.795623.to_f, 200.to_f
      result = StransAPi.instance.stops_proximas(long, lat, dist)
      expect(result.size).to eq(2)
    end

    it "should be not return stops if not stops in raio from coord." do
      lat, long, dist = -5.0.to_f, -42.0.to_f, 500.to_f
      result = StransAPi.instance.stops_proximas(long, lat, dist)
      expect(result.size).to eq(0)
    end
  end
end
