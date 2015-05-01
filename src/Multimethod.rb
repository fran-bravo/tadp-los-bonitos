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

module Respondedor
  alias_method :ruby_respond_to?, :respond_to?
  alias_method :ruby_initialize, :initialize
end


class Module
  attr_accessor :multimetodos #Lista con los multimethods definidos

#  def imm_provider
#    self.class
#  end

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
    end

    if self.multimethods.include?(simbolo)
      define_method(simbolo) {|*tipos| bloque = self.singleton_class.dame_multimethod(simbolo).elegir_multimethod_apropiado(*tipos)
                              self.instance_exec(*tipos, &(bloque.block))} #qué mierda es esto lo puedo romper?
      #básicamente lo bonito que teníamos de delegar al PartialBlock para la ejecución no sirve más
      #tengo que romper sí o sí ese encapsulamiento y obtener el proc de más bajo nivel
      #de otra forma pierdo la posibilidad de hacer instance_exec en la clase que quiero, Module
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
  alias_method :ruby_initialize, :initialize

  def respond_to?(simbolo, boolean=false, parameter_list=nil) #El primero es el símbolo, el segundo el boolean y el tercero la lista de clases. Puede no estar.
    lo_responde = false
    lo_responde = lo_responde || (ruby_respond_to?(simbolo, boolean) && parameter_list==nil)

    #lo_responde = lo_responde || self.class.tiene_el_multimethod(simbolo, boolean, parameter_list)

    begin
      lo_responde = lo_responde || self.singleton_class.tiene_el_multimethod(simbolo, boolean, parameter_list)
    rescue
      lo_responde = lo_responde || self.class.tiene_el_multimethod(simbolo, boolean, parameter_list)
        #ESTO RUBY NUNCA LO EJECUTA
        #NO SE POR QUE
    else
      #asi que lo repito acá, y sí lo ejectuta
      lo_responde = lo_responde || self.class.tiene_el_multimethod(simbolo, boolean, parameter_list)
    end


    return lo_responde
  end

  def initialize(*params)
    self.send(:define_singleton_method, :partial_def) {|simbolo, tipos, &bloque| self.singleton_class.partial_def(simbolo, tipos, &bloque)}
    ruby_initialize(*params)
  end
end



class Object
#  def imm_provider
#    self.singleton_class
#    self.class
#  end

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

    return bloque

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

