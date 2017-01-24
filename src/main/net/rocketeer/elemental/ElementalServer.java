package net.rocketeer.elemental;

import net.rocketeer.elemental.compute.base.Engine;
import net.rocketeer.elemental.geometry.Material;
import net.rocketeer.elemental.geometry.Scene;
import net.rocketeer.elemental.geometry.Voxel;
import net.rocketeer.elemental.queue.ConvolutionTask;
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
    Scene scene = new Scene(10);
    scene.setVoxel(0, 0, 0, new Voxel(Material.GENERIC, 15));
    server.queue(new ConvolutionTask(scene));
    server.run();
  }

  @Override
  public void run() {

  }

  public <T> T queue(Task<T> task) {
    return task.visit(this.engine);
  }
}
