Shader "Unlit/TestShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
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
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
     
            

            //vertex shading
            v2f vert (appdata v)
            {
                v2f o;
                
                //v.vertex.y = sin(_Time.y + phase);
                v.vertex.y += saturate(0.1f*sin(UNITY_PI*2 * _Time.y + v.vertex.x));
              
                
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
               
                return o;
            } 

            //fragment shading
            fixed4 frag (v2f i) : SV_Target
            {
                //float2 uvCoords = float2(i.uv.x, i.uv.y += 0.1f*sin(_Time.y + phase*2));
                fixed4 col = tex2D(_MainTex, i.uv);                             
                return col;
            }
            ENDCG
        }
    }
}
