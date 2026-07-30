"""Derives each crest's letter box by measurement instead of by eye.

For every crest: take the BODY mask (the face a letter is allowed to occupy),
subtract the balance band, then grow the largest axis-aligned rectangle that
stays entirely inside it, centred on that region's own centre of area. The letter
box and font size come out of that, so a glyph cannot leave its shape and cannot
sit off-centre in it.

Sized against a deliberately pessimistic glyph that clears a descender, because
"J" drops below the baseline. The game's font is Purista, which isn't available
here to measure, so the margin is the point.
"""
from art import *
from PIL import Image, ImageChops
import crests as C, json

# Ink box as a fraction of font size. INK_H must clear a DESCENDER, not just cap
# height: "J" drops below the baseline, and assuming caps-only was the whole
# source of the overflow - every worst case was a Jester J. Purista isn't
# available here to measure, so both numbers stay deliberately generous.
INK_W, INK_H = 0.90, 1.10

def rot(m, deg):
    return m.rotate(deg, resample=Image.BICUBIC)

# The face of each crest a letter may sit on. Kept as explicit geometry rather
# than derived from the rendered alpha, because the rendered layers also contain
# the drop shadow, bead chain, string and eyelet, none of which are "face".
BODY = {
    1: lambda: ellipse([36, 36, 220, 220]),                                    # inside the milled rim
    2: lambda: ellipse([36, 36, 220, 220]),                                    # the enamel field
    # Mirrored to match dog_tag()'s flip: hole on the RIGHT (x -> S-1-x).
    3: lambda: ImageChops.subtract(roundrect([31, 88, 223, 172], 42),
                                   ellipse([187, 110, 231, 154])),             # tag face, minus the punched hole
    4: lambda: polym([(54, 40), (202, 40), (202, 150), (128, 210), (54, 150)]), # inside the merrowed edge
    5: lambda: rectm([36, 62, 220, 190]),                                       # the sprayed block
    6: lambda: rot(roundrect([46, 54, 210, 136], 6), -7),                       # inside the stamp ring, as rotated
    7: lambda: rectm([60, 60, 196, 176]),                                       # inside the chalk ring
    8: lambda: rot(roundrect([90, 72, 182, 146], 5), -5),                       # inside the stamp ring, as rotated
}

def centre(m):
    """Horizontally, the bounding box's centre; vertically, the centre of area.

    Two different rules on purpose. Horizontally the eye reads the letter against
    the shape's outline, so the bbox centre is what looks centred - a centre of
    area gets dragged sideways by the dog tag's punched hole and by the rotated
    stamps, which then reads as off-centre even though it is technically correct.
    Vertically the centre of area is better: it keeps the letter in the wide part
    of a tapering shape like the patch's shield instead of pushing it down into
    the point.
    """
    px = m.load(); sy = n = 0
    for y in range(S):
        for x in range(S):
            if px[x, y] > 128: sy += y; n += 1
    bx0, _, bx1, _ = m.getbbox()
    return ((bx0 + bx1 - 1) / 2, sy / n, n)

def fits(px, x0, y0, x1, y1):
    """Rounds OUTWARD on every side. Truncating instead let a float-bounded check
    sample a different pixel set than the integer-bounded growth loop, which is
    how crest 8 came out reported as contained by one and not by the other."""
    import math
    x0, y0 = math.floor(x0), math.floor(y0)
    x1, y1 = math.ceil(x1), math.ceil(y1)
    if x0 < 0 or y0 < 0 or x1 >= S or y1 >= S: return False
    for y in range(y0, y1 + 1):
        for x in range(x0, x1 + 1):
            if px[x, y] <= 128: return False
    return True

def largest_centred_rect(m, cx, cy):
    """Grow half-extents outward from the centre of area, one axis at a time,
    stopping each when it would cross the mask edge."""
    px = m.load()
    hw = hh = 2
    if not fits(px, cx - hw, cy - hh, cx + hw, cy + hh):
        return None
    grew = True
    while grew:
        grew = False
        if fits(px, cx - hw - 2, cy - hh, cx + hw + 2, cy + hh): hw += 2; grew = True
        if fits(px, cx - hw, cy - hh - 2, cx + hw, cy + hh + 2): hh += 2; grew = True
    return hw, hh

report, out = [], {}
for i, (name, fn) in enumerate(C.CRESTS, start=1):
    *_, lb_old, cb = fn()
    body = BODY[i]()
    # The balance band is off limits, with a little clearance.
    band = rectm([cb[0] - 4, cb[1] - 6, cb[0] + cb[2] + 4, cb[1] + cb[3] + 4])
    region = ImageChops.subtract(body, band)
    cx, cy, area = centre(region)
    hw, hh = largest_centred_rect(region, round(cx), round(cy))
    hw -= 2; hh -= 2   # a pixel of slack on each side, so nothing rides the edge
    # Font size is whichever axis binds first, given the pessimistic ink box.
    size = int(min((hw * 2) / INK_W, (hh * 2) / INK_H))
    box = (round(cx) - hw, round(cy) - hh, hw * 2, hh * 2)
    # Verify: the ink box at that size, centred, really is inside the region.
    iw, ih = size * INK_W, size * INK_H
    rcx, rcy = round(cx), round(cy)
    ok = fits(region.load(), rcx - iw/2, rcy - ih/2, rcx + iw/2, rcy + ih/2)
    out[i] = {"name": name, "letter": list(box), "letterSize": size,
              "credit": list(cb), "letterColour": C.LETTER[i]}
    report.append("%d %-13s centre=(%3d,%3d) box=%-22s size=%3d  contained=%s  (was %s)"
                  % (i, name, cx, cy, str(box), size, "YES" if ok else "NO", lb_old))
print("\n".join(report))
json.dump(out, open("art/boxes.json", "w"), indent=1)
