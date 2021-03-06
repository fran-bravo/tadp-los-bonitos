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

  def cantidad_de_firmas()
    self.bloques_parciales.size
  end

  def tiene_la_sobrecarga(tipos)
    !(self.pos_firma_exacta(tipos).nil?)
  end

  def acepta_la_sobrecarga(tipos)
    !(self.pos_firma_posible(tipos).nil?)
  end

  def pos_firma_exacta(tipos)
    return self.encontrar_bloque_cumple() do |bloque_parcial| bloque_parcial.types.eql?(tipos) end
  end

  def pos_firma_posible(tipos)
    return self.encontrar_bloque_cumple() do |bloque_parcial| bloque_parcial.matchea(*tipos) end
  end

  def encontrar_bloque_cumple(&bloque)
    return self.bloques_parciales.find_index &bloque
  end

  def agregar_bloque(partial_block)
    posicion = self.pos_firma_exacta(partial_block.types)

    unless posicion == nil
      bloques_parciales.delete_at(posicion)
    end

    bloques_parciales << partial_block

  end

  def todas_mis_firmas()
    firmas = []
    self.bloques_parciales.each do |bloque| firmas << bloque.types  end
    firmas
  end

  def merge_with(multimethod)
    multimethod.todas_mis_firmas.each do |firma|
      if (!self.tiene_la_sobrecarga(firma)) #si el bloque con el que estoy mergeando tiene algo que yo no, lo agarro!
        self.agregar_bloque(multimethod.bloques_parciales[multimethod.pos_firma_exacta(firma)])
      end
    end
  end

end

class BaseError < RuntimeError
end


class Base
  attr_accessor :cliente, :parametros

  def initialize(cliente, *args)
    self.cliente=(cliente)
    unless args.nil?
      self.parametros = args
    end
  end
end



class Module
  attr_accessor :multimetodos #Lista con los multimethods definidos

  def multimetodos
    begin
      return @multimetodos= @multimetodos || [] #esto lo tengo que try..catchear porque no todos los que heredan de module pueden mutarse así
    rescue RuntimeError
      return [] #placeholder para cosas que nunca van a poder ser modificadas, siempre retornen que no tienen multimétodos
    end
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
      definir_partial_def(simbolo, tipos, &bloque)
    end

  end

  def agregar_nuevo_multimethod(simbolo, bloque_parcial)
    nuevo_multimetodo = Multimethod.new(simbolo)
    nuevo_multimetodo.agregar_bloque(bloque_parcial)
    multimetodos << nuevo_multimetodo
  end

  def definir_partial_def(simbolo, tipos, &bloque)
    define_method(simbolo) {|*tipos|
      bloque = self.singleton_class.dame_multimethod(simbolo).elegir_multimethod_apropiado(*tipos)
      self.instance_exec(*tipos, &(bloque.block))}
  end

  def agregar_multimethod_existente(simbolo, bloque_parcial)
    multimetodo = self.multimethod(simbolo)
    multimetodo.agregar_bloque(bloque_parcial)
  end

  def multimethod(simbolo)
    self.multimetodos.detect do |multimethod| multimethod.simbolo == simbolo end
  end

  def dame_multimethod(simbolo)

    mm_a_proveer = Multimethod.new(simbolo) #hago un multimethod vacío

    #recordando que cada clase es su primer propio ancestor, empiezo a mergear
    self.ancestors.each do |ancestro|
      if ancestro.ruby_respond_to?(simbolo)
        break
      end
      if ancestro.tiene_el_multimethod(simbolo, false) #el false no hace falta pero lo pongo para que se vea
        mm_a_proveer.merge_with(ancestro.multimethod(simbolo))
      end
    end

    if mm_a_proveer.cantidad_de_firmas == 0 #esto significa que no heredé nada, porque el símbolo este no lo tenia nadie
      raise_error(NoMethodError)
    end

    mm_a_proveer
  end

  def esta_en_la_jerarquia(simbolo, boolean=false, parameter_list=nil)
    self.ancestors.any? do |ancestro|
        ancestro.tiene_el_multimethod(simbolo, false, parameter_list)
    end
  end

  def tiene_el_multimethod(simbolo, boolean=false, parameter_list=nil)
    lo_tiene = false

    if parameter_list.nil?
      lo_tiene = lo_tiene || self.multimethods.include?(simbolo)
    else
      lo_tiene = lo_tiene || self.multimethods.include?(simbolo) && self.multimethod(simbolo).acepta_la_sobrecarga(parameter_list)
    end

    return lo_tiene

  end

end


module Respondedor
  alias_method :ruby_respond_to?, :respond_to?
  alias_method :ruby_initialize, :initialize

  def respond_to?(simbolo, boolean=false, parameter_list=nil) #El primero es el símbolo, el segundo el boolean y el tercero la lista de clases. Puede no estar.

    lo_responde = (ruby_respond_to?(simbolo, boolean) && parameter_list==nil)

    begin
      lo_responde = lo_responde || self.singleton_class.esta_en_la_jerarquia(simbolo, boolean, parameter_list)
    rescue TypeError => e
      lo_responde = lo_responde || self.class.esta_en_la_jerarquia(simbolo, boolean, parameter_list)
    end

    return lo_responde
  end

  def initialize(*params)
    self.send(:define_singleton_method, :partial_def) {|simbolo, tipos, &bloque| self.singleton_class.partial_def(simbolo, tipos, &bloque)}
    ruby_initialize(*params)
  end
end



class Base

  def method_missing(sym, *args)
    if cliente.respond_to?(sym, true, args[0]) #recordando que el args[0] debería ser la lista de parámetros del multimethod
      cliente.ejecutar_mm_especifico(sym, *args)
    else
      raise BaseError #o bien podría tirarse directamente un NoMethodError (que se puede hacer poniendo super)
    end
  end

end


#********************************************************************************************************
#************************************Ejecucion de un multimethod*****************************************
#********************************************************************************************************

class NoMatchingMultimethodError < StandardError
end

class Multimethod

  def elegir_multimethod_apropiado(*parametros)
    bloques_candidatos = bloques_parciales.select do |partial_block|
      partial_block.matches(*parametros)
    end

    bloque = bloques_candidatos.min_by do |part_block|
      distancia_parametros(part_block.types, parametros)
    end

    if bloque.nil?
      raise(NoMatchingMultimethodError, "No se encuentra un multimétodo con esa firma.")
    end
    return bloque

  end

  def elegir_multimethod_exacto(*parametros)
    bloque_a_retornar = bloques_parciales.find do |partial_block|
      partial_block.types == parametros
    end
    return bloque_a_retornar
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

class Object
  include Respondedor

  def base(*args)
    return Base.new(self, *args)
  end

  def ejecutar_mm_especifico(sym, *tipos_y_args) #por ejemplo le llega :m, [Integer], arg1, arg2...
    tipos, *args = tipos_y_args
    bloque = self.singleton_class.dame_multimethod(sym).elegir_multimethod_exacto(*tipos)
    if bloque == nil
      raise BaseError
    end
    self.instance_exec(*args, &(bloque.block))
  end


end

class Array
  def sum
    self.inject{|sum,x| sum + x }
  end
end

