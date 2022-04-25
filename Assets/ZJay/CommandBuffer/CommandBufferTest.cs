using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using UnityEditor;
using UnityEditor.SceneManagement;
using UnityEngine;
using UnityEngine.Experimental.Rendering;
using UnityEngine.Rendering;
using Debug = UnityEngine.Debug;

public class CommandBufferTest : MonoBehaviour
{
    private CommandBuffer cmd;
    private Material cmdMaterial;
    private Shader m_shader;
    public RenderTexture rt;

    public void Start()
    {
        m_shader = Shader.Find("Hidden/custom_depth");
        CreateCommandBuffer();
    }

    public void CreateCommandBuffer()
    {
        cmd = new CommandBuffer();
        cmdMaterial = new Material(m_shader);
        // if(rt==null)
        rt = new RenderTexture(Screen.width, Screen.height,
            16, RenderTextureFormat.Depth);
        
        cmd.name = "jjjjjjjj depth Texture cmd buffer";
        
        cmd.Clear();
        cmd.SetRenderTarget(rt);
        cmd.ClearRenderTarget(true,true,Color.clear);
        
        var gos = GameObject.FindObjectsOfType(typeof(GameObject));
        foreach (var _go in gos)
        {
           var go = _go as GameObject;
           var render = go.GetComponent<Renderer>();
           if(render==null)
               continue;
            cmd.DrawRenderer(render,cmdMaterial);//todo
        }
        
        Camera.main.AddCommandBuffer(CameraEvent.BeforeForwardOpaque,cmd);
        
        // cmd.Blit(BuiltinRenderTextureType.CurrentActive,
        //     ShaderManager.GlobalShaderIds.CustomDepthTexture);
        Shader.SetGlobalTexture(ShaderManager.GlobalShaderIds.CustomDepthTexture,rt);
    }

    public void RemoveCommandBuffer()
    {
        Camera.main.RemoveCommandBuffer(CameraEvent.BeforeForwardOpaque,cmd);
    }
    
    public void ReleaseTemporaryRT()
    {
        
    }
}
