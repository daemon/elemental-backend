package net.rocketeer.elemental.compute.base;
import static org.jocl.CL.*;

import net.rocketeer.elemental.compute.base.param.*;
import net.rocketeer.elemental.compute.base.param.Readable;
import org.jocl.*;

import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

public class Engine implements AutoCloseable {
  private final cl_device_id clDeviceId;
  private final cl_context_properties properties;
  private final cl_platform_id platform;
  final cl_context clContext;
  private final cl_command_queue clQueue;
  private final Lock executionLock = new ReentrantLock();
  private final ProgramRegistry programRegistry;

  public Engine() {
    this.platform = findFirstPlatform();
    this.programRegistry = new ProgramRegistry(this);
    this.clDeviceId = findFirstDevice(CL_DEVICE_TYPE_GPU, this.platform);
    this.properties = new cl_context_properties();
    this.properties.addProperty(CL_CONTEXT_PLATFORM, platform);
    this.clContext = clCreateContext(this.properties, 1, new cl_device_id[]{this.clDeviceId}, null, null, null);
    this.clQueue = clCreateCommandQueue(this.clContext, this.clDeviceId, 0, null);
  }

  public ProgramRegistry programRegistry() {
    return this.programRegistry;
  }

  public ResultPack execute(Kernel kernel, long[] globalWorkSize, long[] localWorkSize) {
    this.executionLock.lock();
    try {
      int rc = clEnqueueNDRangeKernel(this.clQueue, kernel.kernel, globalWorkSize.length, null, globalWorkSize, localWorkSize, 0, null, null);
      return new ResultPack(kernel, rc);
    } catch (Exception ignored) {
      return new ResultPack(kernel, CL_INVALID_VALUE);
    }
  }

  public cl_context clContext() {
    return this.clContext;
  }

  public static cl_device_id findFirstDevice(long deviceType, cl_platform_id platformId) {
    cl_device_id[] devices = new cl_device_id[1];
    clGetDeviceIDs(platformId, deviceType, 1, devices, null);
    return devices[0];
  }

  public static cl_platform_id findFirstPlatform() {
    cl_platform_id[] platforms = new cl_platform_id[1];
    clGetPlatformIDs(1, platforms, null);
    return platforms[0];
  }

  @Override
  public void close() throws Exception {
    clReleaseCommandQueue(this.clQueue);
    clReleaseContext(this.clContext);
  }

  public class ResultPack implements AutoCloseable {
    private final int returnCode;
    private final Kernel kernel;

    ResultPack(Kernel kernel, int returnCode) {
      this.kernel = kernel;
      this.returnCode = returnCode;
    }

    public int returnCode() {
      return this.returnCode;
    }

    public ResultPack readInto(int index, Pointer pointer) {
      Readable target = (net.rocketeer.elemental.compute.base.param.Readable) this.kernel.params().at(index);
      clEnqueueReadBuffer(clQueue, target.memory(), CL_TRUE, 0, target.size(), pointer, 0, null, null);
      return this;
    }

    public <OutType> OutType read(Extractor<OutType, ResultPack> extractor) {
      return extractor.extract(this);
    }

    public void finish() {
      executionLock.unlock();
    }

    @Override
    public void close() throws Exception {
      this.finish();
    }
  }
}
