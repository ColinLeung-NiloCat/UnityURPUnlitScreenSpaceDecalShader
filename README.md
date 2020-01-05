Unity URP Unlit ScreenSpaceDecal Shader(SRP batcher compatible)
======================
Before adding decal
![screenshot](https://i.imgur.com/dyFj5h1.png)

After adding decal(multiply blend mode)
![screenshot](https://i.imgur.com/ptjzwPK.png)
![screenshot](https://i.imgur.com/m4F0N5t.png)

Before adding decal
![screenshot](https://imgur.com/ZWIzkdR.png)
After adding decal
![screenshot](https://imgur.com/EqsxFC9.png)
![screenshot](https://imgur.com/EluE9Dx.png)
![screenshot](https://imgur.com/P2tJqKs.png)
![screenshot](https://imgur.com/xIjdKvW.png)

![screenshot](https://imgur.com/WE6AqYP.png)
![screenshot](https://imgur.com/c3fInsS.png)
![screenshot](https://imgur.com/lGE6qr3.png)
![screenshot](https://imgur.com/5LwT7Xe.png)

How to use this shader:
-------------------
1. create a new material using this shader
2. assign any texture to material's Texture slot
3. create a new unity default cube GameObject in scene (in Hierarchy window, click +/3D Object/Cube)
4. apply material to MeshRenderer component's material slot
5. edit the GameObject's transform so the local forward vector (blue Z arrow) is pointing to scene objects, and the cube is intersecting scene objects
6. you should now see decal rendering correctly
7. (optional)make the cube as thin as possible to improve rendering performance

Requirement when using this shader:
-------------------
- Forward rendering
- Perspective camera
- _CameraDepthTexture is already rendering by unity (toggle on DepthTexture in your Universal Render Pipeline Asset)

[the camera depth texture]:
    https://docs.unity3d.com/Manual/SL-CameraDepthTexture.html

Performance
-------------------
This screen space decal shader is SRP batcher compatible, so you can put lots of decals in scene without hurting CPU performance too much.
Also this shader removed all matrix mul() inside the fragment shader, so you can put lots of decals in scene without hurting GPU performance too much, as long as they are thin, small and don't overlap(overdraw).

System Requirements
-------------------

- Unity 2019.1 or later (due to shader_feature_local)
- #pragma target 3.0 (due to ddx() & ddy())

Reference
-------------------

Low Complexity, High Fidelity: The Rendering of INSIDE's optimized decal shader

https://youtu.be/RdN06E6Xn9E?t=2153

Screen Space Decals in Warhammer 40,000: Space Marine

https://www.slideshare.net/blindrenderer/screen-space-decals-in-warhammer-40000-space-marine-14699854?fbclid=IwAR2X6yYeWmDiz1Ho4labx3zA3GATpC7fi5qNkzjEj-MYTOBpXnkIsnA3T-A


