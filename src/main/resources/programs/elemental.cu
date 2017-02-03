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

__global__ void sph_density_gpu(float *posX, float *posY, float *posZ, float *density, int nParticles) {
  int gid = blockIdx.x * blockDim.x + threadIdx.x;
  if (gid >= nParticles)
    return;
  float rho = 0;  
  float x = posX[gid];
  float y = posY[gid];
  float z = posZ[gid];
  float pi = 3.141592654f;
  for (int i = 0; i < nParticles; ++i) {
    float dX = posX[i] - x;
    float dY = posY[i] - y;
    float dZ = posZ[i] - z;
    float dist = dX * dX + dY * dY + dZ * dZ;
    if (dist <= 1)
      rho += (1 - (3.0 / 2) * dist * (1 - sqrtf(dist) / 2)) * (1 / (pi * 8));
    else if (dist <= 4)
      rho += powf(2 - sqrtf(dist), 3) * (1 / (4 * pi * 8));
  }
  density[gid] = rho;
}

__global__ void sph_accel_gpu(float *posX, float *posY, float *posZ, float *velX, float *velY, float *velZ, float *density, bool *wallBlocks, float dt, int nParticles, int fieldLength) {
  int gid = blockIdx.x * blockDim.x + threadIdx.x;
  if (gid >= nParticles)
    return;
  float3 a = make_float3(0, -9.81, 0);
  float x = posX[gid];
  float y = posY[gid];
  float z = posZ[gid];
  float pi = 3.141592654f;
  float rhoi = density[gid];
  float3 force = make_float3(0, 0, 0);
  for (int i = 0; i < nParticles; ++i) {
    if (i == gid)
      continue;
    float3 dX = make_float3(x - posX[i], y - posY[i], z - posZ[i]);
    float dist = dX.x * dX.x + dX.y * dX.y + dX.z * dX.z;
    if (dist > 4)
      continue;
    float rhoj = density[i];
    float qij = max(sqrtf(dist) / 2, 0.0005);
    float k1 = 1 / (pi * 16 * rhoj) * (1 - qij) * (70 * (rhoi + rhoj - 0.2) * (1 - qij) / qij);
    force.x += k1 * dX.x;
    force.y += k1 * dX.y;
    force.z += k1 * dX.z;
  }
  a.x = force.x / rhoi;
  a.y = force.y / rhoi - 9.81;
  a.z = force.z / rhoi;
  velX[gid] += a.x * dt;
  velY[gid] += a.y * dt;
  velZ[gid] += a.z * dt;
  int newX = (int) (posX[gid] + velX[gid] * dt);
  int newY = (int) (posY[gid] + velY[gid] * dt);
  int newZ = (int) (posZ[gid] + velZ[gid] * dt);
  if (newX >= fieldLength || newX < 0) {
    velX[gid] = -velX[gid];
    velX[gid] *= 0.15;
  }
  if (newY >= fieldLength || newY < 0) {
    velY[gid] = -velY[gid];
    velY[gid] *= 0.15;
  }
  if (newZ >= fieldLength || newZ < 0) {
    velZ[gid] = -velZ[gid];
    velZ[gid] *= 0.15;
  }
  if (wallBlocks[newX * fieldLength * fieldLength + newY * fieldLength + newZ]) {
    if (wallBlocks[newX * fieldLength * fieldLength + fieldLength * (int) (posY[gid]) + (int) (posZ[gid])]) {
      velX[gid] = -velX[gid];
      velX[gid] *= 0.15;
    }
    if (wallBlocks[(int) (posX[gid]) * fieldLength * fieldLength + fieldLength * newY + (int) (posZ[gid])]) {
      velY[gid] = -velY[gid];
      velY[gid] *= 0.15;
    }
    if (wallBlocks[(int) (posX[gid]) * fieldLength * fieldLength + fieldLength * (int) (posY[gid]) + newZ]) {
      velZ[gid] = -velZ[gid];
      velZ[gid] *= 0.15;
    }
  }
  posX[gid] += velX[gid] * dt;
  posY[gid] += velY[gid] * dt;
  posZ[gid] += velZ[gid] * dt;
}

extern "C"
__declspec(dllexport) void __cdecl
sph(float *posX, float *posY, float *posZ, float *velX, float *velY, float *velZ, bool *wallBlocks, float dt, int nParticles, int fieldLength) {
  float *dPosX,*dPosY, *dPosZ, *dVelX, *dVelY, *dVelZ, *dDensity;
  bool *dWallBlocks;
  int particlesSize = nParticles * sizeof(float);
  cudaMalloc((void **) &dPosX, particlesSize);
  cudaMalloc((void **) &dPosY, particlesSize);
  cudaMalloc((void **) &dPosZ, particlesSize);
  cudaMalloc((void **) &dVelX, particlesSize);
  cudaMalloc((void **) &dVelY, particlesSize);
  cudaMalloc((void **) &dVelZ, particlesSize);
  cudaMalloc((void **) &dDensity, particlesSize);
  cudaMalloc((void **) &dWallBlocks, fieldLength * fieldLength * fieldLength * sizeof(bool));
  cudaMemcpy(dPosX, posX, particlesSize, cudaMemcpyHostToDevice);
  cudaMemcpy(dPosY, posY, particlesSize, cudaMemcpyHostToDevice);
  cudaMemcpy(dPosZ, posZ, particlesSize, cudaMemcpyHostToDevice);
  cudaMemcpy(dVelX, velX, particlesSize, cudaMemcpyHostToDevice);
  cudaMemcpy(dVelY, velY, particlesSize, cudaMemcpyHostToDevice);
  cudaMemcpy(dVelZ, velZ, particlesSize, cudaMemcpyHostToDevice);
  cudaMemcpy(dWallBlocks, wallBlocks, fieldLength * fieldLength * fieldLength * sizeof(bool), cudaMemcpyHostToDevice);
  int nBlocks = nParticles / 16 + 1;
  sph_density_gpu<<<nBlocks, 16>>>(dPosX, dPosY, dPosZ, dDensity, nParticles);
  sph_accel_gpu<<<nBlocks, 16>>>(dPosX, dPosY, dPosZ, dVelX, dVelY, dVelZ, dDensity, dWallBlocks, dt, nParticles, fieldLength);
  cudaMemcpy(velX, dVelX, particlesSize, cudaMemcpyDeviceToHost);
  cudaMemcpy(velY, dVelY, particlesSize, cudaMemcpyDeviceToHost);
  cudaMemcpy(velZ, dVelZ, particlesSize, cudaMemcpyDeviceToHost);
  cudaMemcpy(posX, dPosX, particlesSize, cudaMemcpyDeviceToHost);
  cudaMemcpy(posY, dPosY, particlesSize, cudaMemcpyDeviceToHost);
  cudaMemcpy(posZ, dPosZ, particlesSize, cudaMemcpyDeviceToHost);
  cudaFree(dPosX);
  cudaFree(dPosY);
  cudaFree(dPosZ);
  cudaFree(dVelX);
  cudaFree(dVelY);
  cudaFree(dVelZ);
  cudaFree(dDensity);
  cudaFree(dWallBlocks);
}
