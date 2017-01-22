package net.rocketeer.elemental.geometry;

public class Point {
  public final int x;
  public final int y;
  public final int z;
  private final int[] array;

  public Point(int x, int y, int z) {
    this.x = x;
    this.y = y;
    this.z = z;
    this.array = new int[] {x, y, z};
  }

  public int[] array() {
    return this.array;
  }
}
