package net.rocketeer.elemental;

import net.rocketeer.elemental.compute.ElementalLibrary;

import java.util.Arrays;

public class ElementalServer implements Runnable {
  public static void main(String[] args) {
    int size = 3;
    float[] u = new float[size * size * size];
    float[] v = new float[size * size * size];
    float[] w = new float[size * size * size];
    ElementalLibrary lib = ElementalLibrary.get();
    Arrays.fill(u, 10);
    Arrays.fill(v, 5);
    Arrays.fill(w, 10);
    for (int i = 0; i < 5; ++i) {
      lib.advection(u, v, w, 0.1F, size);
      System.out.println(Arrays.toString(u));
    }
  }

  @Override
  public void run() {
  }
}
