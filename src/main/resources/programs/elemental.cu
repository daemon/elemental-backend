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
  int gid = blockIdx.x * blockDim.x + threadIdx.x;
  field[gid] += laplacian[gid] * alpha[gid] * dt;
}

// Simple trilinear interpolation
__global__ void advection_gpu(float *fieldU, float *fieldV, float *fieldW, float *resultU, float *resultV, float *resultW, int fieldLength, float dt) {
  int gid = blockIdx.x * blockDim.x + threadIdx.x;
  int volume = fieldLength * fieldLength * fieldLength;
  int area = fieldLength * fieldLength;
  if (gid >= volume)
    return;
  int u = gid / area;
  int v = (gid - u * area) / fieldLength;
  int w = (gid - u * area) % fieldLength;
  float u2 = u - dt * fieldU[gid];
  float v2 = v - dt * fieldV[gid];
  float w2 = w - dt * fieldW[gid];
  int c1 = (int) u2;
  int c2 = c1 + 1;
  int c3 = (int) v2;
  int c4 = c3 + 1;
  int c5 = (int) w2;
  int c6 = c5 + 1;
  float pctU = (u2 - c1);
  float pctV = (v2 - c3);
  float pctW = (w2 - c5);
  int i1 = c2 * area + c3 * fieldLength + c5;
  int i2 = c1 * area + c3 * fieldLength + c5;
  int i3 = c2 * area + c4 * fieldLength + c5;
  int i4 = c1 * area + c4 * fieldLength + c5;
  int i5 = c2 * area + c3 * fieldLength + c6;
  int i6 = c1 * area + c3 * fieldLength + c6;
  int i7 = c2 * area + c4 * fieldLength + c6;
  int i8 = c1 * area + c4 * fieldLength + c6;
  float uI1 = 0 ? c2 >= fieldLength || c3 < 0 || c5 < 0 : fieldU[i1];
  float uI2 = 0 ? c1 < 0 || c3 < 0 || c5 < 0 : fieldU[i2];
  float uI6 = 0 ? c1 < 0 || c3 < 0 || c6 >= fieldLength : fieldU[i6];
  float uI5 = 0 ? c2 >= fieldLength || c3 < 0 || c6 >= fieldLength : fieldU[i5];
  float uI4 = 0 ? c1 < 0 || c4 >= fieldLength || c5 < 0 : fieldU[i4];
  float uI3 = 0 ? c2 >= fieldLength || c4 >= fieldLength || c5 < 0 : fieldU[i3];
  float uI8 = 0 ? c1 < 0 || c4 >= fieldLength || c6 >= fieldLength : fieldU[i8];
  float uI7 = 0 ? c2 >= fieldLength || c4 >= fieldLength || c6 >= fieldLength : fieldU[i7];
  float top1, top2, top, bot1, bot2, bot;
  top1 = pctU * uI1 + (1 - pctU) * uI2;
  top2 = pctU * uI6 + (1 - pctU) * uI5;
  top = pctW * top2 + (1 - pctW) * top1;
  bot1 = pctU * uI4 + (1 - pctU) * uI3;
  bot2 = pctU * uI8 + (1 - pctU) * uI7;
  bot = pctW * bot2 + (1 - pctW) * bot1;
  float rU = pctV * bot + (1 - pctV) * top;
  float vI1 = 0 ? c2 >= fieldLength || c3 < 0 || c5 < 0 : fieldV[i1];
  float vI2 = 0 ? c1 < 0 || c3 < 0 || c5 < 0 : fieldV[i2];
  float vI6 = 0 ? c1 < 0 || c3 < 0 || c6 >= fieldLength : fieldV[i6];
  float vI5 = 0 ? c2 >= fieldLength || c3 < 0 || c6 >= fieldLength : fieldV[i5];
  float vI4 = 0 ? c1 < 0 || c4 >= fieldLength || c5 < 0 : fieldV[i4];
  float vI3 = 0 ? c2 >= fieldLength || c4 >= fieldLength || c5 < 0 : fieldV[i3];
  float vI8 = 0 ? c1 < 0 || c4 >= fieldLength || c6 >= fieldLength : fieldV[i8];
  float vI7 = 0 ? c2 >= fieldLength || c4 >= fieldLength || c6 >= fieldLength : fieldV[i7];
  top1 = pctU * vI1 + (1 - pctU) * vI2;
  top2 = pctU * vI6 + (1 - pctU) * vI5;
  top = pctW * top2 + (1 - pctW) * top1;
  bot1 = pctU * vI4 + (1 - pctU) * vI3;
  bot2 = pctU * vI8 + (1 - pctU) * vI7;
  bot = pctW * bot2 + (1 - pctW) * bot1;
  float rV = pctV * bot + (1 - pctV) * top;
  float wI1 = 0 ? c2 >= fieldLength || c3 < 0 || c5 < 0 : fieldW[i1];
  float wI2 = 0 ? c1 < 0 || c3 < 0 || c5 < 0 : fieldW[i2];
  float wI6 = 0 ? c1 < 0 || c3 < 0 || c6 >= fieldLength : fieldW[i6];
  float wI5 = 0 ? c2 >= fieldLength || c3 < 0 || c6 >= fieldLength : fieldW[i5];
  float wI4 = 0 ? c1 < 0 || c4 >= fieldLength || c5 < 0 : fieldW[i4];
  float wI3 = 0 ? c2 >= fieldLength || c4 >= fieldLength || c5 < 0 : fieldW[i3];
  float wI8 = 0 ? c1 < 0 || c4 >= fieldLength || c6 >= fieldLength : fieldW[i8];
  float wI7 = 0 ? c2 >= fieldLength || c4 >= fieldLength || c6 >= fieldLength : fieldW[i7];
  top1 = pctU * wI1 + (1 - pctU) * wI2;
  top2 = pctU * wI6 + (1 - pctU) * wI5;
  top = pctW * top2 + (1 - pctW) * top1;
  bot1 = pctU * wI4 + (1 - pctU) * wI3;
  bot2 = pctU * wI8 + (1 - pctU) * wI7;
  bot = pctW * bot2 + (1 - pctW) * bot1;
  float rW = pctV * bot + (1 - pctV) * top;
  resultU[gid] = rU;
  resultV[gid] = rV;
  resultW[gid] = rW;
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
  heat3d_gpu<<<nBlocks, 16>>>(dField, dResult, dAlpha, dt);
  cudaDeviceSynchronize();
  cudaMemcpy(field, dField, fieldSize, cudaMemcpyDeviceToHost);
  cudaFree(dFilter);
  cudaFree(dResult);
  cudaFree(dField);
  cudaFree(dAlpha);
}

extern "C"
__declspec(dllexport) void __cdecl
advection(float *fieldU, float *fieldV, float *fieldW, float dt, int fieldLength) {
  float *dFieldU, *dFieldV, *dFieldW, *dResultU, *dResultV, *dResultW;
  size_t fieldSize = fieldLength * fieldLength * fieldLength * sizeof(float);
  cudaMalloc((void **) &dFieldU, fieldSize);
  cudaMalloc((void **) &dFieldV, fieldSize);
  cudaMalloc((void **) &dFieldW, fieldSize);
  cudaMalloc((void **) &dResultU, fieldSize);
  cudaMalloc((void **) &dResultV, fieldSize);
  cudaMalloc((void **) &dResultW, fieldSize);
  cudaMemcpy(dFieldU, fieldU, fieldSize, cudaMemcpyHostToDevice);
  cudaMemcpy(dFieldV, fieldV, fieldSize, cudaMemcpyHostToDevice);
  cudaMemcpy(dFieldW, fieldW, fieldSize, cudaMemcpyHostToDevice);
  int nBlocks = (fieldLength * fieldLength * fieldLength) / 16 + 1;
  advection_gpu<<<nBlocks, 16>>>(dFieldU, dFieldV, dFieldW, dResultU, dResultV, dResultW, fieldLength, dt);
  cudaDeviceSynchronize();
  cudaMemcpy(fieldU, dResultU, fieldSize, cudaMemcpyDeviceToHost);
  cudaMemcpy(fieldV, dResultV, fieldSize, cudaMemcpyDeviceToHost);
  cudaMemcpy(fieldW, dResultW, fieldSize, cudaMemcpyDeviceToHost);
  cudaFree(dFieldU);
  cudaFree(dFieldV);
  cudaFree(dFieldW);
  cudaFree(dResultU);
  cudaFree(dResultV);
  cudaFree(dResultW);
}