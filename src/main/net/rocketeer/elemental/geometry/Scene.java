package net.rocketeer.elemental.geometry;

public class Scene {
  private final int width;
  private final int height;
  private final int depth;
  private final HeatData heatData;
  private float[] buffer;

  private final Point origin;

  public Scene(int size) {
    this(size, new Point(0, 0, 0));
  }

  public Scene(int size, Point origin) {
    this(size, size, size, origin);
  }

  public Scene(int width, int height, int depth, Point origin) {
    this.buffer = new float[width * height * depth];
    this.heatData = new HeatData(width, height, depth);
    this.origin = origin;
    this.width = width;
    this.height = height;
    this.depth = depth;
  }

  public float[] buffer() {
    return this.buffer;
  }

  public HeatData heatData() {
    return this.heatData;
  }

  public int width() {
    return this.width;
  }

  public int volume() {
    return this.width * this.height * this.depth;
  }

  public class HeatData {
    volatile float[] heatPoints;
    volatile float[] heatCoeffs;
    public HeatData(int width, int height, int depth) {
      this.heatPoints = new float[width * height * depth];
      this.heatCoeffs = new float[width * height * depth];
    }

    public float[] heatPoints() {
      return this.heatPoints;
    }

    public void setHeat(float heat, int x, int y, int z) {
      this.heatPoints[width * height * x + height * y + z] = heat;
    }

    public float[] heatCoeffs() {
      return this.heatCoeffs;
    }
  }
}
