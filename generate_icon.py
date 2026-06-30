#!/usr/bin/env python3
from PIL import Image, ImageDraw, ImageFont
import os

def create_icon(size):
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    corner = size // 4
    draw.rounded_rectangle([(0, 0), (size-1, size-1)], radius=corner, fill=(25, 80, 180, 255))
    
    for y in range(size):
        a = int(30 * (y / size))
        draw.line([(0, y), (size, y)], fill=(0, 0, a, 30))
    
    nx, ny, ns = size//3, size//5, size//5
    sw = max(2, size//25)
    draw.rectangle([(nx+ns, ny), (nx+ns+sw, ny+ns*2)], fill=(255, 215, 130, 255))
    draw.ellipse([(nx, ny+ns), (nx+ns, ny+ns*2)], fill=(255, 215, 130, 255))
    
    wx = nx + ns + sw + size//20
    wy = ny + ns//2
    for i in range(3):
        ws = (i+1) * size//12
        ax = wx + i * size//15
        draw.arc([(ax, wy-ws//2), (ax+ws, wy+ws//2)], -60, 60, fill=(255,255,255,200), width=max(2, size//80))
    
    ky = size//2 + size//10
    ks = size//7
    kr = size//40
    bw = max(1, size//200)
    
    kx1 = size//4
    draw.rounded_rectangle([(kx1, ky), (kx1+ks, ky+ks)], radius=kr, fill=(200,230,255,255), outline=(150,180,220,255), width=bw)
    sx, sy, ss = kx1+ks//3, ky+ks//3, ks//3
    draw.rectangle([(sx, sy), (sx+ss//3, sy+ss)], fill=(80,130,190,255))
    draw.polygon([(sx+ss//3, sy-ss//6), (sx+ss, sy+ss//2), (sx+ss//3, sy+ss+ss//6)], fill=(80,130,190,255))
    
    kx2 = kx1 + ks + size//20
    draw.rounded_rectangle([(kx2, ky), (kx2+ks, ky+ks)], radius=kr, fill=(200,230,255,255), outline=(150,180,220,255), width=bw)
    px, py = kx2+ks//2, ky+ks//2
    ps = ks//4
    draw.rectangle([(px-ps//2, py-ps//6), (px+ps//2, py+ps//6)], fill=(80,130,190,255))
    draw.rectangle([(px-ps//6, py-ps//2), (px+ps//6, py+ps//2)], fill=(80,130,190,255))
    
    kx3 = kx2 + ks + size//20
    draw.rounded_rectangle([(kx3, ky), (kx3+ks, ky+ks)], radius=kr, fill=(200,230,255,255), outline=(150,180,220,255), width=bw)
    mx, my, ms = kx3+ks//3, ky+ks//3, ks//4
    draw.ellipse([(mx, my+ms//2), (mx+ms, my+ms)], fill=(80,130,190,255))
    draw.rectangle([(mx+ms-2, my), (mx+ms+2, my+ms)], fill=(80,130,190,255))
    
    fs = max(10, size//8)
    try:
        font = ImageFont.truetype("/System/Library/Fonts/SFNSMono.ttf", fs)
    except:
        try:
            font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", fs)
        except:
            font = ImageFont.load_default()
    
    text = "KEY SOUND"
    try:
        bbox = draw.textbbox((0, 0), text, font=font)
        tw = bbox[2] - bbox[0]
    except:
        tw = len(text) * fs // 2
    tx = (size - tw) // 2
    ty = size - size // 5
    draw.text((tx, ty), text, fill=(255, 255, 255, 255), font=font)
    
    return img

output_dir = "/Users/kmpz/Projects/KeyboardSound/KeyboardSound/Assets.xcassets/AppIcon.appiconset"

sizes_map = {
    16: [("icon_16x16.png", 16), ("icon_16x16@2x.png", 32)],
    32: [("icon_32x32.png", 32), ("icon_32x32@2x.png", 64)],
    128: [("icon_128x128.png", 128), ("icon_128x128@2x.png", 256)],
    256: [("icon_256x256.png", 256), ("icon_256x256@2x.png", 512)],
    512: [("icon_512x512.png", 512), ("icon_512x512@2x.png", 1024)],
}

for base_size, files in sizes_map.items():
    for fname, px_size in files:
        icon = create_icon(px_size)
        icon.save(f"{output_dir}/{fname}")
        print(f"Created {fname} ({px_size}x{px_size})")

print("\nAll icons created!")
