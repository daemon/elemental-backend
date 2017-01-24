package net.rocketeer.elemental.compute.base.param;

import org.jocl.cl_mem;

public interface Readable {
  cl_mem memory();
  int size();
}
