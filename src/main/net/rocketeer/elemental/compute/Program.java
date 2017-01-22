package net.rocketeer.elemental.compute;
import static org.jocl.CL.*;
import org.jocl.*;

public class Program implements AutoCloseable {
  private final cl_program clProgram;

  public Program(cl_context context, String programSource) {
    this.clProgram = clCreateProgramWithSource(context, 1, new String[]{programSource}, null, null);
    clBuildProgram(this.clProgram, 0, null, null, null, null);
  }

  @Override
  public void close() {
    clReleaseProgram(this.clProgram);
  }
}
