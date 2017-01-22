package net.rocketeer.elemental.compute;
import static org.jocl.CL.*;
import org.jocl.*;

import java.util.Arrays;

public class Engine {
  public Engine() {

  }

  public static cl_device_id findFirstDevice(int deviceType) {
    cl_platform_id[] platforms = new cl_platform_id[1];
    clGetPlatformIDs(1, platforms, null);
    cl_platform_id platformId = platforms[0];
    cl_device_id[] devices = new cl_device_id[1];
    clGetDeviceIDs(platformId, deviceType, 1, devices, null);
    return devices[0];
  }
}
