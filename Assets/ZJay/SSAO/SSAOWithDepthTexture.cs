using UnityEngine;
using System.Collections;
using UnityEngine.Serialization;

public class SSAOWithDepthTexture : PostEffectsBase {

	public Shader ssaoShader;
	private Material ssaoMaterial = null;

	public Material material {  
		get {
			ssaoMaterial = CheckShaderAndCreateMaterial(ssaoShader, ssaoMaterial);
			return ssaoMaterial;
		}  
	}

	private Camera myCamera;
	public Camera camera {
		get {
			if (myCamera == null) {
				myCamera = GetComponent<Camera>();
			}
			return myCamera;
		}
	}

	[Range(0, 20)]
	public int SampleCount = 20;
	[Range(0, 20)]
	public int _Test = 20;
	[Range(-1, 1)]
	public float _Radius = 0.5f;
	
	[Range(-10, 10)]
	public float _FloatTest = 0.5f;
	
	private Matrix4x4 previousViewProjectionMatrix;
	
	void OnEnable() {
		camera.depthTextureMode |= DepthTextureMode.Depth;

		previousViewProjectionMatrix = camera.projectionMatrix * camera.worldToCameraMatrix;
	}
	
	void OnRenderImage (RenderTexture src, RenderTexture dest) {
		if (material != null) {
			material.SetFloat("_SampleCount", SampleCount);
			material.SetFloat("_Test", _Test);
			material.SetFloat("_Radius", _Radius);
			material.SetFloat("_FloatTest", _FloatTest);
			
			material.SetMatrix("_PreviousViewProjectionMatrix", previousViewProjectionMatrix);
			Matrix4x4 currentViewProjectionMatrix = camera.projectionMatrix * camera.worldToCameraMatrix;
			material.SetMatrix("_CurrentViewProjectionMatrix", previousViewProjectionMatrix);
			Matrix4x4 currentViewProjectionInverseMatrix = currentViewProjectionMatrix.inverse;
			material.SetMatrix("_CurrentViewProjectionInverseMatrix", currentViewProjectionInverseMatrix);
			previousViewProjectionMatrix = currentViewProjectionMatrix;

			Graphics.Blit (src, dest, material);
		} else {
			Graphics.Blit(src, dest);
		}
	}
}
