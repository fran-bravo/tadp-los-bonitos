require 'rspec'
require_relative './tanques_fixture'
require_relative '../src/Multimethod'
require_relative '../src/PartialBlock'

describe 'Tests sobre multimetodos definidos en objetos' do

  class A

  end

  tanque_modificado = Tanque.new
  tanque_modificado.partial_def :tocar_bocina_a, [Soldado] do |soldado|
    "Honk Honk! #{soldado.nombre}"
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
    expect{A.new.gritar("buu")}.to raise_error(NoMethodError)
  end

  it 'Funciona respond_to? cuando se agrega un multimetodo solo a una instancia' do
    nueva_a = A.new

    nueva_a.partial_def :multiplicar, [Integer, Integer] do |num1, num2| num1*num2 end #De momento no está implementado
    expect(nueva_a.respond_to?(:multiplicar, false, [Integer, Integer])).to eq(true)
  end

 # begin
    it 'Funciona un multimétodo agregado sólo a una instancia' do
      otra_a = A.new

      otra_a.partial_def :hablar, [String] do |s| s end
      expect(otra_a.hablar("ola ke ase")). to eq("ola ke ase")

    end
#end

 it 'responds_to? funciona cuando agrego un mixin directamente a un objeto' do
   module Coso
     partial_def :hacer_cosa, [] do
       return "que cosa che!"
     end

     partial_def :hacer_cosa, [Object] do |object|
       return "guarda que me dieron un parametro"
     end
   end
   #ojo que este Coso repite código, es el mismo Coso que usé en multimethod_spec

   a = String.new
   a.extend(Coso)
   expect(a.respond_to?(:hacer_cosa, false)).to eq(true)
   expect(a.respond_to?(:hacer_cosa, false, [Integer])).to eq(true)
 end

#para este test de acá arriba habría que esperar a implementar herencia

  it 'un objeto ejecuta bien los multimethods que le defino a nivel objeto' do
    expect(tanque_modificado.tocar_bocina_a(Soldado.new("pepe"))).to eq("Honk Honk! pepe") # "Honk Honk! pepe"
    expect(tanque_modificado.tocar_bocina_a(Tanque.new)).to eq("Hooooooonk!") # "Hooooooonk!"
  end

  it 'el scope del multimethod definido en un objeto es sólo ese objeto y no se propaga a toda la clase' do
    expect{Tanque.new.tocar_bocina_a(Tanque.new)}.to raise_error
  end

  it 'un objeto con algo parcialmente definido sabe que responde a eso' do
    expect(tanque_modificado.respond_to?(:tocar_bocina_a, false, [Soldado])).to eq(true)
  end

  it 'un multimethod definido en un objeto se agrega a la lista de multimethods de su singleton class' do
    expect(tanque_modificado.singleton_class.multimetodos.size).to eq(1)
  end

  it 'los multimethods que hay en la clase no están en la singleton class' do
    expect(Tanque.multimethods.size).to eq(1)
    expect(Tanque.new.singleton_class.multimethods.size).to eq(0)
  end

end