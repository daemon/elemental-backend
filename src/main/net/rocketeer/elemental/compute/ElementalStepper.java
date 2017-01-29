package net.rocketeer.elemental.compute;

import net.rocketeer.elemental.geometry.Scene;

public class ElementalStepper {
  private final Scene scene;
  private final ElementalLibrary library;

  public ElementalStepper(Scene scene) {
    this.scene = scene;
    this.library = ElementalLibrary.get();
  }

  public ElementalStepper step(float dt) {
    this.library.heat3d(scene.heatData().heatPoints(), scene.buffer(), scene.heatData().heatCoeffs(), dt, scene.width());
    return this;
  }
}
