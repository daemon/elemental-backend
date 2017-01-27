package net.rocketeer.elemental.geometry;

import java.util.Arrays;

// TODO: Get rid of voxel, store 3d array as 1d in scene directly for efficiency
public class Scene {
  private final int width;
  private final int height;
  private final int depth;
  private final float[] heatCoeffs;
  private float[] heatPoints;
  private float[] buffer;

  private final Point origin;

  public Scene(int size) {
    this(size, new Point(0, 0, 0));
  }

  public Scene(int size, Point origin) {
    this(size, size, size, origin);
  }

  public Scene(int width, int height, int depth, Point origin) {
    this.heatPoints = new float[width * height * depth];
    this.heatPoints[3] = 100;
    this.buffer = new float[width * height * depth];
    this.heatCoeffs = new float[width * height * depth];
    Arrays.fill(this.heatCoeffs, 0.1F);
    this.origin = origin;
    this.width = width;
    this.height = height;
    this.depth = depth;
  }

  public float[] heatCoeffs() {
    return this.heatCoeffs;
  }

  public float[] buffer() {
    return this.buffer;
  }

  public void setHeat(int x, int y, int z, float heat) {
    this.heatPoints[this.width * this.height * x + this.height * y + z] = heat;
  }

  public float[] heatPoints() {
    return this.heatPoints;
  }

  public int length() {
    return this.width * this.height * this.depth;
  }
}
