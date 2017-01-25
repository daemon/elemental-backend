__kernel void conv3d(__global double *field, __global double *filter, __global double *result, __const int fieldLength, __const int filterLength) {
  int gid = get_global_id(0);
  int base = -fieldLength * fieldLength - fieldLength - 1;
  int fieldIndex = 0;
  double answer = 0.0;
  for (int i = 0; i < filterLength; ++i) {
    for (int j = 0; j < filterLength; ++j) {
      int boundary = (gid + base + 1) / fieldLength;
      for (int k = 0; k < filterLength; ++k) {
        fieldIndex = gid + base + k;
        if (fieldIndex / fieldLength != boundary)
          continue;
        if (fieldIndex < 0 || fieldIndex >= fieldLength * fieldLength * fieldLength)
          continue;
        double fieldValue = field[fieldIndex];
        answer += filter[filterLength * filterLength * i + filterLength * j + k] * fieldValue;
      }
      base += fieldLength;
    }
    base -= filterLength * fieldLength;
    base += fieldLength * fieldLength;
  }
  result[gid] = answer;
}
