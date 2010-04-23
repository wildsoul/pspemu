module pspemu.core.gpu.ops.Texture;

template Gpu_Texture() {
	static pure string TextureArrayOperation(string type, string code) { return ArrayOperation(type, 0, 7, code); }

	/**
	 * Set texture-mode parameters
	 *
	 * Available texture-formats are:
	 *   - GU_PSM_5650 - Hicolor, 16-bit
	 *   - GU_PSM_5551 - Hicolor, 16-bit
	 *   - GU_PSM_4444 - Hicolor, 16-bit
	 *   - GU_PSM_8888 - Truecolor, 32-bit
	 *   - GU_PSM_T4 - Indexed, 4-bit (2 pixels per byte)
	 *   - GU_PSM_T8 - Indexed, 8-bit
	 *
	 * @param tpsm - Which texture format to use
	 * @param maxmips - Number of mipmaps to use (0-8)
	 * @param a2 - Unknown, set to 0
	 * @param swizzle - GU_TRUE(1) to swizzle texture-reads
	 **/
	// void sceGuTexMode(int tpsm, int maxmips, int a2, int swizzle);

	// Texture Mode
	auto OP_TMODE() {
		with (gpu.state) {
			textureSwizzled  = command.extract!(uint, 0, 8) != 0;
			mipmapShareClut  = command.extract!(uint, 8, 8) == 0;
			mipMapLevel      = command.extract!(uint, 16, 8);
		}
	}

	// Texture Pixel Storage Mode
	auto OP_TPSM() {
		gpu.state.textureFormat = command.extractEnum!(PixelFormats);
	}

	/**
	 * Set current texturemap
	 *
	 * Textures may reside in main RAM, but it has a huge speed-penalty. Swizzle textures
	 * to get maximum speed.
	 *
	 * @note Data must be aligned to 1 quad word (16 bytes)
	 *
	 * @param mipmap - Mipmap level
	 * @param width - Width of texture (must be a power of 2)
	 * @param height - Height of texture (must be a power of 2)
	 * @param tbw - Texture Buffer Width (block-aligned)
	 * @param tbp - Texture buffer pointer (16 byte aligned)
	 **/
	// void sceGuTexImage(int mipmap, int width, int height, int tbw, const void* tbp);

	// Texture Base Pointer
	mixin (TextureArrayOperation("TBPx", q{
		with (gpu.state.textures[Index]) {
			address &= 0xFF000000;
			address |= command.param24;
		}
	}));

	// Texture Buffer Width.
	mixin (TextureArrayOperation("TBWx", q{
		with (gpu.state.textures[Index]) {
			buffer_width = command.extract!(uint, 0, 16); // ???
			address &= 0x00FFFFFF;
			address |= command.extract!(uint, 16, 8) << 24;
		}
	}));

	// Texture Size
	mixin (TextureArrayOperation("TSIZEx", q{
		with (gpu.state.textures[Index]) {
			width  = 1 << command.extract!(uint, 0, 8);
			height = 1 << command.extract!(uint, 8, 8);
			format   = gpu.state.textureFormat;
			swizzled = gpu.state.textureSwizzled;
		}
	}));

	/**
	 * Flush texture page-cache
	 *
	 * Do this if you have copied/rendered into an area currently in the texture-cache
	**/
	// void sceGuTexFlush(void);

	// Texture Flush. NOTE: 'sceGuTexImage' and 'sceGuTexMode' calls TFLUSH.
	auto OP_TFLUSH() {
		//writefln("TFLUSH!");
	}

	/**
	 * Synchronize rendering pipeline with image upload.
	 *
	 * This will stall the rendering pipeline until the current image upload initiated by
	 * sceGuCopyImage() has completed.
	 **/
	// void sceGuTexSync();

	// Texture Sync
	auto OP_TSYNC() {
		//writefln("TSYNC!");
	}

	/**
	 * Set how the texture is filtered
	 *
	 * Available filters are:
	 *   - GU_NEAREST
	 *   - GU_LINEAR
	 *   - GU_NEAREST_MIPMAP_NEAREST
	 *   - GU_LINEAR_MIPMAP_NEAREST
	 *   - GU_NEAREST_MIPMAP_LINEAR
	 *   - GU_LINEAR_MIPMAP_LINEAR
	 *
	 * @param min - Minimizing filter
	 * @param mag - Magnifying filter
	 **/
	// void sceGuTexFilter(int min, int mag);

	// Texture FiLTer
	auto OP_TFLT() {
		with (gpu.state) {
			textureFilterMin = command.extractEnum!(TextureFilter, 0); // only GL_NEAREST, GL_LINEAR (no mipmaps) (& 0b_1)
			textureFilterMag = command.extractEnum!(TextureFilter, 8); // only GL_NEAREST, GL_LINEAR (no mipmaps) (& 0b_1)
		}
	}

	/**
	 * Set if the texture should repeat or clamp
	 *
	 * Available modes are:
	 *   - GU_REPEAT - The texture repeats after crossing the border
	 *   - GU_CLAMP - Texture clamps at the border
	 *
	 * @param u - Wrap-mode for the U direction
	 * @param v - Wrap-mode for the V direction
	 **/
	// void sceGuTexWrap(int u, int v);

	// Texture WRAP
	auto OP_TWRAP() {
		with (gpu.state) {
			textureWrapU = command.extractEnum!(WrapMode, 0);
			textureWrapV = command.extractEnum!(WrapMode, 8);
		}
	}

	/**
	 * Set how textures are applied
	 *
	 * Key for the apply-modes:
	 *   - Cv - Color value result
	 *   - Ct - Texture color
	 *   - Cf - Fragment color
	 *   - Cc - Constant color (specified by sceGuTexEnvColor())
	 *
	 * Available apply-modes are: (TFX)
	 *   - GU_TFX_MODULATE - Cv=Ct*Cf TCC_RGB: Av=Af TCC_RGBA: Av=At*Af
	 *   - GU_TFX_DECAL - TCC_RGB: Cv=Ct,Av=Af TCC_RGBA: Cv=Cf*(1-At)+Ct*At Av=Af
	 *   - GU_TFX_BLEND - Cv=(Cf*(1-Ct))+(Cc*Ct) TCC_RGB: Av=Af TCC_RGBA: Av=At*Af
	 *   - GU_TFX_REPLACE - Cv=Ct TCC_RGB: Av=Af TCC_RGBA: Av=At
	 *   - GU_TFX_ADD - Cv=Cf+Ct TCC_RGB: Av=Af TCC_RGBA: Av=At*Af
	 *
	 * The fields TCC_RGB and TCC_RGBA specify components that differ between
	 * the two different component modes.
	 *
	 *   - GU_TFX_MODULATE - The texture is multiplied with the current diffuse fragment
	 *   - GU_TFX_REPLACE - The texture replaces the fragment
	 *   - GU_TFX_ADD - The texture is added on-top of the diffuse fragment
	 *   
	 * Available component-modes are: (TCC)
	 *   - GU_TCC_RGB - The texture alpha does not have any effect
	 *   - GU_TCC_RGBA - The texture alpha is taken into account
	 *
	 * @param tfx - Which apply-mode to use
	 * @param tcc - Which component-mode to use
	**/
	// void sceGuTexFunc(int tfx, int tcc);

	// Texture enviroment Mode
	auto OP_TFUNC() {
		with (gpu.state) {
			textureEffect = command.extractEnum!(TextureEffect);
		}
	}

	/**
	 * Set texture scale
	 *
	 * @note Only used by the 3D T&L pipe, renders ton with GU_TRANSFORM_2D are
	 * not affected by this.
	 *
	 * @param u - Scalar to multiply U coordinate with
	 * @param v - Scalar to multiply V coordinate with
	 **/
	// void sceGuTexScale(float u, float v);

	// UV SCALE
	auto OP_USCALE () { gpu.state.textureScale.u = command.float1; }
	auto OP_VSCALE () { gpu.state.textureScale.v = command.float1; }

	/**
	 * Set texture offset
	 *
	 * @note Only used by the 3D T&L pipe, renders done with GU_TRANSFORM_2D are
	 * not affected by this.
	 *
	 * @param u - Offset to add to the U coordinate
	 * @param v - Offset to add to the V coordinate
	 **/
	// void sceGuTexOffset(float u, float v);

	// UV OFFSET
	auto OP_UOFFSET() { gpu.state.textureOffset.u = command.float1; }
	auto OP_VOFFSET() { gpu.state.textureOffset.v = command.float1; }
}
