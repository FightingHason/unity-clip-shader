Shader "Clip Plane/Basic"
{
    Properties
    {
        _Color("Color", Color) = (1,1,1,1)
        _MainTex("Main Texture", 2D) = "white" {}
        _PlaneVector("Plane Vector", Vector) = (0,0,0,0)
    }

    SubShader
    {
        Tags{ "RenderType" = "Opaque" "Queue" = "Geometry" }

        Pass
        {

            CGPROGRAM
            #include "UnityCG.cginc"
            #pragma target 5.0
            #pragma vertex vert
            #pragma fragment frag

            uniform fixed4 _LightColor0;

            float4 _Color;
            float4 _MainTex_ST;			// For the Main Tex UV transform
            sampler2D _MainTex;			// Texture used for the line
            float4 _PlaneVector;

            struct v2f
            {
                float4 pos		: POSITION;
                float4 col      : COLOR;
                float2 uv		: TEXCOORD0;
                float4 worldpos : TEXCOORD1;
            };

            v2f vert(appdata_base v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldpos = mul(unity_ObjectToWorld, v.vertex);
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);

                float4 norm = mul(unity_ObjectToWorld, v.normal);
                float3 normalDirection = normalize(norm.xyz);
                float4 AmbientLight = UNITY_LIGHTMODEL_AMBIENT;
                float4 LightDirection = normalize(_WorldSpaceLightPos0);
                float4 DiffuseLight = saturate(dot(LightDirection, -normalDirection))*_LightColor0;
                o.col = float4(AmbientLight + DiffuseLight);

                return o;
            }

            float4 frag(v2f i) : COLOR
            {
                float3 norm = normalize(_PlaneVector.xyz);
                float dist = _PlaneVector.w;
                clip(dist - dot(i.worldpos.xyz, norm));

                float4 col = _Color * tex2D(_MainTex, i.uv);
                return col * i.col;
            }

            ENDCG
        }
    }
}
