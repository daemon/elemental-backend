package net.rocketeer.elemental.geometry;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

public class Scene {
  private final int width;
  private final int height;
  private final int depth;
  private final HeatData heatData;
  private final FluidField fluidField;
  private float[] buffer;
  private boolean[] wallBlocks;

  private final Vector<Integer> origin;

  public Scene(int size) {
    this(size, new Vector<>(0, 0, 0));
  }

  public Scene(int size, Vector<Integer> origin) {
    this(size, size, size, origin);
  }

  public Scene(int width, int height, int depth, Vector<Integer> origin) {
    this.buffer = new float[width * height * depth];
    this.wallBlocks = new boolean[width * height * depth];
    this.heatData = new HeatData(width, height, depth);
    this.fluidField = new FluidField();
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

  public FluidField fluidField() {
    return this.fluidField;
  }

  public int width() {
    return this.width;
  }

  public int volume() {
    return this.width * this.height * this.depth;
  }

  public class FluidField {
    public float[] velocitiesX = new float[0];
    public float[] velocitiesY = new float[0];
    public float[] velocitiesZ = new float[0];
    public float[] positionsX = new float[0];
    public float[] positionsY = new float[0];
    public float[] positionsZ = new float[0];
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
