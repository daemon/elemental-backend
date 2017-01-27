package net.rocketeer.elemental;

import com.sun.jna.Library;
import com.sun.jna.Native;
import net.rocketeer.elemental.geometry.Scene;

import java.util.Arrays;

public class ElementalServer implements Runnable {
  public interface Compute extends Library {
    void conv3d(float[] field, float[] filter, float[] result, int fieldLength, int filterLength);
    void heat3d(float[] field, float[] buffer, float[] alpha, float dt, int fieldLength);
  }

  public static void main(String[] args) {
    /*ElementalServer server = new ElementalServer();
    Scene scene = new Scene(64);
    server.queue(new LaplacianTask(scene));
    server.run();*/
    int size = 100;
    Scene scene = new Scene(size);
    Compute api = Native.loadLibrary("elemental", Compute.class);
    long a = System.currentTimeMillis();
    int n = 30;
    for (int i = 0; i < n; ++i) {
      api.heat3d(scene.heatPoints(), scene.buffer(), scene.heatCoeffs(), 0.1F, size);
    }
    long b = System.currentTimeMillis();
    System.out.println("Total time: " + (b - a));
    System.out.println("Time per convolution: " + (b - a) / ((double) n));
    // System.out.println(Arrays.toString(scene.heatPoints()));
  }

  @Override
  public void run() {
  }
}
