// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "SSAO/JayToWorldPosOrth" {
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
			float4x4 _CurrentViewProjectionInverseMatrix;
			
			struct v2f
			{
			    float4 vertex : SV_POSITION;
			    float4 screenPos : TEXCOORD0;
			    float3 viewVec : TEXCOORD1;
			};

			v2f vert(appdata_base v)
			{
			    v2f o;
			    o.vertex = UnityObjectToClipPos(v.vertex);

			    // Compute texture coordinate
			    o.screenPos = ComputeScreenPos(o.vertex);

			    // NDC position
			    float4 ndcPos = (o.screenPos / o.screenPos.w) * 2 - 1;

			    // View space vector from near plane pointing to far plane
			    o.viewVec = float3(unity_OrthoParams.xy * ndcPos.xy, 0);

			    return o;
			}
			 

			half4 frag(v2f i) : SV_Target
			{
			    // Camera parameters
			    float near = _ProjectionParams.y;
			    float far = _ProjectionParams.z;

			    // Sample the depth texture to get the linear depth
			    float rawDepth = UNITY_SAMPLE_DEPTH(tex2D(_CameraDepthTexture, i.screenPos));
			    float ortho = (far - near) * (1 - rawDepth) + near;
			    float depth = lerp(LinearEyeDepth(rawDepth), ortho, unity_OrthoParams.w) / far;

			    // Linear interpolate between near plane and far plane by depth value
			    float z = -lerp(near, far, depth);

			    // View space position
			    float3 viewPos = float3(i.viewVec.xy, z);

			    // Pixel world position
			    float3 worldPos = mul(UNITY_MATRIX_I_V, float4(viewPos, 1)).xyz;

			    return float4(worldPos, 1.0);
			}
			ENDCG
		}
		 
	} 
	FallBack off
}
