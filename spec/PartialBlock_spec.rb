require 'rspec'
require 'fixture'
require_relative '../src/PartialBlock'


describe 'Pruebas sobre partial blocks'  do

  attr_accessor(:helloBlock)
  attr_accessor(:un_block)


  before(:all) do
    self.helloBlock = PartialBlock.new([String]) do |who| "Hello #{who}" end
    self.un_block = PartialBlock.new([Numeric, Numeric]) do |var1, var2| var1+var2 end
  end

  it 'un bloque mal definido explota' do
    expect{PartialBlock.new([]) do |argumento| end}.to raise_error(ArgumentError)
  end


  it 'un bloque definido para string matchea con strings ' do

    expect(helloBlock.matches("a")).to equal(true) #true

  end


  it 'un bloque definido para strings no matchea con no-strings ' do

    expect(helloBlock.matches(1)).to equal(false) #false
    expect(helloBlock.matches("a", "b")).to equal(false) #false

  end

  it 'un bloque matchea con subtipos' do

    Integer a = 2
    Integer b = 2

    expect(un_block.matches(a,b)).to equal(true)

  end

  it 'un bloque no matchea con argumentos no matcheables' do #WHAT? buen nombre

    expect(un_block.matches(2, "hola")).to equal(false)

  end

  it 'un bloque parcial con mas de un parametro matchea correctamente' do

    expect(un_block.matches(2)).to equal(false) #false
    expect(un_block.matches(1, "a")).to equal(false) #false
    expect(un_block.matches(2, 4)).to equal(true) #true

  end

  it 'un helloBlock al que le paso world!, dice Hello world!' do
    expect(helloBlock.call('world!')).to eq('Hello world!')
  end

  it 'un bloque no recibe argumentos y anda correctamente' do
    pi = PartialBlock.new([]) do 3.14
    end

    expect(pi.call()). to eq(3.14)
  end

  it 'un bloque funciona correctamente con subtipos' do

    #Primer ejemplo
    Integer a = 5
    Integer b = 2

    expect(un_block.call(a,b)). to eq(7)

    #Segundo ejemplo
    bloque_objetoso = PartialBlock.new([Object, Object]) do |var1, var2| [var1*7,var2*7] end

    expect(bloque_objetoso.call(a,b)). to eq([35,14])
  end

  it 'tratar de callear a un bloque con argumentos que no acepta provoca una explosion' do
    expect{helloBlock.call(1)}.to raise_error(ArgumentError)
  end

  it 'soporte de modules en matches y call' do

    module_block = PartialBlock.new([Ave]) { |ave|  ave.volar(10) }
    paloma = Paloma.new
    paloma.energia=(80)

    expect(module_block.matches(paloma)).to eq(true)
    expect(module_block.call(paloma)).to eq(70)

  end

end