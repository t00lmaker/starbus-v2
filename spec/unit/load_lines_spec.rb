describe :load_lines do

  context :init do
    it "should be call StransApi" do
      client = double(:client_strans)
      expect(client).to receive(:get).with(:linhas).and_return([])
      LoadLinesStops.new(client).init()
    end

    it "should be raise erro if Strans Api return error" do
      client = double(:client_strans)
      expect(client).to receive(:get).with(:linhas).and_return(ErroStrans.new({}))
      expect{ LoadLinesStops.new(client).init }.to raise_error
    end
  end
  
  context :create_lines do
    it "should be create new line if line not exists " do
    
    end
    it "should be do nothing if line exists " do
      
    end
  end
  
  context :transform_in_lines do
    it "" do
    end
  end
  
  context :transform_in_stop do
    it "" do
    end
  end
end