package net.rocketeer.elemental.compute.base;

@FunctionalInterface
public interface Extractor<Out, In> {
  Out extract(In o);
}
