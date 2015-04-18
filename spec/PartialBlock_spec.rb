require 'rspec'
require_relative '../src/PartialBlock'

describe 'Pruebas sobre partial blocks'  do

  attr_accessor(:helloBlock)


  before(:all) do
    self.helloBlock = PartialBlock.new([String]) do |who| "Hello #{who}" end
  end

  it 'un bloque mal definido explota' do
    expect{PartialBlock.new([]) do |argumento| end}.to raise_error(ArgumentException)
  end

  it 'un bloque definido para string matchea con strings ' do

    expect(self.helloBlock.matches("a")).to equal(true) #true

  end


  it 'un bloque definido para strings no matchea con no-strings ' do

    expect(self.helloBlock.matches(1)).to equal(false) #false
    expect(self.helloBlock.matches("a", "b")).to equal(false) #false

  end

  it 'un bloque parcial con mas de un parametro matchea correctamente' do

    un_block = PartialBlock.new([Fixnum, Fixnum]) do |var1, var2| var1+var2 end

    expect(un_block.matches(2)).to equal(false) #false
    expect(un_block.matches(1, "a")).to equal(false) #false
    expect(un_block.matches(2, 4)).to equal(true) #true

  end

end