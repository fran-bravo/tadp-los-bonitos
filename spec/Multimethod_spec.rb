require 'rspec'
require_relative '../src/PartialBlock'
require_relative '../src/Multimethod'
require_relative './tanques_fixture'

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




  describe 'tests sobre definicion de multimetodos' do

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

  end



  describe 'tests sobre respond_to?' do

    it 'funciona el respond_to? para partial_def' do

      expect(A.new.respond_to?(:concat)).to eq(true)

    end

    it 'funciona el respond_to? para un método común, en una clase que definió un partial method' do
      expect(A.new.respond_to?(:to_s)).to eq(true)
      # true, define el método normalmente
    end

    it 'funciona el respond_to? para un multimethod preguntando por una firma exactamente como una de las que tiene' do
      expect(A.new.respond_to?(:concat, false, [String,String])).to eq(true)
      # true, los tipos coinciden
    end

    it 'funciona el respond_to? para un multimethod preguntando por una firma que matchea por herencia con una de las que tiene' do
      expect(A.new.respond_to?(:concat, false, [Integer,A])).to eq(true)
      #esto matchea con el partial def que toma [Object, Object]
    end

    it 'puedo preguntar respond_to? por algo que es un método y no un multimétodo, y si especifico la firma no matchea' do
     expect(A.new.respond_to?(:to_s, false, [String])).to eq(false)
      # false, no es un multimethod
    end

    it 'puedo preguntar respond_to? por un multimethod que existe pero con una firma que no tiene, y da false' do
     expect(A.new.respond_to?(:concat, false, [String,String,String])).to eq(false) # false, los tipos no coinciden
    end

    it 'respond_to? me da true si algún ancestro tiene el multimethod' do
      class B < A
      end

      b = B.new
      expect(b.respond_to?(:concat, false, [String, String])).to eq(true)
      a = A.new
      expect(a.respond_to?(:concat, false, [String, String])).to eq(true)
    end

    it 'respond_to? me da true si algún ancestro tiene el multimethod (con mixins)' do
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

      expect(a.respond_to?(:hacer_cosa, false)).to eq(true)
      expect(a.respond_to?(:hacer_cosa, false, 15)).to eq(true)

    end
  end #end describe




  describe 'tests sobre calculo de distancias' do

    it 'La distancia del parámetro se calcula correctamente' do
      expect(Multimethod.new(:metodo).distancia_parametro(Numeric, 3)).to eq(2)
    end

    it 'Se calcula correctamente la distancia de los parámetros' do
      multimetodo = Multimethod.new(:metodo)
      expect(multimetodo.distancia_parametros([Numeric, Numeric], [3, 3.0])).to eq(4)
    end

  end





  it 'Se invoca un multimetodo' do
    expect(A.new.concat('hello', " world!")). to eq("hello world!")
    expect(A.new.concat('hello', 3)). to eq("hellohellohello") #Devuelve esto porque el método se está redefiniendo en un test anterior :/
    expect(A.new.concat(['hello', ' world', '!'])). to eq("hello world!")

  end

  it 'Cuando abro una clase y vuelvo a definir un multimetodo, piso al anterior' do
    mambru = Soldado.new
    denis = Tanque.new

    expect(denis.ataca_a(mambru)).to eq("splat")

  end

  it 'Cuando abro una clase y defino un metodo parcial, no pisa a un metodo parcial con otra firma' do
    denis = Tanque.new
    silva = Tanque.new
    boeing737 = Avion.new

    expect(denis.ataca_a(silva)).to eq("boom")
    expect(denis.ataca_a(boeing737)).to eq("niuuuuuuuum")
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



