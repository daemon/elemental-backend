package net.rocketeer.elemental.queue;

import net.rocketeer.elemental.compute.base.Engine;

public interface Task<T> {
  T visit(Engine engine);
}
