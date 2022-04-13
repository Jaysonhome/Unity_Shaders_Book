using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;

public class ShaderManager : MonoBehaviour
{
    public struct GlobalShaderIds
    {
        public static readonly int CustomDepthTexture = Shader.PropertyToID("_CustomDepthTexture");
    }
}
