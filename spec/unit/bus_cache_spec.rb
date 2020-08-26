# frozen_string_literal: true

describe :bus_cache do
  before do
    @lines1 = LinhaStrans.new(codigoVeiculo: '1')
    @lines2 = LinhaStrans.new(codigoVeiculo: '2')
    @buses = [
      VeiculoStrans.new(codigoVeiculo: '1', hora: time_to(-6 * 60), linha: @lines1),
      VeiculoStrans.new(codigoVeiculo: '2', hora: time_to, linha: @lines2),
      VeiculoStrans.new(codigoVeiculo: '3', hora: time_to(6 * 60), linha: @lines2)
    ]
  end

  after do
    truncate(Vehicle)
  end

  it 'should be return all vehicles validse and save new Vehicle' do
    client = double(:client_strans)
    expect(client).to receive(:get).with(:veiculos).and_return(@buses)
    cache = BusCache.new(client)
    vehicles = cache.all
    expect(vehicles.size).to eq(1)
    expect(vehicles.first.code).to eq(@buses[1].codigoVeiculo)
  end

  it 'should be save vehicles valids' do
    client = double(:client_strans)
    expect(client).to receive(:get).with(:veiculos).and_return(@buses)
    cache = BusCache.new(client)
    vehicles = cache.all
    expect(Vehicle.find_by_code(@buses[1].codigoVeiculo)).not_to be_nil
  end

  it 'should be return vehicle by code' do
    client = double(:client_strans)
    expect(client).to receive(:get).with(:veiculos).and_return(@buses)
    cache = BusCache.new(client)
    expect(cache.get('2')).not_to be_nil
  end

  it 'should be return vehicles by line' do
    client = double(:client_strans)
    expect(client).to receive(:get).with(:veiculos_linha, nil).and_return(@buses)
    expect(client).to receive(:get).with(:veiculos).and_return(@buses)
    cache = BusCache.new(client)
    vehicles = cache.get_by_line(@lines2.codigoLinha)
    expect(vehicles.size).to eq(1)
    expect(vehicles.first.code).to eq(@buses[1].codigoVeiculo)
  end
end
