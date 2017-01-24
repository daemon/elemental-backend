package net.rocketeer.elemental.geometry;
// TODO: Get rid of voxel, store 3d array as 1d in scene directly for efficiency
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
    for (int i = 0; i < width; ++i)
      for (int j = 0; j < height; ++j)
        for (int k = 0; k < depth; ++k)
          this.setVoxel(i, j, k, new Voxel(Material.GENERIC, 0));
    this.origin = origin;
  }

  public Scene(Voxel[][][] voxels, Point origin) {
    this.voxels = voxels;
    this.origin = origin;
  }

  public Voxel[][][] voxels() {
    return this.voxels;
  }

  public void setVoxel(int x, int y, int z, Voxel voxel) {
    voxel.setPoint(x, y, z);
    this.voxels[x][y][z] = voxel;
  }

  public int length() {
    return this.voxels[0].length * this.voxels[0][0].length * this.voxels.length;
  }

  public Voxel voxelAt(int x, int y, int z) {
    return this.voxels[x][y][z];
  }
}
