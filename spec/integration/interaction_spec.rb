# frozen_string_literal: true

describe :interactions do
  before(:all) do
    Stop.create(code: '1', description: 'A', address: 'A', lat: '-5.062577', lng: '-42.795527')
    Vehicle.create(code: '1')
  end

  after(:all) do
    truncate(Stop)
    truncate(Vehicle)
  end

  context 'stops' do
    it 'when stop not existis return 404' do
      get '/v2/seg/stop/2', token_head
      expect_status(404)
    end
  end

  context 'vehicle' do
    it 'when stop not existis return 404' do
      get '/v2/seg/vehicle/2', token_head
      expect_status(404)
    end
  end
end
