package net.rocketeer.elemental.compute.base;

import java.io.IOException;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

public class ProgramRegistry {
  private final Map<String, Program> programMap = new HashMap<>();
  private final Engine engine;

  public ProgramRegistry(Engine engine) {
    this.engine = engine;
  }

  public ProgramRegistry register(String name, Program program) {
    if (this.engine.clContext != program.engine().clContext())
      return this;
    this.programMap.put(name, program);
    return this;
  }

  public ProgramRegistry register(String name, String classPath) {
    try {
      this.programMap.put(name, Program.fromClassPath(this.engine, classPath));
    } catch (IOException e) {
      e.printStackTrace();
    }
    return this;
  }

  public Optional<Program> findProgram(String name) {
    return Optional.ofNullable(this.programMap.get(name));
  }
}
