package net.rocketeer.elemental.geometry;

public class Vector<T> {
  public final T x;
  public final T y;
  public final T z;

  public Vector(T x, T y, T z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }
}
