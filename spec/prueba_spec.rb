require 'rspec'
require_relative('../src/prueba')

describe 'Prueba de palomas' do


  it 'la paloma sabe calcular su vitalidad' do
    josefa = Paloma.new
    josefa.vida=(50)
    josefa.energia=(30)
    expect(josefa.vitalidad()).to eq(80)
  end
end