Shader "Unlit/CRTShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap("Normal Map",2D) = "bump" {}
        _DistortionLevel("Distortion Level", float) = 0.1
        _ScanlineMask("Scanline Mask", 2D) = "black" {}
        _ScanlineTex("Scanline Texture", 2D) = "White" {}
        _LineThickness("Line Thickness", float)  = 1
        _ScanlineSpeed("Scanline Speed", float) = 0.01
        _ScreenJiggleSpeed("Screen Jiggle Speed", float) = 0.01
        _ScreenJiggleLevel("Screen Jiggle Level", float) = 1
        
    }
    SubShader
    {
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : TEXCOORD1;
                float2 uv : TEXCOORD0;
               
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float3 normal : TEXCOORD1;
                float4 vertex : SV_POSITION;
                
            };

            sampler2D _MainTex;
            sampler2D _NormalMap;
            sampler2D _ScanlineMask;
            sampler2D _ScanlineTex;

            float4 _MainTex_ST;
            float4 _Saturation = 0.1;
            float _LineThickness;
            float _ScanlineSpeed;
            float _ScreenJiggleSpeed;
            float _ScreenJiggleLevel;
            float _DistortionLevel;

            v2f vert (appdata v)
            {
                v2f o;
                
                //This adds the jitter movement
                float2 offset = v.vertex.y / v.vertex.x * UNITY_PI;
                float2 jitterMovement = sin( _Time.y*_ScreenJiggleSpeed - offset) / _ScreenJiggleLevel;
                v.vertex.x += saturate(jitterMovement);

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.normal = v.normal;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

         
            fixed4 frag (v2f i) : SV_Target
            {

                //Sampling the Normal map
                half2 normalMap = tex2D(_NormalMap, i.uv);
                half2 distortion = normalMap - 0.5f;
                i.uv += distortion * _DistortionLevel;

                
                

                //renders the scanlines on the given mask texture
                fixed4 mask = tex2D(_ScanlineMask, i.uv + _Time.y * (float2)_ScanlineSpeed);
                fixed4 scanlines = tex2D(_ScanlineTex,i.uv);
                scanlines *= mask.r;
                


                //scanline uv values to the 'camera texture' 
                fixed4 camera = tex2D(_MainTex, i.uv);    

                //Multiply the uvs with an oscillating value to create those horizontal lines.
                //The horizontal lines can be made thicker or thinner with _LineThickness
                fixed4 screenEffect = camera + scanlines * sin(i.vertex.y * _LineThickness); 
                return screenEffect;
            }
            ENDCG
        }
    }
}
