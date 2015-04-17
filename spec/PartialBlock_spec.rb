require 'rspec'
require_relative '../src/PartialBlock'

describe 'Pruebas sobre partial blocks'  do

  it 'un bloque mal definido explota' do
    expect{PartialBlock.new([], Proc.new do |argumento| end)}.to raise_error(ArgumentException)
  end

  it 'un bloque definido para string matchea con strings ' do

    helloBlock = PartialBlock.new([String], Proc.new do |who| "Hello #{who}" end)

    #esto rompe porque manda un parámetro y según la consigna deberían ser dos, lo voy a preguntar en la lista <- creo que con esto ya esta resuelto el comment

    expect(helloBlock.matches("a")).to equal(true) #true
    expect(helloBlock.matches(1)).to equal(false) #false
    expect(helloBlock.matches("a", "b")).to equal(false) #false

  end

  it 'un bloque parcial con mas de un parametro matchea correctamente' do

    un_block = PartialBlock.new([Fixnum, Fixnum], Proc.new do |var1, var2| var1+var2 end)

    expect(un_block.matches(2)).to equal(false) #false
    expect(un_block.matches(1, "a")).to equal(false) #false
    expect(un_block.matches(2, 4)).to equal(true) #true

  end

end