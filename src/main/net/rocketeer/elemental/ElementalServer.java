package net.rocketeer.elemental;

import net.rocketeer.elemental.compute.base.Engine;
import net.rocketeer.elemental.geometry.Scene;
import net.rocketeer.elemental.queue.LaplacianTask;
import net.rocketeer.elemental.queue.Task;

public class ElementalServer implements Runnable {
  private final Engine engine;

  public ElementalServer() {
    Engine engine = new Engine();
    engine.programRegistry().register("conv3d", "/programs/conv3d.cl");
    this.engine = engine;
  }

  public static void main(String[] args) {
    ElementalServer server = new ElementalServer();
    Scene scene = new Scene(100);
    server.queue(new LaplacianTask(scene));
    server.run();
  }

  @Override
  public void run() {

  }

  public <T> T queue(Task<T> task) {
    return task.visit(this.engine);
  }
}
