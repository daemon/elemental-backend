package net.rocketeer.elemental.queue;

import net.rocketeer.elemental.compute.Engine;

public abstract class Task<T> {
  private final TaskType type;
  private final long timestamp;

  public Task(TaskType type) {
    this.type = type;
    this.timestamp = System.nanoTime() * 1000000;
  }

  public TaskType type() {
    return this.type;
  }

  public long timestampMillis() {
    return this.timestamp;
  }

  public abstract T visit(Engine engine);
}
