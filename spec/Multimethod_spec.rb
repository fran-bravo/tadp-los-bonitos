require 'rspec'
require_relative '../src/PartialBlock'
require_relative '../src/Multimethod'

describe 'Tests sobre multimethods' do

  before (:each) do
    class A

      partial_def :concat, [String, String] do |s1, s2|
        s1 + s2
      end


      partial_def :concat, [String, Integer] do |s1,n|
        s1 * n
      end

      partial_def :concat, [Array] do |a|
        a.join
      end

      partial_def :concat, [Object, Object] do |o1, o2|
        "Objetos concatenados"
      end
    end

    end


  it 'Se definió un multimétodo' do
    expect(A.multimetodos.length).to eq(1)
  end

  it 'Se definió un multimétodo con 4 definiciones parciales' do
    expect(A.multimetodos[0].bloques_parciales.length).to eq(4)
  end

  it 'Se redefine un multimétodo, que sobreescribe otro con los mismos tipos' do
    class A
      partial_def :concat, [String, Integer] do |s1, n| "Hola Maiu!" end
    end

    expect(A.multimetodos.first.bloques_parciales.last.call("Juli", 9)).to eq("Hola Maiu!")
    expect(A.multimetodos.first.bloques_parciales.length).to eq(4)
  end

  it 'Se puede preguntar por los multimétodos definidos en la clase' do
    expect(A.multimethods).to eq([:concat])
  end

  it 'funciona el responds_to? para partial_def' do

    expect(A.new.respond_to?(:concat)).to eq(true)

  end

  it 'funciona el responds_to? para un método común, en una clase que definió un partial method' do
    expect(A.new.respond_to?(:to_s)).to eq(true)
    # true, define el método normalmente
  end

  it 'funciona el responds_to? para un multimethod preguntando por una firma exactamente como una de las que tiene' do
    expect(A.new.respond_to?(:concat, false, [String,String])).to eq(true)
    # true, los tipos coinciden
  end

  it 'funciona el responds_to? para un multimethod preguntando por una firma que matchea por herencia con una de las que tiene' do
    expect(A.new.respond_to?(:concat, false, [Integer,A])).to eq(true)
    #esto matchea con el partial def que toma [Object, Object]
  end

  it 'puedo preguntar responds_to? por algo que es un método y no un multimétodo, y si especifico la firma no matchea' do
   expect(A.new.respond_to?(:to_s, false, [String])).to eq(false)
    # false, no es un multimethod
  end

  it 'puedo preguntar responds_to? por un multimethod que existe pero con una firma que no tiene, y da false' do
   expect(A.new.respond_to?(:concat, false, [String,String,String])).to eq(false) # false, los tipos no coinciden
  end

  it 'responds_to? con true me da true si algún ancestro tiene el multimethod' do
    module Coso
      partial_def :hacer_cosa, [] do
        return "que cosa che!"
      end

      partial_def :hacer_cosa, [Object] do |object|
        return "guarda que me dieron un parametro"
      end
    end

    A.include(Coso)
    a = A.new

    expect(a.respond_to?(:hacer_cosa, true)).to eq(true)
    expect(a.respond_to?(:hacer_cosa, true, 15)).to eq(true)

  end

  it 'responds_to? con true funciona cuando agrego un mixin directamente a un objeto' do
    a = String.new
    a.extend(Coso)
    expect(a.respond_to?(:hacer_cosa, true)).to eq(true)
    expect(a.respond_to?(:hacer_cosa, true, 15)).to eq(true)
  end



  it 'La distancia del parámetro se calcula correctamente' do
    expect(Multimethod.new(:metodo).distancia_parametro(Numeric, 3)).to eq(2)
  end

  it 'Se calcula correctamente la distancia de los parámetros' do
    multimetodo = Multimethod.new(:metodo)
    expect(multimetodo.distancia_parametros([Numeric, Numeric], [3, 3.0])).to eq(4)
  end

  it 'Se invoca un multimetodo' do
    expect(A.new.concat('hello', " world!")). to eq("hello world!")
    expect(A.new.concat('hello', 3)). to eq("hellohellohello") #Devuelve esto porque el método se está redefiniendo en un test anterior :/
    expect(A.new.concat(['hello', ' world', '!'])). to eq("hello world!")

  end

  it 'Se agrega un multimetodo solo a una instancia' do
    nueva_a = A.new

    #nueva_a.partial_def :multiplicar, [Integer, Integer] do |num1, num2| num1*num2 end #De momento no está implementado
    #expect(nueva_a.respond_to?(:multiplicar, false, [Integer, Integer])).to eq(true)
  end

  it 'Muestra la representacion de un multimethod' do
    expect(A.multimethod(:concat).class). to eq(Multimethod)
  end

  it 'Puedo llamar a self desde un multimethod' do

    class Alumno
      attr_accessor :nombre

      def initialize(nombre)
        self.nombre = nombre
      end

      def to_s
        return self.nombre
      end

      partial_def :agregar_titulo, [String] do |titulo| #un alumno sabe recibirse. el modelo puede no reflejar con precision la realidad
        titulo + self.to_s
      end

      partial_def :agregar_titulo, [] do
        "Ing. " + self.to_s
      end

    end

    dario = Alumno.new("Dario") #autobombo pattern

    expect(dario.agregar_titulo).to eq("Ing. Dario") #si el test da verde me recibo?

  end


  end



