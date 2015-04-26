require_relative '../src/PartialBlock'

#********************************************************************************************************
#************************************Definicion de un multimethod****************************************
#********************************************************************************************************

class Multimethod
  attr_accessor :simbolo, :bloques_parciales

  def initialize(method)
    self.simbolo = method
    self.bloques_parciales = []
  end

  def tiene_la_sobrecarga(tipos)
    !(self.pos_firma_exacta(tipos).nil?)
  end

  def acepta_la_sobrecarga(tipos)
    !(self.pos_firma_posible(tipos).nil?)
  end


  def pos_firma_exacta(tipos)
    return self.bloques_parciales.find_index do |bloque_parcial| bloque_parcial.types.eql?(tipos) end
  end

  def pos_firma_posible(tipos)
    return self.bloques_parciales.find_index do |bloque_parcial| bloque_parcial.matches(*tipos) end
  end

  def agregar_bloque(partial_block)
    posicion = self.pos_firma_exacta(partial_block.types)

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
      agregar_nuevo_multimethod(simbolo, bloque_parcial)
    end

    if self.multimethods.include?(simbolo)
      define_method(simbolo) {|*tipos| self.class.multimethod(simbolo).elegir_multimethod_apropiado(*tipos)}
    end

  end

  def agregar_nuevo_multimethod(simbolo, bloque_parcial)
    nuevo_multimetodo = Multimethod.new(simbolo)
    nuevo_multimetodo.agregar_bloque(bloque_parcial)
    multimetodos << nuevo_multimetodo
  end

  def agregar_multimethod_existente(simbolo, bloque_parcial)
    multimetodo = self.multimethod(simbolo)
    multimetodo.agregar_bloque(bloque_parcial)
  end

  def multimethod(simbolo)
    self.multimetodos.detect do |multimethod| multimethod.simbolo == simbolo end
  end

  def tiene_el_multimethod(simbolo, boolean=false, parameter_list=nil)
    lo_tiene = false

    if parameter_list.nil?
      lo_tiene = lo_tiene || self.multimethods.include?(simbolo)
    else
      lo_tiene = lo_tiene || self.multimethods.include?(simbolo) && self.multimethod(simbolo).acepta_la_sobrecarga(parameter_list)
    end

    if boolean==true
      for ancestro in self.ancestors
        lo_tiene = lo_tiene || ancestro.tiene_el_multimethod(simbolo, false, parameter_list)
        #aca va false porque esto no tiene que ser recursivo! si lo fuera entraria en un loop infinito
        #basta con que alguno de sus ancestros (que ya vienen convenientemente aplanados) tenga el multimethod
        #todos los ancestros son siempre Modules y por lo tanto lo entienden
      end
    end

    return lo_tiene

  end

end


module Respondedor
  alias_method :ruby_respond_to?, :respond_to?

  def respond_to?(simbolo, boolean=false, parameter_list=nil) #El primero es el símbolo, el segundo el boolean y el tercero la lista de clases. Puede no estar.
    return (ruby_respond_to?(simbolo, boolean) && parameter_list==nil) || self.class.tiene_el_multimethod(simbolo, boolean, parameter_list)
  end

end



class Object
  include Respondedor
end

#********************************************************************************************************
#************************************Ejecucion de un multimethod*****************************************
#********************************************************************************************************

class Multimethod

  def elegir_multimethod_apropiado(*parametros)
    bloques_candidatos = bloques_parciales.select do |partial_block|
      partial_block.matches(*parametros)
    end

    bloque = bloques_candidatos.min_by do |part_block|
      distancia_parametros(part_block.types, parametros)
    end

    bloque.call(*parametros)

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


class Array
  def sum
    self.inject{|sum,x| sum + x }
  end
end

