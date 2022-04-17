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

	[Range(0.0f, 2.0f)]
	public float size = 0.5f;

	private Matrix4x4 previousViewProjectionMatrix;
	
	void OnEnable() {
		camera.depthTextureMode |= DepthTextureMode.Depth;

		previousViewProjectionMatrix = camera.projectionMatrix * camera.worldToCameraMatrix;
	}
	
	void OnRenderImage (RenderTexture src, RenderTexture dest) {
		if (material != null) {
			material.SetFloat("_Size", size);

			material.SetMatrix("_PreviousViewProjectionMatrix", previousViewProjectionMatrix);
			Matrix4x4 currentViewProjectionMatrix = camera.projectionMatrix * camera.worldToCameraMatrix;
			Matrix4x4 currentViewProjectionInverseMatrix = currentViewProjectionMatrix.inverse;
			material.SetMatrix("_CurrentViewProjectionInverseMatrix", currentViewProjectionInverseMatrix);
			previousViewProjectionMatrix = currentViewProjectionMatrix;

			Graphics.Blit (src, dest, material);
		} else {
			Graphics.Blit(src, dest);
		}
	}
}
