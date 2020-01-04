/*
https://github.com/ColinLeung-NiloCat/URP-UnlitScreenSpaceDecalShader/blob/master/README.md

Unity URP UnlitScreenSpaceDecalShader(SRP batcher compatible)
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
- Perspective camera
- _CameraDepthTexture already rendering by unity (tick DepthTexture in Universal Render Pipeline Asset)

[the camera depth texture]:
	https://docs.unity3d.com/Manual/SL-CameraDepthTexture.html

This screen space decal shader is SRP batcher compatible, so you can put lots of decals in scene without hurting CPU performance too much.
Also this shader removed all matrix mul() inside the fragment shader, so you can put lots of decals in scene without hurting GPU performance too much, as long as they are thin, small and don't overlap(overdraw).

Reference
-------------------

Low Complexity, High Fidelity: The Rendering of INSIDE's optimized decal shader

https://youtu.be/RdN06E6Xn9E?t=2153

Screen Space Decals in Warhammer 40,000: Space Marine

https://www.slideshare.net/blindrenderer/screen-space-decals-in-warhammer-40000-space-marine-14699854?fbclid=IwAR2X6yYeWmDiz1Ho4labx3zA3GATpC7fi5qNkzjEj-MYTOBpXnkIsnA3T-A

System Requirements
-------------------

- Unity 2019.1 or later (due to shader_feature_local)
- #pragma target 3.0 (due to ddx() & ddy())

License
-------

Public domain
*/

Shader "Unlit/URPScreenSpaceDecal(SRPBatcherCompatible)"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		[HDR]_Color ("_Color", color) = (1,1,1,1)

		[Header(Blending option)]
		//https://docs.unity3d.com/ScriptReference/Rendering.BlendMode.html
		[Enum(UnityEngine.Rendering.BlendMode)]_SrcBlend("_SrcBlend", Float) = 5 //default = SrcAlpha
		[Enum(UnityEngine.Rendering.BlendMode)]_DstBlend("_DstBlend", Float) = 10 //default = OneMinusSrcAlpha

		[Header(Stencil masking)]
		//https://docs.unity3d.com/ScriptReference/Rendering.CompareFunction.html
		_StencilRef("_StencilRef", Float) = 0
		[Enum(UnityEngine.Rendering.CompareFunction)]_StencilComp("_StencilComp (Set to NotEqual if want to mask by specific _StencilRef value, else set to Disable)", Float) = 0 //default = disable

		[Header(ZTest)]
		//https://docs.unity3d.com/ScriptReference/Rendering.CompareFunction.html
		//default = disable = make sure decal render correctly even if camera go inside decal cube, although this default value will prevent EarlyZ
		[Enum(UnityEngine.Rendering.CompareFunction)]_ZTest("_ZTest (optimization: Set to LessEqual if camera never go inside cube volume, else set to Disable)", Float) = 0 

		[Header(Cull)]
		//https://docs.unity3d.com/ScriptReference/Rendering.CullMode.html
		//default = Cull front = make sure decal render correctly even if camera go inside decal cube
		[Enum(UnityEngine.Rendering.CullMode)]_Cull("_Cull (optimization: Set to Back if camera never go inside cube volume, else set to Front)", Float) = 1

		[Header(Alpha remap)]
		_AlphaRemap("_AlphaRemap(first mul x, then add y)(zw unused)", vector) = (1,0,0,0)
		[Toggle]_MulAlphaToRGB("_MulAlphaToRGB", Float) = 0

		[Header(Compare projection dir with scene normal and Discard if needed )]
		[Toggle(_ProjectionAngleDiscardEnable)] _ProjectionAngleDiscardEnable("_ProjectionAngleDiscardEnable", float) = 1
		_ProjectionAngleDiscardThreshold("_ProjectionAngleDiscardThreshold", range(-1,1)) = 0

		[Header(Unity Fog)]
		[Toggle(_UnityFogEnable)] _UnityFogEnable("_UnityFogEnable", float) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Overlay" "Queue"="AlphaTest+1" }

        Pass
        {
			Stencil
			{
				Ref [_StencilRef]
				Comp [_StencilComp]
			}
			
			Cull [_Cull]
			ZTest [_ZTest]

			ZWrite off
			Blend[_SrcBlend][_DstBlend]

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
			// make fog work
			#pragma multi_compile_fog

			//due to ddx() & ddy()
			#pragma target 3.0

			#pragma shader_feature_local _ProjectionAngleDiscardEnable
			#pragma shader_feature_local _UnityFogEnable

			#include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
#if _UnityFogEnable
				UNITY_FOG_COORDS(1)
#endif
				float4 screenUV : TEXCOORD0;
				float4 viewRayOS : TEXCOORD2;
				float3 cameraPosOS : TEXCOORD3;
            };

			CBUFFER_START(UnityPerMaterial)
				sampler2D _MainTex;
				float4 _MainTex_ST;
				float _ProjectionAngleDiscardThreshold;
				half4 _Color;
				half2 _AlphaRemap;
				half _MulAlphaToRGB;
			CBUFFER_END

			sampler2D _CameraDepthTexture;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
#if _UnityFogEnable
				UNITY_TRANSFER_FOG(o, o.vertex);
#endif
				//depth texture's screenUV
				o.screenUV = ComputeScreenPos(o.vertex);

				//get "camera to vertex" ray in View space
				float3 viewRay = UnityObjectToViewPos(v.vertex);

				//***WARNING***: viewRay z division must do in the fragment shader! (due to rasteriazation varying interpolation perspective correction)
				//We skip the viewRay z division in vertex shader for now, and pass the division value to varying o.viewRayOS.w first, we will do the division later in fragment shader
				//viewRay /= viewRay.z; //skip in vertex shader!
				o.viewRayOS.w = viewRay.z;

				viewRay *= -1; //unity's camera space is right hand coord(negativeZ pointing into screen), we want positive z ray in fragment shader, so negate it

				//it is ok to write expensive code in decal's vertex shader, it is just a unity cube(4*6 vertices) per decal only.
				float4x4 ViewToObjectMatrix = mul(unity_WorldToObject, UNITY_MATRIX_I_V);

				//transform everything to object space(decal space) in vertex shader first, so we can skip all matrix mul() in fragment shader
				o.viewRayOS.xyz = mul((float3x3)ViewToObjectMatrix, viewRay);
				o.cameraPosOS = mul(ViewToObjectMatrix, float4(0,0,0,1)).xyz;

                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
				//***WARNING***: now do viewRay z division that we skipped in vertex shader.
				i.viewRayOS /= i.viewRayOS.w;

				float sceneCameraSpaceDepth = LinearEyeDepth(tex2Dproj(_CameraDepthTexture, i.screenUV));

				float3 decalSpaceScenePos = i.cameraPosOS + i.viewRayOS * sceneCameraSpaceDepth;//= rayStartPos + rayDir * rayLength, all in ObjectSpace(OS)

				//convert unity cube's [-0.5,0.5] vertex pos range to [0,1] uv. Only works if you use unity cube in mesh filter!
				float2 decalSpaceUV = decalSpaceScenePos.xy + 0.5;

				//discard logic
				//===================================================
				// discard "out of UV range" pixels
				float mask = (abs(decalSpaceScenePos.x) < 0.5) * (abs(decalSpaceScenePos.y) < 0.5) *(abs(decalSpaceScenePos.z) < 0.5);

#if _ProjectionAngleDiscardEnable
				// discard "scene normal not facing projector" pixels
				float3 normalized_ddx = normalize(ddx(decalSpaceScenePos));
				float3 normalized_ddy = normalize(ddy(decalSpaceScenePos));
				float3 decalSpaceHardNormal = cross(normalized_ddx, normalized_ddy);
				mask *= decalSpaceHardNormal.z > _ProjectionAngleDiscardThreshold;
#endif
				//do discard
				clip(mask - 0.5);//if ZWrite is off, clip() is fast enough in mobile, because it wont affect DepthBuffer, so no pipeline stall.
				//===================================================

                // sample the decal texture
                half4 col = tex2D(_MainTex, decalSpaceUV.xy) * _Color;
				col.a = col.a * _AlphaRemap.x + _AlphaRemap.y;//alpha remap MAD
				col.rgb *= lerp(1, col.a, _MulAlphaToRGB);

#if _UnityFogEnable
				// apply fog
				UNITY_APPLY_FOG(i.fogCoord, col);
#endif

                return col;
            }
            ENDCG
        }
    }
}
