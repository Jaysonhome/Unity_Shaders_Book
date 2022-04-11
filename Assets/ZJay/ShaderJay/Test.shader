// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Jay/Test"
{
    Properties{
        _MainTex("MainTex",2D)= "white"{}
        _CubeMap("CudeMap",Cube)= ""{}
        _Gloss("Gloss" , Range(0.0, 20.0) ) =5.0
        _Alpha("Alpha" , Range(0.0, 1.0) ) =0.5
    }
    SubShader
    {
		Tags { "RenderType"="Opaque" }
//        Tags { "Queue"="Transparent" }

//		Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout"}
		
//        Blend SrcAlpha OneMinusSrcAlpha
//        ZTest Always
        Pass
        {
			Tags { "LightMode"="ForwardBase" }
            CGPROGRAM
            //阴影0 - pragma
            #pragma multi_compile_fwdbase 
            // #pragma multi_compile_fwdadd
            
            #include "UnityCG.cginc" 
            #include "Lighting.cginc"
            #include "AutoLight.cginc"
            #pragma vertex vert
            #pragma fragment frag

            sampler2D  _MainTex;
            float4   _MainTex_ST;
            float  _Gloss;
            float  _Alpha;
            struct a2v
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
                float4 texcoord : TEXCOORD0;
            };
            struct v2f
            {
                float4 pos:SV_POSITION;
                float3 posWorld:TEXCOORD0; // 只能是TEXCOORD0
                float3 normal : NORMAL;
                float2 uv :TEXCOORD1 ; 
                SHADOW_COORDS(2)
                // UNITY_SHADOW_COORDS(2)
            };
            v2f  vert(a2v v){
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex );
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.posWorld = mul(unity_ObjectToWorld,v.vertex );
                o.uv = TRANSFORM_TEX(v.texcoord,_MainTex).xy;
                TRANSFER_SHADOW(o);
                // UNITY_TRANSFER_SHADOW(o,0);
                return o;
            }
            fixed4 frag(v2f i):SV_Target
            {
                // unity_LightColor0
                fixed3 dir_light = normalize( UnityWorldSpaceLightDir(i.posWorld));
                fixed3 dir_view = normalize(UnityWorldSpaceViewDir(i.posWorld));

                fixed3 tex_color = tex2D(_MainTex,i.uv);

                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz;

                // fixed dotln = dot(i.normal,dir_light);
                fixed dotln  = dot(i.normal,dir_light) *0.5+0.5;
                fixed3 diffuse =  _LightColor0.xyz * saturate( dotln) ;

                //shadow
                fixed shadow = SHADOW_ATTENUATION(i);
                // fixed shadow = UNITY_SHADOW_ATTENUATION(i,0);

                fixed3 halflv = normalize(dir_light+dir_view);
                fixed dotlv = dot(halflv,i.normal) ;
                fixed3 specular = _LightColor0.xyz * pow(saturate( dotlv) ,_Gloss) ;
                fixed3 albedo =  (ambient+diffuse + specular)*tex_color; //saturate(dot(dir_view ,i.normal) ) *
                // albedo = fixed4(shadow,shadow,shadow,1);
                return fixed4(albedo*shadow,_Alpha);
            }

            ENDCG
        }
    }
    FallBack "Diffuse"
}