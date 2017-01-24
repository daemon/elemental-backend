__kernel void conv3d(__global double *field, __global double *filter, __const int fieldLength, __const int filterLength) {
  int gid = get_global_id(0);
  field[gid] = field[gid] * filter[0] * filter[1] * filter[2];
}
