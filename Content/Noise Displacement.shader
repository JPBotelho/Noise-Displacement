Shader "Cloud Displacement"
{	
	Properties 
	{
		_Color ("Color", Color) = (1, 1, 1, 1)
		_MainTex("Albedo (RGB)", 2D) = "white" {}
		_BumpMap("Bumpmap", 2D) = "bump" {}
		_Noise("Noise (RGB)", 2D) = "white" {}
		_Glossiness("Smoothness", Range(0, 1)) = 0.5
		_Metallic("Metallic", Range(0, 1)) = 0.0

		_Speed("Speed", Range(0.01, 5)) = 0.0
		_DistanceX("DistanceX", Range(0.1, 5)) = 0.0
		_DistanceY("DistanceY", Range(0.1, 5)) = 0.0
		_DistanceZ("DistanceZ", Range(0.1, 5)) = 0.0

		_MinHeightX("Min Height X", Range(-10, 10)) = 0.0
		_MinHeightY("Min Height Y", Range(-10, 10)) = 0.0
		_MinHeightZ("Min Height Z", Range(-10, 10)) = 0.0

		_Smoothing("Smoothing", Range(1, 256)) = 0.0

		[MaterialToggle]
		_Randomize("Randomize", Float) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" 
				"DisableBatching" = "True"}
		LOD 200
		
		CGPROGRAM
		
		#pragma surface surf Standard fullforwardshadows vertex:vert addshadow
		#pragma target 3.0

		sampler2D _MainTex;
		sampler2D _Noise;
		sampler2D _BumpMap;

		struct Input 
		{
			float2 uv_MainTex;
			float4 color : Color;
			float2 uv_BumpMap;
		};

		half _Glossiness;
		half _Metallic;
		half _Randomize;
		float4 _Color;

		half _Speed;
		half _DistanceX;	
		half _DistanceY;	
		half _DistanceZ;

		half _MinHeightX;
		half _MinHeightY;
		half _MinHeightZ;

		half _Smoothing;

		float randomNum(in float2 uv)
		{
     		float2 noise = (frac(sin(dot(uv, float2(12.9898,78.233)*2.0)) * 43758.5453));
     		return abs(noise.x + noise.y) * 0.1;
 		}

		void vert( inout appdata_full v )
		{				
			float2 noise = tex2Dlod(_Noise, float4(v.vertex.xy + _Time.y * _Speed, 0, 0)) + randomNum(v.vertex) * _Randomize;

			for (int i = 1; i < _Smoothing; i++)
			{
				noise = tex2Dlod(_Noise, float4(v.vertex.xy - i + _Time.y * _Speed, 0, 0)) + randomNum(v.vertex) * _Randomize;
			}

			float2 Znoise = tex2Dlod(_Noise, float4(v.vertex.z + _Time.y * _Speed, v.vertex.z + _Time.y * _Speed, 0, 0));

			bool mx = (v.vertex.x > _MinHeightX);
			bool my = (v.vertex.y > _MinHeightY);
			bool mz = (v.vertex.z > _MinHeightZ);

			v.vertex.x += (v.normal.x * noise / (_Smoothing + 1)) * _DistanceX * (mx + my + mz == 3);
			v.vertex.y += (v.normal.y * noise / (_Smoothing + 1)) * _DistanceY * (mx + my + mz == 3);
			v.vertex.z += (v.normal.z * noise / (_Smoothing + 1)) * _DistanceZ * (mx + my + mz == 3);
		}

		void surf (Input IN, inout SurfaceOutputStandard o) 
		{			
			fixed4 c = tex2D (_MainTex, IN.uv_MainTex) * _Color;

			o.Normal = UnpackNormal (tex2D (_BumpMap, IN.uv_BumpMap));
			o.Albedo = c;
			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Alpha = c.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
