using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteAlways]
public class Test1 : MonoBehaviour
{
    private Camera camera;
    
    private Matrix4x4 viewProjectionMatrix;

    public List<Transform> tfs = new List<Transform>();
    public GameObject goOri = null;
    private GameObject goTarget = null;
    void Start()
    {
        camera = GetComponent<Camera>();
        goTarget = GameObject.CreatePrimitive(PrimitiveType.Sphere);
        goOri = GameObject.CreatePrimitive(PrimitiveType.Cube);
        goOri.name = "ori";
        goTarget.name = "target";
    }

    // Update is called once per frame
    void Update()
    {
        
        viewProjectionMatrix =/* camera.projectionMatrix **/ camera.worldToCameraMatrix;

        goTarget.transform.position = viewProjectionMatrix *  goOri.transform.position;
    }
}
