Shader "Unlit/FunkyLightingShader"
{
	Properties
	{
		_ObjectColor("Color", Color) = (1.0,1.0,1.0,1)
		_ShadowIntensity("Shadow Intensity", float) = 1
		_LightColor("Light Color", Color) = (0.9,0.9,0.9,1)
		_LightSize("Light Size", Range(0,1)) = 0.5
		_Diffuse("Diffuse", Range(0,0.5)) = 0.1
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" "LightMode" = "ForwardBase"}

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"


			

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal : NORMAL;
			};

			struct v2f
			{
				float4 vertex : SV_POSITION;
				float3 normal : NORMAL;
				float3 worldNormal : TEXCOORD1;
				float3 viewDir : TEXCOORD2;
			};

			float4 _ObjectColor;
			float _ShadowIntensity;
			float4 _LightColor;
			float _LightSize;
			float _Diffuse;
			
			//verter shader
			v2f vert (appdata v)
			{
				v2f o;

				o.vertex = UnityObjectToClipPos(v.vertex);
				//transform vertices based on object transform (unity equivalent mul(UNITY_MATRIX_MVP, float4(pos, 1.0)))
				o.worldNormal = normalize(mul(v	.normal, (float3x3)unity_WorldToObject)); 
				//gets the view direction
				o.viewDir = WorldSpaceViewDir(v.vertex);
				o.normal = v.normal;

				return o;
			}
			
			//pixel shader
			fixed4 frag (v2f i) : SV_Target
			{
			
				//gets the light direction of the scene
				float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);

				//gets the dot product of the object normal and light normal
				float lightDot  = dot(i.normal, lightDir);
				//Adds light if normals equal higher than 0, otherwise adds the _ShadowIntensity
				float lightIntensity = lightDot > 0 ? 1 : _ShadowIntensity;

				//Gets the dot product of the viewer normal and the object normal, then inverses it.
				float viewDot = 1 - dot(normalize(i.viewDir), i.normal);
				float rimLight = viewDot * lightDot * _LightColor;
				float rim = smoothstep(_LightSize - _Diffuse, _LightSize + _Diffuse, rimLight);


				return _ObjectColor * (lightIntensity + rim);
			}

			ENDCG
		}
		        pass
        {
            Tags{"LightMode" = "ShadowCaster"} 
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma muli_compile_shadowcaster
            #include "UnityCG.cginc"

             struct v2f { 
                V2F_SHADOW_CASTER;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG

        }
	}
}
