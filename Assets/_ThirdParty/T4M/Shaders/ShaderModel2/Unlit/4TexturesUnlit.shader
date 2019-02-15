Shader "T4MShaders/ShaderModel2/Unlit/T4M 4 Textures Unlit LM" {
Properties {
    _Splat0 ("Layer1 (RGB)", 2D) = "white" {}
	_Splat1 ("Layer2 (RGB)", 2D) = "white" {}
	_Splat2 ("Layer3 (RGB)", 2D) = "white" {}
	_Splat3 ("Layer4 (RGB)", 2D) = "white" {}
	_Control ("Control (RGBA)", 2D) = "white" {}
	_MainTex ("Never Used", 2D) = "white" {}
}
SubShader {
    Pass {

		CGPROGRAM
		#include "UnityCG.cginc"
		#pragma vertex vert
		#pragma fragment frag
		#pragma multi_compile LIGHTMAP_ON LIGHTMAP_OFF
		#pragma exclude_renderers xbox360 ps3
		sampler2D _Splat0 ;
		sampler2D _Splat1 ;
		sampler2D _Splat2 ;
		sampler2D _Splat3;
		sampler2D _Control;

		struct v2f {
			float4  pos : SV_POSITION;
			#ifdef LIGHTMAP_ON
			float2  uv[6] : TEXCOORD0;
			#endif
			#ifdef LIGHTMAP_OFF
			float2  uv[5] : TEXCOORD0;
			#endif
		};

		float4 _Splat0_ST;
		float4 _Splat1_ST;
		float4 _Splat2_ST;
		float4 _Splat3_ST;
		float4 _Control_ST;
		#ifdef LIGHTMAP_ON
            fixed4 unity_LightmapST;
            sampler2D unity_Lightmap;
        #endif

		v2f vert (appdata_full  v)
		{
			v2f o;
			o.pos = mul (UNITY_MATRIX_MVP, v.vertex);
			o.uv[0] = TRANSFORM_TEX (v.texcoord, _Splat0);
			o.uv[1] = TRANSFORM_TEX (v.texcoord, _Splat1);
			o.uv[2] = TRANSFORM_TEX (v.texcoord, _Splat2);
			o.uv[3] = TRANSFORM_TEX (v.texcoord, _Splat3);
			o.uv[4] = TRANSFORM_TEX (v.texcoord, _Control);
			 #ifdef LIGHTMAP_ON
            	o.uv[5] = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
            #endif
			return o;
		}

		fixed4 frag (v2f i) : COLOR
		{
			fixed4 Mask = tex2D( _Control, i.uv[4].xy );
			fixed3 lay1 = tex2D( _Splat0, i.uv[0].xy );
			fixed3 lay2 = tex2D( _Splat1, i.uv[1].xy );
			fixed3 lay3 = tex2D( _Splat2, i.uv[2].xy );
			fixed3 lay4 = tex2D( _Splat3, i.uv[3].xy );
   				
    		fixed4 c;
			c.xyz = (lay1.xyz * Mask.r + lay2.xyz * Mask.g + lay3.xyz * Mask.b + lay4.xyz * Mask.a);
			#ifdef LIGHTMAP_ON
           		 c.rgb *= DecodeLightmap(tex2D(unity_Lightmap, i.uv[5]));
            #endif
			c.w = 0;
			return c;
		}
		ENDCG
    }
}
} 