package net.rocketeer.elemental;

import com.sun.jna.Library;
import com.sun.jna.Native;
import net.rocketeer.elemental.geometry.Scene;

public class ElementalServer implements Runnable {
  public interface Compute extends Library {
    void conv3d(float[] field, float[] filter, float[] result, int fieldLength, int filterLength);
  }

  public static void main(String[] args) {
    /*ElementalServer server = new ElementalServer();
    Scene scene = new Scene(64);
    server.queue(new LaplacianTask(scene));
    server.run();*/
    Scene[] scenes = new Scene[20];
    for (int i = 0; i < 20; ++i)
      scenes[i] = new Scene(64);
    Compute api = Native.loadLibrary("elemental", Compute.class);
    float[] laplacian = new float[]{0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, -6, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0};
    long a = System.currentTimeMillis();
    int n = 20;
    for (Scene scene : scenes)
      api.conv3d(scene.heatPoints(), laplacian, scene.buffer(), 64, 3);
    long b = System.currentTimeMillis();
    System.out.println("Total time: " + (b - a));
    System.out.println("Time per convolution: " + (b - a) / ((double) n));
  }

  @Override
  public void run() {

  }
}
