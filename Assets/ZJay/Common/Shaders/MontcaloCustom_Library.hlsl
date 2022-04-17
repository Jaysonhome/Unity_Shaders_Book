#ifndef _MontcaloCustom_Library_
#define _MontcaloCustom_Library_

#define PI			3.14159265359f

float RadicalInverse( uint bits ){
    //reverse bit
    //高低16位换位置
    bits = (bits << 16u) | (bits >> 16u); 
    //A是5的按位取反
    bits = ((bits & 0x55555555) << 1u) | ((bits & 0xAAAAAAAA) >> 1u);
    //C是3的按位取反
    bits = ((bits & 0x33333333) << 2u) | ((bits & 0xCCCCCCCC) >> 2u);
    bits = ((bits & 0x0F0F0F0F) << 4u) | ((bits & 0xF0F0F0F0) >> 4u);
    bits = ((bits & 0x00FF00FF) << 8u) | ((bits & 0xFF00FF00) >> 8u);
    return  float(bits) * 2.3283064365386963e-10;
}

float2 Hammersley(uint i,uint N){
    return float2(float(i) / float(N), RadicalInverse(i));
}
float3 hemisphereSample_uniform(float u, float v) {
    float phi = v * 2.0 * PI;
    float cosTheta = 1.0 - u;
    float sinTheta = sqrt(1.0 - cosTheta * cosTheta);
    return float3(cos(phi) * sinTheta, sin(phi) * sinTheta, cosTheta);
}
    
float3 hemisphereSample_cos(float u, float v) {
    float phi = v * 2.0 * PI;
    float cosTheta = sqrt(1.0 - u);
    float sinTheta = sqrt(1.0 - cosTheta * cosTheta);
    return float3(cos(phi) * sinTheta, sin(phi) * sinTheta, cosTheta);
}

#endif