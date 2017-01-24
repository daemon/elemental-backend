package net.rocketeer.elemental.compute.base.param;

import net.rocketeer.elemental.compute.base.Kernel;
import static org.jocl.CL.*;
import org.jocl.*;

public class IntParameter extends Parameter<Integer> {
  public IntParameter(Integer object) {
    super(object);
  }

  @Override
  public void bind(Kernel kernel, int index) {
    clSetKernelArg(kernel.kernel(), index, Sizeof.cl_int, Pointer.to(new int[]{this.object}));
  }

  @Override
  protected void free() {}
}
