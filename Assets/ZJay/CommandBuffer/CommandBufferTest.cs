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
        rt = new RenderTexture(Screen.width/2, Screen.height/2,
            16, RenderTextureFormat.Depth);
        
        cmd.name = "jjjjjjjj depth Texture cmd buffer";
        
        cmd.Clear();
        cmd.SetRenderTarget(rt);
        cmd.ClearRenderTarget(true,true,Color.clear);
        
        var objs = GameObject.FindObjectsOfType(typeof(Renderer));
        foreach (var o in objs)
        {
           var render = o as Renderer;
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
