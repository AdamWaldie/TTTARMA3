"""Material toolkit for the role crests.

Every crest ships as TWO textures, because Arma's only reliable runtime tint is
ctrlSetTextColor on an RscPicture, which multiplies the WHOLE texture:

  *_role.paa   luminance-only art (RGB = how lit the material is, A = shape).
               ctrlSetTextColor multiplies it, so this becomes the role colour
               with its shading intact. Nothing fixed-coloured can live here.
  *_detail.paa full-colour art drawn on top and never tinted - amber fittings,
               paper, brass, chalk dust, wear, shadow.

That split is what lets one crest be role-coloured AND keep fixed amber
detailing, using only the two mechanisms already proven in this repo: an
RscPicture with no colour property renders as-authored (roleTextBG before it's
tinted), and ctrlSetTextColor tints one (roleTextBG in fn_initHud, every round).
"""
import math, random
from PIL import Image, ImageDraw, ImageFilter, ImageChops

S = 256   # texture size; the crest draws at ~160px on a 1080p screen

def blank(): return Image.new("RGBA", (S, S), (0, 0, 0, 0))
def mask(): return Image.new("L", (S, S), 0)
def drawon(im): return ImageDraw.Draw(im)

def noise(seed, scale=1, lo=0, hi=255):
    """Value noise, smoothed - grain, fibre and wear all come off this."""
    r = random.Random(seed)
    small = max(2, S // scale)
    n = Image.new("L", (small, small))
    n.putdata([r.randint(lo, hi) for _ in range(small * small)])
    return n.resize((S, S), Image.BICUBIC)

def grain(img, amount=14, scale=1, seed=1):
    """Fine tooth, luminance only.

    Must rebuild via merge, NOT img.paste(rgb): pasting an RGB image into an RGBA
    one overwrites the alpha channel with 255 everywhere, which silently turns
    every shaped crest into a full-canvas square. That bug put a solid
    role-coloured block behind seven of these before it was caught on a
    contact sheet.
    """
    n = noise(seed, scale)
    pos = n.point(lambda v: max(0, v - 128) * amount // 128)
    neg = n.point(lambda v: max(0, 128 - v) * amount // 128)
    r, g, b, a = img.split()
    out = []
    for ch in (r, g, b):
        out.append(ImageChops.subtract(ImageChops.add(ch, pos), neg))
    return Image.merge("RGBA", out + [a])

def shade(m, rgb_light, rgb_dark, angle=135, softness=0):
    """Directional lighting across a mask: a linear ramp from light to dark, so
    a flat shape reads as a lit surface rather than a swatch."""
    ramp = Image.new("L", (S, S))
    px = ramp.load()
    dx, dy = math.cos(math.radians(angle)), math.sin(math.radians(angle))
    for y in range(S):
        for x in range(S):
            t = ((x / S) * dx + (y / S) * dy + 1) / 2
            px[x, y] = max(0, min(255, int(t * 255)))
    base = Image.new("RGBA", (S, S), rgb_dark)
    top = Image.new("RGBA", (S, S), rgb_light)
    base.paste(top, (0, 0), ramp)
    if softness: m = m.filter(ImageFilter.GaussianBlur(softness))
    out = blank(); out.paste(base, (0, 0), m)
    return out

def edge(m, width=3, inner=True):
    """The rim of a mask - the band a bevel's highlight and shadow live in."""
    shrunk = m.filter(ImageFilter.MinFilter(max(3, width * 2 + 1)))
    return ImageChops.subtract(m, shrunk) if inner else \
           ImageChops.subtract(m.filter(ImageFilter.MaxFilter(max(3, width*2+1))), m)

def bevel(img, m, width=4, light=(255, 255, 255, 110), dark=(0, 0, 0, 130), angle=135):
    """Highlight the lit edge, shadow the far one. This is what makes struck
    metal, a debossed tag or an embroidered edge read as having thickness."""
    band = edge(m, width)
    dx = int(round(math.cos(math.radians(angle)) * width))
    dy = int(round(math.sin(math.radians(angle)) * width))
    hi = blank(); hi.paste(Image.new("RGBA", (S, S), light), (0, 0), band)
    lo = blank(); lo.paste(Image.new("RGBA", (S, S), dark), (0, 0), band)
    out = img.copy()
    out.alpha_composite(hi.transform((S, S), Image.AFFINE, (1, 0, dx, 0, 1, dy)))
    out.alpha_composite(lo.transform((S, S), Image.AFFINE, (1, 0, -dx, 0, 1, -dy)))
    a = out.split()[3]
    out.putalpha(ImageChops.multiply(a, m.point(lambda v: 255 if v > 8 else v * 8)))
    return out

def rough(m, amount=42, scale=6, seed=3):
    """Break a clean edge up - spray overspray, chalk crumble, torn card."""
    n = noise(seed, scale)
    return ImageChops.subtract(m, n.point(lambda v: max(0, v - (255 - amount))))

def wear(img, amount=30, scale=5, seed=7):
    """Rub the alpha thin in patches. Age, not damage."""
    n = noise(seed, scale).point(lambda v: 255 - max(0, (v - (255 - amount)) * 6))
    out = img.copy()
    out.putalpha(ImageChops.multiply(out.split()[3], n))
    return out

def shadow(m, off=(5, 6), blur=6, alpha=150):
    """Contact shadow, so the crest sits ON the world instead of floating."""
    sh = blank()
    sh.paste(Image.new("RGBA", (S, S), (0, 0, 0, alpha)), (0, 0), m)
    sh = sh.transform((S, S), Image.AFFINE, (1, 0, -off[0], 0, 1, -off[1]))
    return sh.filter(ImageFilter.GaussianBlur(blur))

def roundrect(box, r):
    m = mask(); drawon(m).rounded_rectangle(box, radius=r, fill=255); return m
def ellipse(box):
    m = mask(); drawon(m).ellipse(box, fill=255); return m
def rectm(box):
    m = mask(); drawon(m).rectangle(box, fill=255); return m
def polym(pts):
    m = mask(); drawon(m).polygon(pts, fill=255); return m

def punch(img, box):
    """An actual hole - a punched eyelet has to be see-through, and a dark disc
    pretending to be one is exactly the kind of shortcut that reads as fake."""
    hole = ellipse(box)
    out = img.copy()
    out.putalpha(ImageChops.subtract(out.split()[3], hole))
    return out

def save(img, name, outdir="art"):
    import os
    os.makedirs(outdir, exist_ok=True)
    img.save("%s/%s.png" % (outdir, name))
    return "%s/%s.png" % (outdir, name)
