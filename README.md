SRP batcher compatible Unlit Screen Space Decal Shader
======================
![screenshot](https://imgur.com/EluE9Dx.png)
![screenshot](https://imgur.com/EqsxFC9.png)
![screenshot](https://imgur.com/xIjdKvW.png)
![screenshot](https://imgur.com/P2tJqKs.png)
![screenshot](https://imgur.com/ZWIzkdR.png)
![screenshot](https://imgur.com/WE6AqYP.png)
![screenshot](https://imgur.com/c3fInsS.png)
![screenshot](https://imgur.com/lGE6qr3.png)
![screenshot](https://imgur.com/5LwT7Xe.png)

This screen space decal shader is SRP batcher compatible, you can put a lot decals in scene without hurting CPU performance too much.
And this shader removed all matrix mul() inside the fragment shader, you can put a lot decals in scene without hurting GPU performance too much, as long as they are thin and don't overlap(overdraw).

How to use this shader:
1. create a new material using this shader
2. assign any texture in material's Texture slot
3. create a new unity default cube GameObject in scene (in Hierarchy window, click +/3D Object/Cube)
4. apply the new material created to MeshRenderer component's material slot
5. edit the GameObject's transform so the local forward vector (blue Z arrow) is pointing to scene objects, and the cube is intersecting scene objects
6. you should see decal rendering correctly
7. (optional)make the cube as thin as possible to improve rendering performance

Requirement when you use this shader:
- Forward rendering
- _CameraDepthTexture already rendering by unity (tick DepthTexture in Universal Render Pipeline Asset)

[the camera depth texture]:
    https://docs.unity3d.com/Manual/SL-CameraDepthTexture.html

Reference
-------------------

Low Complexity, High Fidelity: The Rendering of INSIDE's optimized decal shader

https://youtu.be/RdN06E6Xn9E?t=2153

Screen Space Decals in Warhammer 40,000: Space Marine

https://www.slideshare.net/blindrenderer/screen-space-decals-in-warhammer-40000-space-marine-14699854?fbclid=IwAR2X6yYeWmDiz1Ho4labx3zA3GATpC7fi5qNkzjEj-MYTOBpXnkIsnA3T-A

System Requirements
-------------------

- Unity 2019.1 or later (due to shader_feature_local)

License
-------

Public domain
