package net.rocketeer.elemental.compute.base.param;

import net.rocketeer.elemental.compute.base.Kernel;
import static org.jocl.CL.*;
import org.jocl.*;

import static org.jocl.CL.CL_MEM_READ_WRITE;
import static org.jocl.CL.clCreateBuffer;
import static org.jocl.CL.clSetKernelArg;

public class DoubleArrayParameter extends Parameter<double[]> implements Readable {
  private cl_mem clMemory;

  public DoubleArrayParameter(double[] object) {
    super(object);
  }

  @Override
  public void bind(Kernel kernel, int index) {
    this.clMemory = clCreateBuffer(kernel.program().engine().clContext(), CL_MEM_READ_WRITE | CL_MEM_COPY_HOST_PTR, Sizeof.cl_double *
        this.object.length, Pointer.to(this.object), null);
    clSetKernelArg(kernel.kernel(), index, Sizeof.cl_mem, Pointer.to(this.clMemory));
  }

  @Override
  protected void free() {
    clReleaseMemObject(this.clMemory);
  }

  @Override
  public cl_mem memory() {
    return this.clMemory;
  }

  @Override
  public int size() {
    return Sizeof.cl_double * this.object.length;
  }
}
