// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "SSAO/JaySSAO" {
	Properties {
		_MainTex ("Base (RGB)", 2D) = "white" {}
//		_Albedo ("_Albedo", Color) = (1, 1, 1, 1)
//		_Li_indir ("Li_indir", Color) = (1, 1, 1, 1)
//		_Color ("Color Tint", Color) = (1, 1, 1, 1)
//		_MainTex ("Main Tex", 2D) = "white" {}
//		_BumpMap ("Normal Map", 2D) = "bump" {}
//		_SampleCount ("_SampleCount", Range(0.0, 256)) = 20
//		_Size("Size", Range(0.0, 10)) = 1
//		_SampleRadius ("SampleRadius", Range(1, 5)) = 1
	}
	SubShader {
//		Tags { "RenderType"="Opaque" "Queue"="Geometry"}

		Pass { 
//			Tags { "LightMode"="ForwardBase" }
			ZTest always Cull Off ZWrite Off
			CGPROGRAM
			
			#pragma multi_compile_fwdbase
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			// #include "../../Common/Shaders/Montcalo_Library.hlsl"
			#include "../../Common/Shaders/MontcaloCustom_Library.hlsl"
			
			fixed4 _Color;
			fixed4 _Albedo;
			fixed4 _Li_indir;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;

			fixed _SampleCount;
			fixed _Base;
			fixed _SampleRadius;
			sampler2D	_CameraDepthTexture;
			sampler2D	_CameraDepthNormalsTexture;
			sampler2D _CustomDepthTexture;
			float4 _CustomDepthTexture_ST;
			float4x4 _ShadowMapVP;
			
			struct a2v {
				float4 vertex : POSITION;
				float3 normal : NORMAL;
				float4 tangent : TANGENT;
				float4 texcoord : TEXCOORD0;
			};
			
			struct v2f {
				float4 pos : SV_POSITION;
				float4 uv : TEXCOORD0;
				float4 TtoW0 : TEXCOORD1;  
				float4 TtoW1 : TEXCOORD2;  
				float4 TtoW2 : TEXCOORD3;
				SHADOW_COORDS(4)
				// float4 sm_coord : TEXCOORD5;
			};
			 
			
			v2f vert(a2v v) {
				v2f o;
				o.pos = UnityObjectToClipPos(v.vertex);
				
				o.uv.xy = v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.uv.zw = v.texcoord.xy * _BumpMap_ST.xy + _BumpMap_ST.zw;
				
				float3 worldPos = mul(unity_ObjectToWorld, v.vertex).xyz;  
				fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);  
				fixed3 worldTangent = UnityObjectToWorldDir(v.tangent.xyz);  
				fixed3 worldBinormal = cross(worldNormal, worldTangent) * v.tangent.w; 
				
				o.TtoW0 = float4(worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x);
				o.TtoW1 = float4(worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y);
				o.TtoW2 = float4(worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z);  
				
				
				TRANSFER_SHADOW(o);
				// o.sm_coord = mul(_ShadowMapVP,mul(unity_ObjectToWorld,v.vertex));
				return o;
			}
			
			fixed4 frag(v2f i) : SV_Target { 
				float3 ssao = fixed3(0.2, 0, 0);
				float3 albedo = tex2D(_MainTex,i.uv); 
				return fixed4(albedo*ssao,  1);
			}
			ENDCG
		}
		 
	} 
	FallBack off
}
