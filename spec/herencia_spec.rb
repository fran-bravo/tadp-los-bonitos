require 'rspec'
require_relative '../spec/tanques_fixture'

describe 'pruebas sobre herencia de multimétodos' do

  class Panzer < Tanque
  end

  it 'Panzer hereda el multimétodo de Tanque' do
    panzer = Panzer.new
    expect(panzer.ataca_a(Soldado.new)).to eq("splat")
  end


  describe 'tests sobre orden de redefinición' do

    class Tanque
      def chocar(objetivo)
        return "crash!"
      end
    end

    class NueveDeArea < Tanque
      def ataca_a(objetivo)
        return "uh! fuerte, cruzado y desviado"
      end
    end

    class Arquero < Tanque

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
end