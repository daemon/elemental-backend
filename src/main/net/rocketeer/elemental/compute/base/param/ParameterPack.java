package net.rocketeer.elemental.compute.base.param;

public class ParameterPack {
  private final Parameter<?>[] params;

  public ParameterPack(Parameter<?> ... params) {
    this.params = params;
  }

  public Parameter<?>[] params() {
    return this.params;
  }

  public Parameter<?> at(int index) {
    return this.params[index];
  }
}
