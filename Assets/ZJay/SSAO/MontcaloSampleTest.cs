using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MontcaloSampleTest : MonoBehaviour
{
    private static float PI = 3.1415926f;
    float RadicalInverse( uint bits ){
        //reverse bit
        //高低16位换位置
        bits = (bits << 16) | (bits >> 16); 
        //A是5的按位取反
        bits = ((bits & 0x55555555) << 1) | ((bits & 0xAAAAAAAA) >> 1);
        //C是3的按位取反
        bits = ((bits & 0x33333333) << 2) | ((bits & 0xCCCCCCCC) >> 2);
        bits = ((bits & 0x0F0F0F0F) << 4) | ((bits & 0xF0F0F0F0) >> 4);
        bits = ((bits & 0x00FF00FF) << 8) | ((bits & 0xFF00FF00) >> 8);
        return (float)((bits) * 2.3283064365386963e-10);
    }

    Vector2 Hammersley(uint i,uint N)
    {
        return new Vector2((float)i / (float)N, RadicalInverse(i));
    }
    Vector3 hemisphereSample_uniform(float u, float v) {
        float phi = v * 2.0f * PI;
        float cosTheta = 1.0f - u;
        float sinTheta = Mathf.Sqrt(1.0f - cosTheta * cosTheta);
        return new Vector3(Mathf.Cos(phi) * sinTheta, Mathf.Sin(phi) * sinTheta, cosTheta);
    }
    
    Vector3 hemisphereSample_cos(float u, float v) {
        float phi = v * 2.0f * PI;
        float cosTheta = Mathf.Sqrt(1.0f - u);
        float sinTheta = Mathf.Sqrt(1.0f - cosTheta * cosTheta);
        return new Vector3(Mathf.Cos(phi) * sinTheta, Mathf.Sin(phi) * sinTheta, cosTheta);
    }
    
    Vector2 UniformSampleDisk( Vector2 E )
    {
        float Theta = 2 * PI * E.x;
        float Radius = Mathf.Sqrt( E.y );
        return Radius *new Vector2( Mathf.Cos( Theta ), Mathf.Sin( Theta ) );
    }
    Vector4 UniformSampleSphere(Vector2 E) {
        float Phi = 2 * PI * E.x;
        float CosTheta = 1 - 2 * E.y;
        float SinTheta = Mathf.Sqrt(1 - CosTheta * CosTheta);

        Vector3 L = new Vector3( SinTheta * Mathf.Cos(Phi), SinTheta * Mathf.Sin(Phi), CosTheta );
        float PDF = 1 / (4 * PI);

        return new Vector4(L.x,L.y,L.z, PDF);
    }
    Vector3 UniformSampleHemisphere(Vector2 E) {
        float Phi = 2 * PI * E.x;
        float CosTheta = E.y;
        float SinTheta = Mathf.Sqrt(1 - CosTheta * CosTheta);

        Vector3 L =new Vector3( SinTheta * Mathf.Cos(Phi), SinTheta * Mathf.Sin(Phi), CosTheta );
        // float PDF = 1.0 / (2 * UNITY_PI);

        return L;
    }
    // Start is called before the first frame update
    void Start()
    {
        
    }

    private List<Transform> sphereList = new List<Transform>();
    [Min(0)]
    public int SampleNum = 100;
    public float Scale = 0.1f;
    // Update is called once per frame
    void Update()
    {
        
        for(int i = 0;i < SampleNum;i++)
        {
            if(sphereList.Count<=i)
            {
                var sp = GameObject.CreatePrimitive(PrimitiveType.Sphere).transform;
                sp.name = $"sphere_{i}";
                sp.parent = transform;
                sp.localScale *= Scale;
                sphereList.Add(sp);
            }
            var s = sphereList[(int)i];
            Vector2 hammersleyVec = Hammersley((uint)i,(uint)SampleNum);
            //用vec3的结果直接在球面上实现均匀采样
            Vector3 hemisphereVec = hemisphereSample_cos(hammersleyVec.x ,hammersleyVec.y);
            hemisphereVec = UniformSampleDisk(hammersleyVec);

            //考虑3D球面
            s.position = hemisphereVec; 
        }

        for (int i = sphereList.Count-1; i >=SampleNum ; i--)
        {
            var sp = sphereList[i];
            sphereList.RemoveAt(i);
            GameObject.Destroy(sp.gameObject);
        }
    }
}
