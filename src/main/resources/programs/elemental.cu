#include <iostream>

// Only works with 3x3x3 filters for now
__global__ void conv3d_gpu(float *field, float *filter, float *result, int fieldLength, int filterLength) {
  int gid = blockDim.x * blockIdx.x + threadIdx.x;
  int fieldVolume = fieldLength * fieldLength * fieldLength;
  int fieldArea = fieldLength * fieldLength;
  if (gid >= fieldVolume)
    return;
  int base = -fieldArea - fieldLength - 1;
  int fieldIndex = 0;
  double answer = 0.0;
  for (int i = 0; i < filterLength; ++i) {
    for (int j = 0; j < filterLength; ++j) {
      int boundary = (gid + base + 1) / fieldLength;
      for (int k = 0; k < filterLength; ++k) {
        fieldIndex = gid + base + k;
        if (fieldIndex / fieldLength != boundary)
          continue;
        if (fieldIndex < 0 || fieldIndex >= fieldVolume)
          continue;
        answer += filter[filterLength * filterLength * i + filterLength * j + k] * field[fieldIndex];
      }
      base += fieldLength;
    }
    base -= filterLength * fieldLength;
    base += fieldArea;
  }
  result[gid] = answer;
}

__global__ void heat3d_gpu(float *field, float *laplacian, float *alpha, float dt) {
  int gid = blockIdx.x;
  field[gid] += laplacian[gid] * alpha[gid] * dt;
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
  int nBlocks = (fieldLength * fieldLength * fieldLength) / 16 + 1;
  conv3d_gpu<<<nBlocks, 16>>>(dField, dFilter, dResult, fieldLength, filterLength);
  cudaDeviceSynchronize();
  cudaMemcpy(result, dResult, fieldSize, cudaMemcpyDeviceToHost);
  cudaFree(dFilter);
  cudaFree(dResult);
  cudaFree(dField);
}

extern "C"
__declspec(dllexport) void __cdecl
heat3d(float *field, float *buffer, float *alpha, float dt, int fieldLength) {
  float *dField, *dFilter, *dResult, *dAlpha;
  float filter[27] = {0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0, 1, -6, 1, 0, 1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0};
  size_t fieldSize = sizeof(float) * fieldLength * fieldLength * fieldLength;
  size_t filterSize = sizeof(float) * 27;
  cudaMalloc((void **) &dField, fieldSize);
  cudaMalloc((void **) &dFilter, filterSize);
  cudaMalloc((void **) &dResult, fieldSize);
  cudaMemcpy(dField, field, fieldSize, cudaMemcpyHostToDevice);
  cudaMemcpy(dFilter, filter, filterSize, cudaMemcpyHostToDevice);
  int nBlocks = (fieldLength * fieldLength * fieldLength) / 16 + 1;
  conv3d_gpu<<<nBlocks, 16>>>(dField, dFilter, dResult, fieldLength, 3);
  cudaMalloc((void **) &dAlpha, fieldSize);
  cudaMemcpy(dAlpha, alpha, fieldSize, cudaMemcpyHostToDevice);
  cudaDeviceSynchronize();
  heat3d_gpu<<<fieldLength * fieldLength * fieldLength, 1>>>(dField, dResult, dAlpha, dt);
  cudaDeviceSynchronize();
  cudaMemcpy(field, dField, fieldSize, cudaMemcpyDeviceToHost);
  cudaFree(dFilter);
  cudaFree(dResult);
  cudaFree(dField);
  cudaFree(dAlpha);
}