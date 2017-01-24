package net.rocketeer.elemental.compute.conv;

import net.rocketeer.elemental.compute.base.Extractor;
import net.rocketeer.elemental.compute.base.param.DoubleArrayParameter;
import net.rocketeer.elemental.compute.base.param.IntParameter;
import net.rocketeer.elemental.compute.base.param.ParameterPack;

public class ConvolutionParameterPack {
  private final double[] field;
  private final ParameterPack params;

  public <T> ConvolutionParameterPack(T[][][] objects, Extractor<Double, T> extractor) {
    this.field = new double[objects.length * objects[0].length * objects[0][0].length];
    int n = objects.length;
    int m = objects[0].length;
    for (int i = 0; i < objects.length; ++i)
      for (int j = 0; j < objects[i].length; ++j)
        for (int k = 0; k < objects[i][j].length; ++k)
          this.field[n * m * i + m * j + k] = extractor.extract(objects[i][j][k]);
    this.params = new ParameterPack(new DoubleArrayParameter(this.field), new DoubleArrayParameter(new double[]{1, 2, 3}),
        new IntParameter(11), new IntParameter(11));
  }

  public ParameterPack params() {
    return params;
  }
}
