require 'rspec'
require_relative '../spec/tanques_fixture'

describe 'pruebas sobre herencia de multimétodos' do

  class Panzer < Tanque
  end


  describe 'pruebas basicas' do

    it 'Panzer hereda otro multimétodo de Tanque' do
      panzer = Panzer.new
      expect(panzer.ataca_a(Tanque.new)).to eq("boom")
    end

    it 'Panzer hereda el multimétodo de atacar a un tanque y matchea cuando le paso un panzer' do
      panzer = Panzer.new
      expect(panzer.ataca_a(Panzer.new)).to eq("boom")
    end

  end

  describe 'pruebas sobre redefiniciones parciales'do

    class Radar
    end
    class Panzer < Tanque

      def neutralizar(objetivo)
        "pium pium - neutralizado"
      end

      def uber_atacar_a(objetivo)
        "uber-kaboom"
      end

      partial_def :ataca_a, [Radar] do |radar|
        #Esta definición se suma a las heredadas de Tanque, sin pisar ninguna
        self.neutralizar(radar)
      end

      partial_def :ataca_a, [Soldado] do |soldado|
        #Pisa la definición parcial de la superclase correspondiente al soldado
        self.uber_atacar_a(soldado)
      end

    end

    it 'Una definición parcial sumada a las ya existentes funca OK' do
      radarin = Radar.new
      panzer = Panzer.new

      expect(panzer.ataca_a(radarin)).to eq("pium pium - neutralizado")
    end

    it 'Una definición parcial que redefine una heredada funca OK' do
      mambru = Soldado.new
      panzer = Panzer.new

      expect(panzer.ataca_a(mambru)).to eq("uber-kaboom")
    end

    it 'Una definición parcial en una subclase no interfiere con la clase original' do
      radarin = Radar.new
      mambru = Soldado.new
      tanque = Tanque.new

      expect(tanque.ataca_a(mambru)).to eq("splat")
      expect{tanque.ataca_a(radarin)}.to raise_error(NoMethodError)
    end

    it 'Una definición parcial en una subclase no interfiere con otras subclases' do
      class TanqueConRuedas < Tanque
      end

      radarin = Radar.new
      tanque_raro = TanqueConRuedas.new
      mambru = Soldado.new

      expect(tanque_raro.ataca_a(mambru)).to eq("splat")
      expect{tanque_raro.ataca_a(radarin)}.to raise_error(NoMethodError)

    end


  end



  describe 'tests sobre redefinición entre métodos parciales y totales' do

    class Tanque
      def chocar(objetivo)
        return "crash!"
      end
    end

    class NueveDeArea < Tanque
      def ataca_a(objetivo) #redefino un método parcial con uno total
        return "uh! fuerte, cruzado y desviado"
      end
    end

    class Arquero < Tanque

      #y acá redefino un método total con uno parcial
      partial_def :chocar, [] do
        "que palo se pego!"
      end

      partial_def :chocar, [NueveDeArea] do |nueve|
        "durisimo! patada criminal"
      end

    end


    it 'método de subclase redefine método parcial de superclase' do

      denis = NueveDeArea.new

      expect(denis.ataca_a(Soldado.new)).to eq("uh! fuerte, cruzado y desviado")
      expect(denis.ataca_a(Tanque.new)).to eq("uh! fuerte, cruzado y desviado")
      expect(denis.ataca_a(Object.new)).to eq("uh! fuerte, cruzado y desviado")
      expect(denis.ataca_a(nil)).to eq("uh! fuerte, cruzado y desviado")

    end

    it 'multimétodo de subclase redefine método total de superclase' do
      sessa = Arquero.new
      palacio = NueveDeArea.new

      expect(sessa.chocar).to eq("que palo se pego!")
      expect(sessa.chocar(palacio)).to eq("durisimo! patada criminal")
    end

  end

  describe 'tests sobre especificidad de multimétodos y lugar en la jerarquía de herencia' do

    class A
      partial_def :m, [String] do |s|
        "A>m #{s}"
      end

      partial_def :m, [Numeric] do |n|
        "A>m" * n
      end

      partial_def :m, [Object] do |o|
        "A>m and Object"
      end

    end

    class B < A
      partial_def :m, [Object] do |o|
        "B>m and Object"
      end
    end

    it 'multimétodo específico heredado vence a multimétodo vago de la clase propia' do

      #cómo entender este test
      #B define un m para Object
      #A define un m para Object, uno para String y uno para Numeric
      #B hereda de a
      #si llamo al método con Object, tiene que ejecutar el de B, por encontrarse más cerca en la jerarquía
      #pero si llamo al método con String o Numeric tiene que ejecutar el de A
      #porque aunque esté más lejos en la jerarquía que el de B para Object, es más específico

      b = B.new

      expect(b.m("hello")).to eq("A>m hello") # ejecuta A>m[String]
      expect(b.m(Object.new)).to eq("B>m and Object")
      expect(b.m(3)).to eq("A>mA>mA>m")

    end


  end

  it 'un método normal de una subclase pisa al multimétodo de la superclase' do
    class Tiger < Tanque
      def ataca_a(un_oponente)
        "¡Hola, wachines!"
      end
    end

    expect(Tiger.new.ataca_a(1)).to eq("¡Hola, wachines!")
  end

  it 'un multimétodo de una subclase pisa al método común de la superclase' do
    class Tiger < Tanque
      partial_def :pisar, [Object] do |obj|
        "Lo pisé."
      end
    end

    expect(Tiger.new.pisar(1)).to eq("Lo pisé.")
  end


end
