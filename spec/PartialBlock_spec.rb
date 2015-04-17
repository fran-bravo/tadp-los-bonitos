require 'rspec'
require_relative '../src/PartialBlock'

describe 'Pruebas sobre partial blocks'  do

  it 'un bloque mal definido explota' do
    expect{PartialBlock.new([]) do |argumento| end}.to raise_error(RuntimeError)
  end

  it 'un bloque definido para string matchea con strings ' do

    helloBlock = PartialBlock.new([String]) do |who| #esto rompe porque manda un parámetro y según la consigna deberían ser dos, lo voy a preguntar en la lista
      "Hello #{who}"
    end

    expect(helloBlock.matches("a")).to equal(true) #true
    expect(helloBlock.matches(1)).to equal(false) #false
    expect(helloBlock.matches("a", "b")).to equal(false) #false


  end

end