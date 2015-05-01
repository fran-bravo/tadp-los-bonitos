require 'rspec'
require_relative './tanques_fixture'
require_relative '../src/Multimethod'
require_relative '../src/PartialBlock'

describe 'Tests sobre multimetodos definidos en objetos' do

  class A

  end

  tanque_modificado = Tanque.new
  tanque_modificado.partial_def :tocar_bocina_a, [Soldado] do |soldado|
    "Honk honk! #{soldado.nombre}"
  end

  tanque_modificado.partial_def :tocar_bocina_a, [Tanque] do |tanque|
    "Hooooooonk!"
  end


  it 'Un objeto entiende partial_def' do
    a = A.new

    expect(a.respond_to?(:partial_def)).to eq(true)
  end

  it 'Se define un partial_def en un objeto y solo para ese objeto' do
    a = A.new
    a.partial_def(:gritar, [String]) do |grito| grito + "!" end

    expect(a.gritar("buu")).to eq("buu!")
    expect(A.new.respond_to?(:gritar)).to eq(false) 
  end


  it 'Se define un partial_def en un objeto y no funciona para otro objeto' do
    a = A.new
    a.partial_def(:gritar, [String]) do |grito| grito + "!" end

    expect(a.gritar("buu")).to eq("buu!")
    expect{A.new.gritar("buu")}.to raise_error
  end

  it 'Funciona respond_to? cuando se agrega un multimetodo solo a una instancia' do
    nueva_a = A.new

    nueva_a.partial_def :multiplicar, [Integer, Integer] do |num1, num2| num1*num2 end #De momento no está implementado
    expect(nueva_a.respond_to?(:multiplicar, [Integer, Integer])).to eq(true)
  end

  begin
    it 'Funciona un multimétodo agregado sólo a una instancia' do
      otra_a = A.new

      otra_a.partial_def :hablar, [String] do  |s| return s end
      expect(otra_a.hablar("ola ke ase")). to eq("ola ke ase")

    end
end

# it 'responds_to? con true funciona cuando agrego un mixin directamente a un objeto' do
#   a = String.new
#   a.extend(Coso)
#   expect(a.respond_to?(:hacer_cosa, true)).to eq(true)
#   expect(a.respond_to?(:hacer_cosa, true, 15)).to eq(true)
# end

#para este test de acá arriba habría que esperar a implementar herencia

  it 'un objeto ejecuta bien los multimethods que le defino a nivel objeto' do
    expect(tanque_modificado.tocar_bocina(Soldado.new("pepe"))).to eq("Honk Honk! pepe") # "Honk Honk! pepe"
    expect(tanque_modificado.tocar_bocina(Tanque.new)).to eq("Hooooooonk!") # "Hooooooonk!"
  end

  it 'el scope del multimethod definido en un objeto es sólo ese objeto y no se propaga a toda la clase' do
  expect{Tanque.new.tocar_bocina(Tanque.new)}.to raise_error
  end

end