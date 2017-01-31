package net.rocketeer.elemental.geometry;

public class Scene {
  private final int width;
  private final int height;
  private final int depth;
  private final HeatData heatData;
  private final VelocityField velocityField;
  private float[] buffer;

  private final Vector<Integer> origin;

  public Scene(int size) {
    this(size, new Vector<>(0, 0, 0));
  }

  public Scene(int size, Vector<Integer> origin) {
    this(size, size, size, origin);
  }

  public Scene(int width, int height, int depth, Vector<Integer> origin) {
    this.buffer = new float[width * height * depth];
    this.heatData = new HeatData(width, height, depth);
    this.velocityField = new VelocityField(width, height, depth);
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

  public VelocityField velocityField() {
    return this.velocityField;
  }

  public int width() {
    return this.width;
  }

  public int volume() {
    return this.width * this.height * this.depth;
  }

  public class VelocityField {
    float[] fieldU;
    float[] fieldV;
    float[] fieldW;
    public VelocityField(int width, int height, int depth) {
      this.fieldU = new float[width * height * depth];
      this.fieldV = new float[width * height * depth];
      this.fieldW = new float[width * height * depth];
    }

    public float[] fieldU() {
      return this.fieldU;
    }

    public float[] fieldV() {
      return this.fieldV;
    }

    public float[] fieldW() {
      return this.fieldW;
    }

    public void setVelocity(int x, int y, int z, float u, float v, float w) {
      int index = width * height * x + height * y + z;
      this.fieldU[index] = u;
      this.fieldV[index] = v;
      this.fieldW[index] = w;
    }

    public Vector<Float> velocity(int x, int y, int z) {
      int index = width * height * x + height * y + z;
      return new Vector<>(this.fieldU[index], this.fieldV[index], this.fieldW[index]);
    }
  }

  public class HeatData {
    float[] heatPoints;
    float[] heatCoeffs;
    public HeatData(int width, int height, int depth) {
      this.heatPoints = new float[width * height * depth];
      this.heatCoeffs = new float[width * height * depth];
    }

    public float[] heatPoints() {
      return this.heatPoints;
    }

    public float heat(int x, int y, int z) {
      return this.heatPoints[width * height * x + height * y + z];
    }

    public void setHeat(int x, int y, int z, float heat) {
      this.heatPoints[width * height * x + height * y + z] = heat;
    }

    public float[] heatCoeffs() {
      return this.heatCoeffs;
    }
  }
}
