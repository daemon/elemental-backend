#include <iostream>

__global__ void conv3d_gpu(float *field, float *filter, float *result, int fieldLength, int filterLength) {
  int gid = blockIdx.x;
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

extern "C"
__declspec(dllexport) void __cdecl
conv3d(float *field, float *filter, float *result, int fieldLength, int filterLength) {
  float *dField, *dFilter, *dResult;
  size_t fieldSize = sizeof(float) * fieldLength * fieldLength * fieldLength;
  size_t filterSize = sizeof(float) * filterLength * filterLength * filterLength;
  cudaMalloc((void **) &dField, fieldSize);
  cudaMalloc((void **) &dFilter, filterSize);
  cudaMalloc((void **) &dResult, fieldSize);
  cudaMemcpy(dField, field, fieldSize, cudaMemcpyHostToDevice);
  cudaMemcpy(dFilter, filter, filterSize, cudaMemcpyHostToDevice);
  conv3d_gpu<<<fieldLength * fieldLength * fieldLength, 1>>>(dField, dFilter, dResult, fieldLength, filterLength);
  cudaMemcpy(result, dResult, fieldSize, cudaMemcpyDeviceToHost);
  cudaFree(dFilter);
  cudaFree(dResult);
  cudaFree(dField);
}