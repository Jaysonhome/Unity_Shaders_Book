// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Jay/Common/JayBumped Diffuse" {
	Properties {
		_Albedo ("_Albedo", Color) = (1, 1, 1, 1)
		_Li_indir ("Li_indir", Color) = (1, 1, 1, 1)
		_Color ("Color Tint", Color) = (1, 1, 1, 1)
		_MainTex ("Main Tex", 2D) = "white" {}
		_BumpMap ("Normal Map", 2D) = "bump" {}
		_SampleCount ("_SampleCount", Range(0.0, 256)) = 20
		_Base ("Base", Range(0.0, 10)) = 1
		_SampleRadius ("SampleRadius", Range(1, 5)) = 1
	}
	SubShader {
		Tags { "RenderType"="Opaque" "Queue"="Geometry"}

		Pass { 
			Tags { "LightMode"="ForwardBase" }
			
			CGPROGRAM
			
			#pragma multi_compile_fwdbase
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			// #include "../../Common/Shaders/Montcalo_Library.hlsl"
			#include "../../Common/Shaders/MontcaloCustom_Library.hlsl"
			#define sampler_SMShadowMap SamplerState_Point_Clamp
			
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
			
			float transferDepth(float z)
			{
			    float res = z;
			#if defined (UNITY_REVERSED_Z)
				res = 1 - res;       //(1, 0)-->(0, 1)
			#else 
				res = res*0.5 + 0.5; //(-1, 1)-->(0, 1)
			#endif
			    return res;
			}
			
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
				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				
				fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
				bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
				
				fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
				
				fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
			
			 	fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(bump, lightDir));
				
				UNITY_LIGHT_ATTENUATION(atten, i, worldPos);

				float count_visible = 0;
				for (uint idx = 0; idx < _SampleCount; ++idx)
				{
					float2 uv = Hammersley(idx,_SampleCount);
					float3 localPosHemisphere = hemisphereSample_uniform(uv.x,uv.y)*_SampleRadius; 
					
				};
				// 				o.screenPos = ComputeScreenPos(o.vertex);
				// float depth = SAMPLE_DEPTH_TEXTURE_PROJ(_CustomDepthTexture, UNITY_PROJ_COORD(i.screenPos));
				// float linear01Depth = Linear01Depth(depth); //转换成[0,1]内的线性变化深度值
				// float linearEyeDepth = LinearEyeDepth(depth); //转换到摄像机空间
				
				float4 rec_ndc = i.pos/i.pos.w ;
				float2 rec_uv = rec_ndc.xy*0.5 +0.5;
				// float depth = transferDepth(rec_ndc.z);
				//ComputeScreenPos 结果：[0~w]
				// float4 screenPos = ComputeScreenPos (i.pos);
				// float2 ndc = screenPos.xy/screenPos.w;
				// float4 color_depth = tex2D(_MainTex,_Base*screenPos.xy/(_ScreenParams.xy*0.5f));//_CustomDepthTexture //ndc*0.1f
				float depth = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv);
				float linearDepth = Linear01Depth(depth);
				float4	color_depth = tex2D(_CameraDepthTexture, i.uv);
 
				return fixed4(linearDepth,linearDepth,linearDepth ,1); 
			 
				
				/*
				for (uint idx = 0; idx < _SampleCount; ++idx)
				{
					half3 randomDirection = RandomSample[ ii ];
					float2 uv_offset = randomDirection.xy * scale;
					float sampleDepth;
					float3 sampleNormal;
					DecodeDepthNormal ( tex2D ( _CameraDepthNormalsTexture, i.uv + uv_offset ), sampleDepth, sampleNormal );
					sampleDepth *= _ProjectionParams.z; 

					float randomDepth = depth - ( randomDirection.z * _Radius );
					float diff =  saturate( randomDepth - sampleDepth );
				}
				// 3. 与Color Buffer混合.
				// 一般加入Gamma Correction使得阴影更有层次感, 即最终结果为:
				tex2D ( _MainTex, i.uv ) * pow ( ( 1 - occlusion ), 2.2 );*/

				
				float sm_depth = color_depth.r;
				// float sm_depth = _CustomDepthTexture.Sample(sampler_SMShadowMap,rec_uv).r;
				
				float v_average = 1;
				if(count_visible<_SampleCount*0.5f)
				{
					v_average = count_visible / (_SampleCount*0.5f);
				}
				fixed3 ssao = _Albedo*_Li_indir*v_average;
				return fixed4(ambient + diffuse * atten, 1.0);
			}
			ENDCG
		}
		
		Pass { 
			Tags { "LightMode"="ForwardAdd" }
			
			Blend One One
		
			CGPROGRAM
			
			#pragma multi_compile_fwdadd
			// Use the line below to add shadows for point and spot lights
//			#pragma multi_compile_fwdadd_fullshadows
			
			#pragma vertex vert
			#pragma fragment frag
			
			#include "Lighting.cginc"
			#include "AutoLight.cginc"
			
			fixed4 _Color;
			sampler2D _MainTex;
			float4 _MainTex_ST;
			sampler2D _BumpMap;
			float4 _BumpMap_ST;
			
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
			
			fixed4 frag(v2f i) : SV_Target {
				float3 worldPos = float3(i.TtoW0.w, i.TtoW1.w, i.TtoW2.w);
				fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos));
				fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos));
				
				fixed3 bump = UnpackNormal(tex2D(_BumpMap, i.uv.zw));
				bump = normalize(half3(dot(i.TtoW0.xyz, bump), dot(i.TtoW1.xyz, bump), dot(i.TtoW2.xyz, bump)));
				
				fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
				
			 	fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(bump, lightDir));
				
				UNITY_LIGHT_ATTENUATION(atten, i, worldPos);
				
				return fixed4(diffuse * atten, 1.0);
			}
			
			ENDCG
		}
	} 
	FallBack "Diffuse"
}
