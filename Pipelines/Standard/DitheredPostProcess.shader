// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Dithered/DitheredPostProcess"
{
	Properties
	{
		_Primary("Primary", 3D) = "white" {}
		_Secondary("Secondary", 3D) = "white" {}
		_NoiseIntensity("Noise Intensity", Range( 0 , 1)) = 0
		[IntRange]_PixelScale("Pixel Scale", Range( 1 , 32)) = 3
		_Pattern("Pattern", 2D) = "white" {}
		_Intensity("Intensity", Range( 0 , 1)) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

	}

	SubShader
	{
		LOD 0

		Cull Off
		ZWrite Off
		ZTest Always
		
		Pass
		{
			CGPROGRAM

			

			#pragma vertex Vert
			#pragma fragment Frag
			#pragma target 3.0

			#include "UnityCG.cginc"
			
		
			struct ASEAttributesDefault
			{
				float3 vertex : POSITION;
				float2 texcoord : TEXCOORD0;
				
			};

			struct ASEVaryingsDefault
			{
				float4 vertex : SV_POSITION;
				float2 texcoord : TEXCOORD0;
				float2 texcoordStereo : TEXCOORD1;
			#if STEREO_INSTANCING_ENABLED
				uint stereoTargetEyeIndex : SV_RenderTargetArrayIndex;
			#endif
				
			};

			uniform sampler2D _MainTex;
			uniform half4 _MainTex_TexelSize;
			uniform half4 _MainTex_ST;
			
			uniform sampler3D _Primary;
			SamplerState sampler_Primary;
			uniform float _PixelScale;
			uniform float _NoiseIntensity;
			uniform sampler2D _Pattern;
			float4 _Pattern_TexelSize;
			uniform sampler3D _Secondary;
			uniform float _Intensity;


			float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }
			float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }
			float snoise( float2 v )
			{
				const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
				float2 i = floor( v + dot( v, C.yy ) );
				float2 x0 = v - i + dot( i, C.xx );
				float2 i1;
				i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
				float4 x12 = x0.xyxy + C.xxzz;
				x12.xy -= i1;
				i = mod2D289( i );
				float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
				float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
				m = m * m;
				m = m * m;
				float3 x = 2.0 * frac( p * C.www ) - 1.0;
				float3 h = abs( x ) - 0.5;
				float3 ox = floor( x + 0.5 );
				float3 a0 = x - ox;
				m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
				float3 g;
				g.x = a0.x * x0.x + h.x * x0.y;
				g.yz = a0.yz * x12.xz + h.yz * x12.yw;
				return 130.0 * dot( m, g );
			}
			

			float2 TransformTriangleVertexToUV (float2 vertex)
			{
				float2 uv = (vertex + 1.0) * 0.5;
				return uv;
			}

			ASEVaryingsDefault Vert( ASEAttributesDefault v  )
			{
				ASEVaryingsDefault o;
				o.vertex = float4(v.vertex.xy, 0.0, 1.0);
				o.texcoord = TransformTriangleVertexToUV (v.vertex.xy);
#if UNITY_UV_STARTS_AT_TOP
				o.texcoord = o.texcoord * float2(1.0, -1.0) + float2(0.0, 1.0);
#endif
				o.texcoordStereo = TransformStereoScreenSpaceTex (o.texcoord, 1.0);

				v.texcoord = o.texcoordStereo;
				float4 ase_ppsScreenPosVertexNorm = float4(o.texcoordStereo,0,1);

				

				return o;
			}

			float4 Frag (ASEVaryingsDefault i  ) : SV_Target
			{
				float4 ase_ppsScreenPosFragNorm = float4(i.texcoordStereo,0,1);

				float2 uv_MainTex = i.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				float pixelWidth99 =  1.0f / ( _MainTex_TexelSize.z / _PixelScale );
				float pixelHeight99 = 1.0f / ( _MainTex_TexelSize.w / _PixelScale );
				half2 pixelateduv99 = half2((int)(uv_MainTex.x / pixelWidth99) * pixelWidth99, (int)(uv_MainTex.y / pixelHeight99) * pixelHeight99);
				float2 ifLocalVar150 = 0;
				if( _PixelScale == 1.0 )
				ifLocalVar150 = uv_MainTex;
				else
				ifLocalVar150 = pixelateduv99;
				float4 tex2DNode16 = tex2D( _MainTex, ifLocalVar150 );
				float4 tex3DNode21 = tex3D( _Primary, tex2DNode16.rgb );
				float simplePerlin2D55 = snoise( ifLocalVar150*400.0 );
				simplePerlin2D55 = simplePerlin2D55*0.5 + 0.5;
				float2 appendResult125 = (float2(_MainTex_TexelSize.z , _MainTex_TexelSize.w));
				float2 appendResult137 = (float2(_Pattern_TexelSize.z , _Pattern_TexelSize.w));
				float4 ifLocalVar78 = 0;
				if( ( ( 1.0 - tex3DNode21.a ) + ( ( simplePerlin2D55 - 0.5 ) * _NoiseIntensity * 0.5 ) ) >= tex2D( _Pattern, ( ( uv_MainTex * appendResult125 ) / ( appendResult137 * _PixelScale ) ) ).r )
				ifLocalVar78 = tex3DNode21;
				else
				ifLocalVar78 = tex3D( _Secondary, tex2DNode16.rgb );
				float4 lerpResult143 = lerp( tex2D( _MainTex, uv_MainTex ) , ifLocalVar78 , _Intensity);
				float4 appendResult149 = (float4(lerpResult143.rgb , tex2DNode16.a));
				

				float4 color = appendResult149;
				
				return color;
			}
			ENDCG
		}
	}
	CustomEditor "ASEMaterialInspector"
	
	
}
/*ASEBEGIN
Version=18600
1920;0;1920;1059;-820.1799;617.0328;1;True;True
Node;AmplifyShaderEditor.RangedFloatNode;102;-1454.308,179.8068;Inherit;False;Property;_PixelScale;Pixel Scale;3;1;[IntRange];Create;True;0;0;False;0;False;3;0;1;32;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;19;-1641.758,-284.0669;Inherit;False;0;0;_MainTex;Pass;False;0;5;SAMPLER2D;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;146;-1682.96,-16.37935;Inherit;False;0;0;_MainTex_TexelSize;Pass;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;100;-1113.95,-50.06746;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;103;-1111.95,44.93254;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;104;-1219.95,-188.0674;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TexturePropertyNode;135;247.5125,-680.2329;Inherit;True;Property;_Pattern;Pattern;4;0;Create;True;0;0;False;0;False;e93a8fd2c6f834a4db0b63332be0e388;e93a8fd2c6f834a4db0b63332be0e388;False;white;Auto;Texture2D;-1;0;2;SAMPLER2D;0;SAMPLERSTATE;1
Node;AmplifyShaderEditor.TFHCPixelate;99;-967.9498,-59.06746;Inherit;False;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TemplateShaderPropertyNode;147;83.94959,-447.0381;Inherit;False;0;0;_MainTex_TexelSize;Pass;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ConditionalIfNode;150;-754.9392,-130.3088;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT2;0,0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TexelSizeNode;134;513.4124,-670.233;Inherit;False;-1;1;0;SAMPLER2D;;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;125;304.5999,-380.2401;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.DynamicAppendNode;137;736.4125,-565.233;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;55;432.0437,472.3454;Inherit;False;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;400;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;16;-544.7579,-125.0669;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;130;453.5999,-455.2401;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;65;422.0068,588.209;Inherit;False;Property;_NoiseIntensity;Noise Intensity;2;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;136;918.4124,-451.233;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;64;617.8846,473.3755;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;21;87.86964,163.6868;Inherit;True;Property;_Primary;Primary;0;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;LockedToTexture3D;False;Object;-1;Auto;Texture3D;8;0;SAMPLER3D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;141;734.5151,667.8055;Inherit;False;Constant;_half;half;5;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;775.9672,476.1425;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;89;515.4644,296.9899;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleDivideOpNode;131;596.5999,-456.2401;Inherit;False;2;0;FLOAT2;0,0;False;1;FLOAT2;32,32;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;22;79.86963,368.6868;Inherit;True;Property;_Secondary;Secondary;1;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;LockedToTexture3D;False;Object;-1;Auto;Texture3D;8;0;SAMPLER3D;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;57;936.2194,305.6742;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;114;872.9064,-224.7713;Inherit;True;Property;_TextureSample1;Texture Sample 1;5;0;Create;True;0;0;False;0;False;-1;85ddff4e0ef71ed4eacad79c8468a044;85ddff4e0ef71ed4eacad79c8468a044;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;144;1511.737,-495.6285;Inherit;False;Property;_Intensity;Intensity;5;0;Create;True;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ConditionalIfNode;78;1623.7,-25.07655;Inherit;False;False;5;0;FLOAT;0;False;1;FLOAT;0.25;False;2;COLOR;0,0,0,0;False;3;COLOR;0,0,0,0;False;4;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;145;1490.92,-407.4106;Inherit;True;Property;_TextureSample2;Texture Sample 2;0;0;Create;True;0;0;False;0;False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;143;1919.564,-183.5361;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.TexelSizeNode;138;-1443.877,-111.5946;Inherit;False;-1;1;0;SAMPLER2D;;False;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.DynamicAppendNode;149;2093.97,-182.6583;Inherit;False;FLOAT4;4;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;1;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;2542.607,-206.489;Float;False;True;-1;2;ASEMaterialInspector;0;2;Dithered/DitheredPostProcess;32139be9c1eb75640a847f011acf3bcf;True;SubShader 0 Pass 0;0;0;SubShader 0 Pass 0;1;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;True;2;False;-1;True;7;False;-1;False;False;False;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;0;;0;0;Standard;0;0;1;True;False;;False;0
WireConnection;100;0;146;3
WireConnection;100;1;102;0
WireConnection;103;0;146;4
WireConnection;103;1;102;0
WireConnection;104;2;19;0
WireConnection;99;0;104;0
WireConnection;99;1;100;0
WireConnection;99;2;103;0
WireConnection;150;0;102;0
WireConnection;150;2;99;0
WireConnection;150;3;104;0
WireConnection;150;4;99;0
WireConnection;134;0;135;0
WireConnection;125;0;147;3
WireConnection;125;1;147;4
WireConnection;137;0;134;3
WireConnection;137;1;134;4
WireConnection;55;0;150;0
WireConnection;16;0;19;0
WireConnection;16;1;150;0
WireConnection;130;0;104;0
WireConnection;130;1;125;0
WireConnection;136;0;137;0
WireConnection;136;1;102;0
WireConnection;64;0;55;0
WireConnection;21;1;16;0
WireConnection;59;0;64;0
WireConnection;59;1;65;0
WireConnection;59;2;141;0
WireConnection;89;0;21;4
WireConnection;131;0;130;0
WireConnection;131;1;136;0
WireConnection;22;1;16;0
WireConnection;57;0;89;0
WireConnection;57;1;59;0
WireConnection;114;0;135;0
WireConnection;114;1;131;0
WireConnection;78;0;57;0
WireConnection;78;1;114;1
WireConnection;78;2;21;0
WireConnection;78;3;21;0
WireConnection;78;4;22;0
WireConnection;145;0;19;0
WireConnection;143;0;145;0
WireConnection;143;1;78;0
WireConnection;143;2;144;0
WireConnection;138;0;19;0
WireConnection;149;0;143;0
WireConnection;149;3;16;4
WireConnection;0;0;149;0
ASEEND*/
//CHKSM=14532C35A772A5752E06844F873CBCBAFF0DC939