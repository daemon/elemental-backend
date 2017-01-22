package net.rocketeer.elemental.geometry;

public class Scene {
  private final Voxel[][][] voxels;
  private final Point origin;

  public Scene(int size) {
    this(size, new Point(0, 0, 0));
  }

  public Scene(int size, Point origin) {
    this(size, size, size, origin);
  }

  public Scene(int width, int height, int depth, Point origin) {
    this.voxels = new Voxel[width][height][depth];
    this.origin = origin;
  }

  public Scene(Voxel[][][] voxels, Point origin) {
    this.voxels = voxels;
    this.origin = origin;
  }

  public Voxel voxelAt(int x, int y, int z) {
    return this.voxels[x][y][z];
  }
}
