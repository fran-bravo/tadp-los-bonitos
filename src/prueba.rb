class Paloma
  attr_accessor :energia, :vida

  def vitalidad()
    return self.energia + self.vida
  end

  def perder_energia(energy)
    self.energia -= energy
  end

  def bailar_zumba()
    self.perder_energia(15)
  end

end