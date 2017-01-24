package net.rocketeer.elemental.geometry;

public class Voxel {
  private Point point;
  private final Material material;
  private final double temperature;

  public Voxel(Material material, int temperature) {
    this(material, temperature, new Point(0, 0, 0));
  }

  public Voxel(Material material, int temperature, Point point) {
    this.point = point;
    this.material = material;
    this.temperature = temperature;
  }

  public void setPoint(int x, int y, int z) {
    this.point = new Point(x, y, z);
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
