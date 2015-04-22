require_relative '../src/PartialBlock'

class Multimethod
  attr_accessor :simbolo, :bloques_parciales

  def initialize(method)
    self.simbolo = method
    self.bloques_parciales = []
  end

  def agregar_bloque(partial_block)
    posicion = self.bloques_parciales.find_index do |bloque_parcial| bloque_parcial.types.eql?(partial_block.types) end

    unless posicion == nil
      bloques_parciales.delete_at(posicion)
    end

    bloques_parciales << partial_block

  end

end


class Module
  attr_accessor :multimetodos #Lista con los multimethods definidos

  def multimetodos
    @multimetodos= @multimetodos || []
  end

  def multimethods
    self.multimetodos.map {|multimetodo| multimetodo.simbolo}
  end

  def partial_def(simbolo, tipos, &bloque)

    bloque_parcial = PartialBlock.new(tipos, &bloque)

    if self.multimethods.include?(simbolo)
      self.agregar_multimethod_existente(simbolo, bloque_parcial)
    else
      agregar_nuevo_multimetodo(simbolo, bloque_parcial)
    end

  end

  def agregar_nuevo_multimetodo(simbolo, bloque_parcial)
    nuevo_multimetodo = Multimethod.new(simbolo)
    nuevo_multimetodo.agregar_bloque(bloque_parcial)
    multimetodos << nuevo_multimetodo
  end

  def agregar_multimethod_existente(simbolo, bloque_parcial)
    indice = multimetodos.find_index do |multimethod| multimethod.simbolo == simbolo end
    multimetodos[indice].agregar_bloque(bloque_parcial)
  end

end

module Boolean
end

class TrueClass
  include Boolean
end

class FalseClass
  include Boolean
end

module Respondedor

=begin
  partial_def :respond_to?, [Symbol] do |simbolo|
    self.class.multimethods.include?(simbolo) || super(simbolo)
  end

  partial_def :respond_to?, [Symbol, Boolean] do |simbolo, bool|
    self.class.multimethods.include?(simbolo) || super(simbolo, bool)
  end

  partial_def :respond_to?, [Symbol, Boolean, Array] do |simbolo, bool, tipos|
    self.class.multimethods.include?(simbolo) && self.coinciden_los_tipos(simbolo, tipos)
  end

  def coinciden_los_tipos(simbolo, tipos)
    indice = @@multimetodos.find_index do |multimethod| multimethod.simbolo == simbolo end
    @@multimetodos[indice].bloques_parciales.any do |bloque|
      bloque.types == tipos
    end
  end
=end

  def respond_to?(*parametros) #El primero es el símbolo, el segundo el boolean y el tercero la lista de clases. Puede no estar.

    self.class.multimethods.include?(parametros.first) || super
  end

end

class Object
  include Respondedor
end

