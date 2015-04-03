require 'rspec'
require_relative('../src/prueba')

describe 'Prueba de palomas' do

  before :each do
    @josefa = Paloma.new
    @josefa.vida=(50)
    @josefa.energia=(30)
  end


  it 'la paloma sabe calcular su vitalidad' do
    expect(@josefa.vitalidad()).to eq(80)
  end

  it 'la paloma baila zumba' do
    expect(@josefa.bailar_zumba()).to eq(15)
  end

  it 'un birdman come 20 gramos y tiene 10 de energia' do
    pedro = Birdman.new
    pedro.energia=(10)
    pedro.comer(20)

    expect(pedro.energia()).to eq(130)
  end

  it 'un manbird come 20 gramos y tiene 10 de energia' do
    pablo = Manbird.new
    pablo.energia=(10)
    pablo.comer(20)

    expect(pablo.energia()).to eq(50)
  end
end