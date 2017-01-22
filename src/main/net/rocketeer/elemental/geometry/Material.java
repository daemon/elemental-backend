package net.rocketeer.elemental.geometry;

public enum Material {
  GENERIC(0.2);
  private final double heatCoeff;
  Material(double heatCoeff) {
    this.heatCoeff = heatCoeff;
  }
}
