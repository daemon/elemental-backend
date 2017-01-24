package net.rocketeer.elemental.compute.base;
import static org.jocl.CL.*;
import org.jocl.*;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;

public class Program implements AutoCloseable {
  final cl_program clProgram;
  private final Engine engine;

  public Program(Engine engine, String programSource) {
    this.engine = engine;
    this.clProgram = clCreateProgramWithSource(engine.clContext, 1, new String[]{programSource}, null, null);
    clBuildProgram(this.clProgram, 0, null, null, null, null);
  }

  public Engine engine() {
    return this.engine;
  }

  public static Program fromClassPath(Engine engine, String path) throws IOException {
    BufferedReader reader = new BufferedReader(new InputStreamReader(Program.class.getResourceAsStream(path)));
    String line;
    StringBuilder builder = new StringBuilder();
    while ((line = reader.readLine()) != null)
      builder.append(line);
    return new Program(engine, builder.toString());
  }

  @Override
  public void close() {
    clReleaseProgram(this.clProgram);
  }
}
