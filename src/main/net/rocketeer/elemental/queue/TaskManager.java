package net.rocketeer.elemental.queue;

public class TaskManager {
  public <T> T queue(Task<T> task) {
    return task.visit(null);
  }
}
