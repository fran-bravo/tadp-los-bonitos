require 'rspec'

describe 'Pruebas sobre partial blocks'  do

  it 'un bloque definido para string matchea con strings ' do

    helloBlock = PartialBlock.new([String]) do |who| #esto rompe porque manda un parámetro y según la consigna deberían ser dos, lo voy a preguntar en la lista
      "Hello #{who}"
    end

    helloBlock.matches("a") #true
    helloBlock.matches(1) #false
    helloBlock.matches("a", "b") #false

  end
end