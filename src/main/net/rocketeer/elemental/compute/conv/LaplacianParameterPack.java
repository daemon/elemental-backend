package net.rocketeer.elemental.compute.conv;

import net.rocketeer.elemental.compute.base.param.DoubleArrayParameter;
import net.rocketeer.elemental.compute.base.param.IntParameter;
import net.rocketeer.elemental.compute.base.param.ParameterPack;

public class LaplacianParameterPack {
  private final double[] field;
  private final ParameterPack params;

  public LaplacianParameterPack(double[] field, double[] buffer, int size) {
    long a, b;
    a = System.currentTimeMillis();
    this.field = field;
    System.out.println(this.field.length);
    this.params = new ParameterPack(new DoubleArrayParameter(this.field), new DoubleArrayParameter(new double[]{0, 0, 0, 0, 1, 0,
      0, 0, 0, 0, 1, 0, 1, -6, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0}), new DoubleArrayParameter(buffer),
        new IntParameter(size), new IntParameter(3));
    b = System.currentTimeMillis();
    System.out.println("Timing (ms): " + (b - a));
  }

  public ParameterPack params() {
    return params;
  }
}
