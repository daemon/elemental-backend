package net.rocketeer.elemental.compute.base.param;

import net.rocketeer.elemental.compute.base.Kernel;

public abstract class Parameter<T> implements AutoCloseable {
  protected final T object;
  protected int index;
  private Parameter<?> next;

  public Parameter(T object) {
    this(object, 0);
  }

  public Parameter(T object, int index) {
    this.object = object;
    this.index = index;
  }

  public Object get() {
    return this.object;
  }

  @Override
  public void close() {
    this.free();
  }

  public abstract void bind(Kernel kernel, int index);
  protected abstract void free();
}
