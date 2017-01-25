package net.rocketeer.elemental.queue;

import net.rocketeer.elemental.compute.base.Engine;
import net.rocketeer.elemental.compute.base.Kernel;
import net.rocketeer.elemental.compute.base.Program;
import net.rocketeer.elemental.compute.base.param.ParameterPack;
import net.rocketeer.elemental.compute.conv.LaplacianParameterPack;
import net.rocketeer.elemental.geometry.Scene;
import org.jocl.Pointer;

import java.util.Arrays;
import java.util.Optional;

public class LaplacianTask implements Task<Boolean> {
  private final Scene scene;

  public LaplacianTask(Scene scene) {
    this.scene = scene;
  }

  @Override
  public Boolean visit(Engine engine) {
    long a, b;
    Optional<Program> program = engine.programRegistry().findProgram("conv3d");
    if (!program.isPresent())
      return false;
    double[] result = new double[this.scene.length()];
    try (Kernel convKernel = new Kernel(program.get(), "conv3d")) {
      a = System.currentTimeMillis();
      ParameterPack params = new LaplacianParameterPack(this.scene.heatPoints(), this.scene.buffer()).params();
      b = System.currentTimeMillis();
      convKernel.bind(params);
      Engine.ResultPack pack = engine.execute(convKernel, new long[]{this.scene.length()}, new long[]{1});
      System.out.println(pack.returnCode());
      pack.readInto(2, Pointer.to(result)).finish();
    }
    System.out.println(Arrays.toString(result));
    System.out.println("Timing (ms): " + (b - a));
    return true;
  }
}
