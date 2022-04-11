Shader "Jay/JayDiffSpec"
{
    Properties
    {
        _MainTex ("MainTex", 2D) = "white" { }
    }

    SubShader
    {

        Pass
        {

            CGPROGRAM
            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            #pragma vertex vert
            #pragma fragment frag

            sampler2D _MainTex;
            float4 _MainTex_ST;
            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 posClip : SV_POSITION;
                float3 normal : TEXCOORD0;
                float2 uv : TEXCOORD1;
                float4 posWorld : TEXCOORD2;

            };

            v2f vert(a2v v)
            {
                v2f o;
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv = TRANSFORM_TEX(v.vertex, _MainTex);
                o.posClip = UnityObjectToClipPos(v.vertex);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {

                return fixed4(1, 1, 1, 1);
            }

            ENDCG
        }

    }

    FallBack "Diffuse"
}