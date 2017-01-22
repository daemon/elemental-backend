package net.rocketeer.elemental.queue;

import net.rocketeer.elemental.compute.Engine;
import net.rocketeer.elemental.geometry.Scene;

public class CreateGeometryTask extends GeometryTask<Boolean> {
  public CreateGeometryTask(TaskType type, Scene scene) {
    super(type, scene);
  }

  @Override
  public Boolean visit(Engine engine) {
    return true;
  }
}
