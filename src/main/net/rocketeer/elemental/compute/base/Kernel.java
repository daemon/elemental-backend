package net.rocketeer.elemental.compute.base;
import static org.jocl.CL.*;

import net.rocketeer.elemental.compute.base.param.Parameter;
import net.rocketeer.elemental.compute.base.param.ParameterPack;
import org.jocl.*;

public class Kernel implements AutoCloseable {
  private final String id;
  private final Program program;
  final cl_kernel kernel;
  private ParameterPack params;

  public Kernel(Program program, String fnName) {
    this.id = fnName;
    this.program = program;
    int[] rc = {0};
    this.kernel = clCreateKernel(program.clProgram, this.id, rc);
    System.out.println(rc[0]);
  }

  public Program program() {
    return this.program;
  }

  public cl_kernel kernel() {
    return this.kernel;
  }

  public ParameterPack params() {
    return this.params;
  }

  public void bind(ParameterPack pack) {
    this.params = pack;
    for (int i = 0; i < pack.params().length; ++i)
      pack.params()[i].bind(this, i);
  }

  public String id() {
    return this.id;
  }

  @Override
  public void close() {
    if (this.params != null)
      for (Parameter<?> param : this.params.params())
        param.close();
    this.params = null;
    clReleaseKernel(this.kernel);
  }
}
