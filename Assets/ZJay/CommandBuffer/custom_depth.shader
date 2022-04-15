Shader "Hidden/custom_depth"
{
    Properties
    {
//        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
//        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float4 posWorld : TEXCOORD0;
            };
 

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.posWorld = mul(unity_ObjectToWorld, v.vertex);
                return o;
            }
            //
            float4 frag (v2f i) : SV_Target
            {
                //todo 为什么game窗口黑色
                float4 col = float4(i.posWorld.zzz,1); 
                return col;
            }
            ENDCG
        }
    }
//    FallBack "Diffuse"
}
