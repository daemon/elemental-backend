package net.rocketeer.elemental.geometry;

import java.util.Arrays;

// TODO: Get rid of voxel, store 3d array as 1d in scene directly for efficiency
public class Scene {
  private final int width;
  private final int height;
  private final int depth;
  private double[] heatPoints;
  private double[] buffer;

  private final Point origin;

  public Scene(int size) {
    this(size, new Point(0, 0, 0));
  }

  public Scene(int size, Point origin) {
    this(size, size, size, origin);
  }

  public Scene(int width, int height, int depth, Point origin) {
    this.heatPoints = new double[width * height * depth];
    Arrays.fill(this.heatPoints, 1);
    this.buffer = new double[width * height * depth];
    this.origin = origin;
    this.width = width;
    this.height = height;
    this.depth = depth;
  }

  public double[] buffer() {
    return this.buffer;
  }

  public void setHeat(int x, int y, int z, double heat) {
    this.heatPoints[this.width * this.height * x + this.height * y + z] = heat;
  }

  public double[] heatPoints() {
    return this.heatPoints;
  }

  public int length() {
    return this.width * this.height * this.depth;
  }
}
