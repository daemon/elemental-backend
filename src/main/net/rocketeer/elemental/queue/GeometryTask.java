package net.rocketeer.elemental.queue;

import net.rocketeer.elemental.geometry.Scene;

public abstract class GeometryTask<T> extends Task<T> {
  private final Scene scene;

  public GeometryTask(TaskType type, Scene scene) {
    super(TaskType.GEOMETRY_TASK);
    this.scene = scene;
  }
}
