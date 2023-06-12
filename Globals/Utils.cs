using Godot;
using System;
using System.Collections.Generic;
using System.IO;

public class Utils : Node
{
	public float get_dpi_scale()
	{
		return (float)Math.Max(1.0f, Math.Floor(OS.GetScreenDpi() / 96.0f));
	}
	
	public void set_owner_recursive_to(Node new_owner, Node node)
	{
		foreach (Node child in node.GetChildren())
		{
			child.Owner = new_owner;
			set_owner_recursive_to(new_owner, child);
		}
	}

	public Image load_image_from_file(string path)
	{
		Godot.File f = new Godot.File();
		f.Open(path, Godot.File.ModeFlags.Read);
		byte[] buffer = f.GetBuffer((long)f.GetLen());
		f.Close();
		
		Image image = null;
		switch (System.IO.Path.GetExtension(path))
		{
			case ".png":
				image = new Image();
				image.LoadPngFromBuffer(buffer);
				break;
			case ".jpg":
			case ".jpeg":
				image = new Image();
				image.LoadJpgFromBuffer(buffer);
				break;
			case ".bmp":
				image = new Image();
				image.LoadBmpFromBuffer(buffer);
				break;
			case ".tga":
				image = new Image();
				image.LoadTgaFromBuffer(buffer);
				break;
			case ".webp":
				image = new Image();
				image.LoadWebpFromBuffer(buffer);
				break;
		}
		
		return image;
	}

	public Image get_filled_image(int width, int height, Image.Format format, Color color)
	{
		Image image = new Image();
		image.Create(width, height, false, format);
		image.Fill(color);
		return image;
	}

	public Image get_circle_filled_image(int width, int height, Image.Format format, Color color)
	{
		if (width <= 1 || height <= 1 || (width <= 2 && height <= 2))
			return get_filled_image(width, height, format, color);
		
		double sqrtHalf = Math.Sqrt(0.5);
		double oneMinusSqrtHalf = 1.0 - sqrtHalf;

		Image quadrant = new Image();
		quadrant.Create((int)Math.Ceiling(width / 2.0), (int)Math.Ceiling(height / 2.0), false, format);
		
		quadrant.Lock();
		float _width_float = (float)(width - 0.5);
		float _height_float = (float)(height - 0.5);
		// top part
		for (int y = 0; y < Math.Ceiling(quadrant.GetHeight() * oneMinusSqrtHalf); y++)
		{
			float _y = y / _height_float - 0.5f;
			_y = _y * _y - 0.25f;

			int max = (int)quadrant.GetWidth();

			for (int x = (int)Math.Floor(quadrant.GetWidth() * oneMinusSqrtHalf); x < max; x++)
			{
				float _x = x / _width_float - 0.5f;
				quadrant.SetPixel(x, y, color * -Mathf.Sign(_x * _x + _y));
			}
		}
		// left part
		for (int y = (int)Math.Floor(quadrant.GetHeight() * oneMinusSqrtHalf); y < quadrant.GetHeight(); y++)
		{
			int max = (int)Math.Ceiling(quadrant.GetWidth() * oneMinusSqrtHalf);
			float _y = y / _height_float - 0.5f;
			_y = _y * _y - 0.25f;

			for (int x = 0; x < max; x++)
			{
				float _x = x / _width_float - 0.5f;
				quadrant.SetPixel(x, y, color * -Mathf.Sign(_x * _x + _y));
			}
		}
		// completely rectangular part
		int w = (int)Math.Max(1.0, Math.Floor(quadrant.GetWidth() * sqrtHalf));
		int h = (int)Math.Max(1.0, Math.Floor(quadrant.GetHeight() * sqrtHalf));
		quadrant.BlitRect(get_filled_image(w, h, format, color), new Rect2(Vector2.Zero, new Vector2(w, h)), quadrant.GetSize() - new Vector2(w, h));
		quadrant.Unlock();
		
		Rect2 quadrant_rect = new Rect2(Vector2.Zero, quadrant.GetSize());
		
		Image image = new Image();
		image.Create(width, height, false, format);
		
		image.BlitRect(quadrant, quadrant_rect, Vector2.Zero); // top left
		quadrant.FlipX();
		image.BlitRect(quadrant, quadrant_rect, new Vector2((float)Math.Floor(width / 2.0), 0.0f)); // top right
		quadrant.FlipY();
		image.BlitRect(quadrant, quadrant_rect, new Vector2((float)Math.Floor(width / 2.0), (float)Math.Floor(height / 2.0))); // bottom right
		quadrant.FlipX();
		image.BlitRect(quadrant, quadrant_rect, new Vector2(0.0f, (float)Math.Floor(height / 2.0))); // bottom left
		
		return image;
	}


	public Rect2 rotate_boundary(Rect2 rect, Vector2 pivotOffset, float angle)
	{
		Vector2 p1 = rect.Position;
		Vector2 p2 = rect.Position + new Vector2(rect.Size.x, 0);
		Vector2 p3 = rect.Position + new Vector2(0, rect.Size.y);
		Vector2 p4 = rect.Position + rect.Size;

		pivotOffset += rect.Position;
		
		p1 -= pivotOffset;
		p2 -= pivotOffset;
		p3 -= pivotOffset;
		p4 -= pivotOffset;

		p1 = p1.Rotated(angle);
		p2 = p2.Rotated(angle);
		p3 = p3.Rotated(angle);
		p4 = p4.Rotated(angle);

		p1 += pivotOffset;
		p2 += pivotOffset;
		p3 += pivotOffset;
		p4 += pivotOffset;

		Vector2 tl = new Vector2(min4(p1.x, p2.x, p3.x, p4.x), min4(p1.y, p2.y, p3.y, p4.y));
		Vector2 br = new Vector2(max4(p1.x, p2.x, p3.x, p4.x), max4(p1.y, p2.y, p3.y, p4.y));
		return new Rect2(tl, br - tl);
	}




	public void stamp_brushes(Godot.Collections.Dictionary brushApplyList, float brushRadius, float brushForce, Godot.Collections.Array applyCoords, int w, int h)
	{
		float radiusSqr = brushRadius * brushRadius;
		float sqrtForce = Mathf.Sqrt(brushForce);

		foreach (Godot.Collections.Array arr in applyCoords)
		{
			float x = (float)arr[0];
			float y = (float)arr[1];

			int minX = (int)Mathf.Clamp(Mathf.Round(x) - Mathf.Ceil(brushRadius), 0.0f, w);
			int maxX = (int)Mathf.Clamp(Mathf.Round(x) + Mathf.Ceil(brushRadius + 1), 0.0f, w);
			int minY = (int)Mathf.Clamp(Mathf.Round(y) - Mathf.Ceil(brushRadius), 0.0f, h);
			int maxY = (int)Mathf.Clamp(Mathf.Round(y) + Mathf.Ceil(brushRadius + 1), 0.0f, h);

			for (int _y = minY; _y < maxY; _y++)
			{
				float _y_pow = (y-_y) * (y-_y);
				int _y_offset = _y * w;

				for (int _x = minX; _x < maxX; _x++)
				{
					float alphaPrecalc = (x-_x);
					alphaPrecalc = alphaPrecalc * alphaPrecalc + _y_pow;
					if (alphaPrecalc < radiusSqr)
					{
						float alpha = (1.0f - Mathf.Pow(alphaPrecalc / radiusSqr, sqrtForce)) * sqrtForce;
						int key = _x + _y_offset;
						if (brushApplyList.Contains(key))
						{
							float from = (float)brushApplyList[key];
							brushApplyList[key] = from * (1.0f - alpha) + /*1.0f * */alpha;//Mathf.Lerp((float)brushApplyList[key], 1.0f, alpha);
						}
						else
							brushApplyList[key] = alpha;
					}
					else if (_x > x) break;
				}
			}
		}
	}




	class FillContext
	{
		public Image layer;
		public Image newMask;
		public float[] baseColor;
		public float colorSimilarityThreshold;
		public int colorSimilarityMode;
		
		public int width, height;

		public byte[] similarityCache;

		public Func<float[], Color, float> getColorDistance;
	}

	readonly Color COLOR_NO = new Color(0, 0, 0, 0);
	readonly Color COLOR_YES = new Color(0, 0, 0, 1);

	static float abs(float a)
	{
		return a < 0 ? -a : a;
	}
	static float max2_abs(float a, float b)
	{
		if (a < 0) a = -a;
		if (b < 0) b = -b;

		if (b > a)
			a = b;
		return a;
	}
	static float max4_abs(float a, float b, float c, float d)
	{
		if (a < 0) a = -a;
		if (b < 0) b = -b;
		if (c < 0) c = -c;
		if (d < 0) d = -d;

		if (b > a)
			a = b;
		if (c > a)
			a = c;
		if (d > a)
			a = d;
		return a;
	}
	static float min4(float a, float b, float c, float d)
	{
		if (b < a)
			a = b;
		if (c < a)
			a = c;
		if (d < a)
			a = d;
		return a;
	}
	static float max4(float a, float b, float c, float d)
	{
		if (b > a)
			a = b;
		if (c > a)
			a = c;
		if (d > a)
			a = d;
		return a;
	}

	static float getColorDistance_Composite(float[] base_rgbahsv, Color c2)
	{
		return max4_abs(base_rgbahsv[0] - c2.r, base_rgbahsv[1] - c2.g, base_rgbahsv[2] - c2.b, base_rgbahsv[3] - c2.a);
	}
	static float getColorDistance_RGBRed(float[] base_rgbahsv, Color c2)
	{
		return max2_abs(base_rgbahsv[0] - c2.r, base_rgbahsv[3] - c2.a);
	}
	static float getColorDistance_RGBGreen(float[] base_rgbahsv, Color c2)
	{
		return max2_abs(base_rgbahsv[1] - c2.g, base_rgbahsv[3] - c2.a);
	}
	static float getColorDistance_RGBBlue(float[] base_rgbahsv, Color c2)
	{
		return max2_abs(base_rgbahsv[2] - c2.b, base_rgbahsv[3] - c2.a);
	}
	static float getColorDistance_Alpha(float[] base_rgbahsv, Color c2)
	{
		return abs(base_rgbahsv[3] - c2.a);
	}
	static float getColorDistance_HSVHue(float[] base_rgbahsv, Color c2)
	{
		return max2_abs(base_rgbahsv[4] - c2.h, base_rgbahsv[3] - c2.a);
	}
	static float getColorDistance_HSVSaturation(float[] base_rgbahsv, Color c2)
	{
		return max2_abs(base_rgbahsv[5] - c2.s, base_rgbahsv[3] - c2.a);
	}
	static float getColorDistance_HSVValue(float[] base_rgbahsv, Color c2)
	{
		return max2_abs(base_rgbahsv[6] - c2.v, base_rgbahsv[3] - c2.a);
	}
	Func<float[], Color, float>[] getColorInstanceFuncs = {
		getColorDistance_Composite,
		getColorDistance_RGBRed,
		getColorDistance_RGBGreen,
		getColorDistance_RGBBlue,
		getColorDistance_Alpha,
		getColorDistance_HSVHue,
		getColorDistance_HSVSaturation,
		getColorDistance_HSVValue,
	};

	bool __get_similar_color__is_pixel_suitable(FillContext context, int x, int y, int __y_offset)
	{
		int i = x + __y_offset;
		byte[] similarityCache = context.similarityCache;

		if ((similarityCache[i] & 1) == 0)
		{
			// Test mask
			bool bad = context.newMask.GetPixel(x, y).a != 0;
			similarityCache[i] |= (byte)(bad ? 1 : 0);
			if (bad) return false;

			if ((similarityCache[i] & 2) == 0)
			{
				// Test if color too far
				// and cache the result since the base color, image and similarity rules are constant
				if (context.getColorDistance(context.baseColor, context.layer.GetPixel(x, y)) > context.colorSimilarityThreshold)
				{
					similarityCache[i] |= 3;
					return false;
				}

				similarityCache[i] |= 2;
			}

			return true;
		}

		return false;
	}

	public void fill_mask(Image newMask, Image image, Vector2 startPos, float colorSimilarityThreshold, int colorSimilarityMode)
	{
		System.Diagnostics.Stopwatch sw = System.Diagnostics.Stopwatch.StartNew();

		int w = image.GetWidth();
		int h = image.GetHeight();
		
		int x = (int)Math.Round(startPos.x);
		int y = (int)Math.Round(startPos.y);

		if (x < 0 || y < 0 || x >= w || y >= h) return;

		int maxX = x;
		int newY = y;
		bool apply = true;
		
		Color baseColor = image.GetPixel(x, y);
		FillContext context = new FillContext {
			layer = image,
			newMask = newMask,
			baseColor = new float[] { baseColor.r, baseColor.g, baseColor.b, baseColor.a, baseColor.h, baseColor.s, baseColor.v },
			colorSimilarityThreshold = colorSimilarityThreshold,
			colorSimilarityMode = colorSimilarityMode,

			width = w,
			height = h,

			similarityCache = new byte[w * h]
		};
		context.getColorDistance = getColorInstanceFuncs[colorSimilarityMode];
		Stack<int> fillStack = new Stack<int>();
		
		newMask.Lock();

		Image row = get_filled_image(w, 1, newMask.GetFormat(), COLOR_YES);
		
		int _prevMinX = 0;
		int _prevMaxX = 0;

		while (true)
		{
			bool moved = false;

			if (apply)
			{
				_prevMinX = x;
				_prevMaxX = maxX;
				
				maxX = x;

				int _y_offset = y * context.width;
				for (; maxX < w - 1 && __get_similar_color__is_pixel_suitable(context, maxX + 1, y, _y_offset); maxX++);
				for (; x > 0 && __get_similar_color__is_pixel_suitable(context, x - 1, y, _y_offset); x--);

				newMask.BlitRect(row, new Rect2(0, 0, maxX + 1 - x, 1), new Vector2(x, y));
				for (int _x = x; _x <= maxX; _x++)
					context.similarityCache[_y_offset + _x] = 1;

				apply = false;
			}

			int _y_minus_one = y - 1;
			int _y_plus_one = y + 1;
			int _y_minus_one_offset = _y_minus_one * w;
			int _y_plus_one_offset = _y_plus_one * w;
			if (y <= 0)
			{
				for (; x <= maxX; x++)
				{
					// down
					if (__get_similar_color__is_pixel_suitable(context, x, _y_plus_one, _y_plus_one_offset))
					{
						newY = _y_plus_one;
						moved = true;
						break;
					}
				}
			}
			else if (y >= h - 1)
			{
				for (; x <= maxX; x++)
				{
					// up
					if (__get_similar_color__is_pixel_suitable(context, x, _y_minus_one, _y_minus_one_offset))
					{
						newY = _y_minus_one;
						moved = true;
						break;
					}
				}
			}
			else
			{
				for (; x <= maxX; x++)
				{
					// up
					if (__get_similar_color__is_pixel_suitable(context, x, _y_minus_one, _y_minus_one_offset))
					{
						newY = _y_minus_one;
						moved = true;
						break;
					}
					
					// down
					if (__get_similar_color__is_pixel_suitable(context, x, _y_plus_one, _y_plus_one_offset))
					{
						newY = _y_plus_one;
						moved = true;
						break;
					}
				}
			}
			
			if (moved)
			{
				fillStack.Push(x);
				fillStack.Push(y);
				fillStack.Push(maxX);
				
				y = newY;
				apply = true;
			}
			else
			{
				if (fillStack.Count < 3) break; // ok we're done
				maxX = fillStack.Pop();
				y = fillStack.Pop();
				x = fillStack.Pop();
			}
		}
		
		newMask.Unlock();

		sw.Stop();
		GD.Print($"Fill took {sw.ElapsedMilliseconds} ms");
	}
}
