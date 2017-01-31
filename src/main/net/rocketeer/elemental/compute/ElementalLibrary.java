package net.rocketeer.elemental.compute;

import com.sun.jna.Library;
import com.sun.jna.Native;

public interface ElementalLibrary extends Library {
  void conv3d(float[] field, float[] filter, float[] result, int fieldLength, int filterLength);
  void heat3d(float[] field, float[] buffer, float[] alpha, float dt, int fieldLength);
  void advection(float[] fieldU, float[] fieldV, float[] fieldW, float dt, int fieldLength);

  static ElementalLibrary get() {
    return Native.loadLibrary("elemental", ElementalLibrary.class);
  }
}
