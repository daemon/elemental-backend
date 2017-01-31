package net.rocketeer.elemental.geometry;

public class Voxel {
  private Vector vector;
  private final Material material;
  private final double temperature;

  public Voxel(Material material, int temperature) {
    this(material, temperature, new Vector(0, 0, 0));
  }

  public Voxel(Material material, int temperature, Vector vector) {
    this.vector = vector;
    this.material = material;
    this.temperature = temperature;
  }

  public void setPoint(int x, int y, int z) {
    this.vector = new Vector(x, y, z);
  }

  public Vector point() {
    return this.vector;
  }

  public Material material() {
    return this.material;
  }

  public double temperature() {
    return this.temperature;
  }
}
