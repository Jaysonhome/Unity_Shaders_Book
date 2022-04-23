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
			#include "../../Common/Shaders/Montcalo_Library.hlsl"
			// #include "../../Common/Shaders/MontcaloCustom_Library.hlsl"
			
			fixed4 _Color;
			fixed4 _Albedo;
			fixed4 _Li_indir;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;

			float _SampleCount;
			float _Test;
			float _FloatTest;
			
			float _Radius;
			float _Base;
			float _SampleRadius;
			sampler2D	_CameraDepthTexture;
			sampler2D	_CameraDepthNormalsTexture;
			sampler2D _CustomDepthTexture;
			float4 _CustomDepthTexture_ST;
			float4x4 _CurrentViewProjectionMatrix;
			float4x4 _CurrentViewProjectionInverseMatrix;
			
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
				return o;
			}
			float GetAverageForVis(float4 pos_world, float depth)
			{
				float count_vis = 0;
				for (int ii = 0; ii < _SampleCount; ++ii)
				{
					float2 e = Hammersley(ii,_SampleCount,3);
					float4 offsetPos = UniformSampleSphere(e);
					float4 samplePos = pos_world + offsetPos * _Radius;
					float4 pos_clip = mul(_CurrentViewProjectionMatrix,samplePos);
					float4 pos_clip_devided = pos_clip/pos_clip.w;
					float depth_inver = 0.5*pos_clip_devided.z+0.5;
					if(ii==_Test )//depth_inver<=depth
					{
						return depth_inver<(depth+0.00)?1:0;
						count_vis+=1;
					}
				}
				return 1;
				return (count_vis/(_SampleCount/**0.5*/));
			}
			
			fixed4 frag(v2f i) : SV_Target {
				float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv).r;
				// depth = Linear01Depth(depth);

				float4 pos_canonial = float4(2*i.uv.x-1, 2*(i.uv.y)-1, 2*depth-1, 1);
				float4 pos_world = mul(_CurrentViewProjectionInverseMatrix,pos_canonial);
				pos_world /= pos_world.w;

				float testDepth = 0;
				int count_vis=0;
				for (int ii = 0; ii < _SampleCount; ++ii)
				{
					float2 e = Hammersley(ii,_SampleCount,HaltonSequence(ii));
					float3 offset = UniformSampleSphere(e) *_Radius;
					float4 pos_world_sample = float4(pos_world.xyz+offset,1);
					float4 pos_clip_sample = mul(_CurrentViewProjectionMatrix, pos_world_sample);
					//[-1,1]
					float4 pos_clip_devided = pos_clip_sample/pos_clip_sample.w;
					float3 uvz_sample = 0.5*pos_clip_devided.xyz + 0.5;
					 
					//注意新的采样点要重新查询深度贴图的深度值。
					float sample_depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, uvz_sample.xy).r;
					// float4 samplePos = pos_world + offsetPos * _Radius;
					// float4 pos_clip = mul(_CurrentViewProjectionMatrix,pos_world);
					// float4 pos_clip_devided = pos_clip/pos_clip.w;
					// float depth_inver = 0.5*pos_clip_devided.z + 0.5;
					if((uvz_sample.z) > (sample_depth))//
					{
						count_vis+=1;
					}
					if(ii==11)
						testDepth =  uvz_sample.z;
				}
				
				float v_average = saturate(count_vis/(_SampleCount*0.5));
				// v_average = testDepth;
				// v_average = depth;
				float3 albedo = tex2D(_MainTex,i.uv); 
				float3 oc = float3(v_average, v_average, v_average);
				return fixed4(albedo*oc,  1); 
				// 
			}
			ENDCG
		}
		 
	} 
	FallBack off
}
