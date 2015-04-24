require_relative '../src/PartialBlock'

class Multimethod
  attr_accessor :simbolo, :bloques_parciales

  def initialize(method)
    self.simbolo = method
    self.bloques_parciales = []
  end

  def tiene_la_sobrecarga(tipos)
    if self.pos_sobrecarga_exacta(tipos).nil?
      return false
    end
    return true
  end

  def acepta_la_sobrecarga(tipos)
    if self.pos_sobrecarga_posible(tipos).nil?
      return false
    end
    return true
  end


  def pos_sobrecarga_exacta(tipos)
    return self.bloques_parciales.find_index do |bloque_parcial| bloque_parcial.types.eql?(tipos) end
  end

  def pos_sobrecarga_posible(tipos)
    return self.bloques_parciales.find_index do |bloque_parcial| bloque_parcial.matches(*tipos) end
  end

  def agregar_bloque(partial_block)
    posicion = self.pos_sobrecarga_exacta(partial_block.types)

    unless posicion == nil
      bloques_parciales.delete_at(posicion)
    end

    bloques_parciales << partial_block

  end

  def enviar_multimetodo(parametros)
    bloques_candidatos = bloques_parciales.select do |partial_block|
      partial_block.matches(parametros)
    end

    bloque = bloques_candidatos.max_by do |part_block|
      self.distancia_parametros(part_block.types, parametros)
    end

    bloque.call(parametros)

  end

  def distancia_parametros(tipos, parametros)
    distancias = tipos.map do |tipo|
      indice = tipos.find_index(tipo)
      self.distancia_parametro(tipo, parametros[indice]) * (indice + 1)
    end
    distancias.sum
  end

  def distancia_parametro(tipo, parametro)
    parametro.class.ancestors.index(tipo)
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
    multimetodo = self.multimethod_requerido(simbolo)
    multimetodo.agregar_bloque(bloque_parcial)
  end

  def multimethod_requerido(simbolo)
    self.multimetodos.detect do |multimethod| multimethod.simbolo == simbolo end
  end

  def tiene_el_multimethod(simbolo, parameter_list=nil)
    if parameter_list.nil?
      return self.multimethods.include?(simbolo)
    else
      return self.multimethods.include?(simbolo) && self.multimethod_requerido(simbolo).acepta_la_sobrecarga(parameter_list)
    end

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

  alias_method :ruby_respond_to?, :respond_to?

  def respond_to?(simbolo, boolean=false, parameter_list=nil) #El primero es el símbolo, el segundo el boolean y el tercero la lista de clases. Puede no estar.
      return self.class.tiene_el_multimethod(simbolo, parameter_list) || (ruby_respond_to?(simbolo, boolean) && parameter_list==nil)
  end

end

module Ejecutor
=begin
  def send(*parametros)
    metodo = parametros.first
    parametros.delete_at(0)

    self.class.multimethod_requerido(metodo).enviar_multimetodo(parametros)
  end
=end
end

class Object
  include Respondedor
  include Ejecutor
end

class Array
  def sum
    self.inject{|sum,x| sum + x }
  end
end

