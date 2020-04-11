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
      expect { LoadLinesStops.new(client).init }.to raise_error
    end
  end

  context :create_lines do
    before do
      Line.create(code: "5", description: "R", return: "F", origin: "R")
      Line.create(code: "4", description: "D", return: "L", origin: "D")
      Line.create(code: "3", description: "M", return: "S", origin: "M")
    end

    after do
      truncate(Line)
    end

    it "should be create new line if line not exists " do
      client = double(:client_strans)
      expect(client)
        .to receive(:get)
        .with(:paradas_linha, anything)
        .exactly(3).times
        .and_return([])
      lines = [
        LinhaStrans.new(codigoLinha: "0", denominacao: "R", origin: "R", retorno: "F"),
        LinhaStrans.new(codigoLinha: "1", denominacao: "D", origin: "R", retorno: "F"),
        LinhaStrans.new(codigoLinha: "2", denominacao: "M", origin: "R", retorno: "F"),
      ]
      LoadLinesStops.new(client).create_lines(lines)
      expect Line.find_by_code!("0")
      expect Line.find_by_code!("1")
      expect Line.find_by_code!("2")
    end

    it "should be do nothing if line exists " do
      lines = [
        LinhaStrans.new(codigoLinha: "5", denominacao: "R", origin: "R", retorno: "F"),
        LinhaStrans.new(codigoLinha: "4", denominacao: "D", origin: "R", retorno: "F"),
        LinhaStrans.new(codigoLinha: "3", denominacao: "M", origin: "R", retorno: "F"),
      ]
      LoadLinesStops.new(nil).create_lines(lines)
      expect(Line.all.size).to eq(3)
    end
  end

  context :transform_in_lines do
    it "should be create new line from LinhaStrans with same attributes." do
      line = LinhaStrans.new(codigoLinha: "1", denominacao: "R", origin: "R", retorno: "F")
      new_line = LoadLinesStops.new(nil).transform_in_line(line)
      expect(new_line.code).to eq(line.codigoLinha)
      expect(new_line.description).to eq(line.denominacao)
      expect(new_line.return).to eq(line.retorno)
      expect(new_line.origin).to eq(line.origem)
    end
  end

  context :transform_in_stop do
    it "should be create stop from paradaStrans." do
      s = ParadaStrans.new(codigoParada: "1", denominacao: "t", endereco: "A", lat: "1", long: "2")
      new_stop = LoadLinesStops.new(nil).transform_in_stops([s]).first
      expect(new_stop.code).to eq(stops.first.codigoParada)
      expect(new_stop.description).to eq(stops.first.denominacao)
      expect(new_stop.address).to eq(stops.first.endereco)
      expect(new_stop.lat).to eq(stops.first.lat)
      expect(new_stop.long).to eq(stops.first.long)
    end
  end
end
