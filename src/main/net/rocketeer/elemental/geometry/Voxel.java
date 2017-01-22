package net.rocketeer.elemental.geometry;

public class Voxel {
  private final Point point;
  private final Material material;
  private final double temperature;

  public Voxel(Point point, Material material, int temperature) {
    this.point = point;
    this.material = material;
    this.temperature = temperature;
  }

  public Point point() {
    return this.point;
  }

  public Material material() {
    return this.material;
  }

  public double temperature() {
    return this.temperature;
  }
}
