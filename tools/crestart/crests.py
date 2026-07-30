"""The eight role crests, drawn. Three thematic wells, per direction: GMod-TTT
heritage (1-2), Armaville military identity (3-5), TTT evidence (6-8).

THREE layers per crest, in draw order:
  base   - untinted, UNDER the role element: the drop shadow, and for the
           "mark on a surface" crests the surface itself (crate plank, asphalt,
           manila card, tag stock). These started out in `detail`, which draws on
           top - so the plank covered its own stencil and every drop shadow
           painted over the object casting it.
  role   - luminance only (RGB = how lit the material is, A = shape). Multiplied
           by the role colour at runtime via ctrlSetTextColor. Nothing
           fixed-coloured can live here.
  detail - untinted, OVER: amber fittings, bead chain, brass eyelet, credit band.

Returns (base, role, detail, letter_box, credit_box); boxes in canvas pixels, so
the config offsets are derived from the art and the two can't drift apart.
"""
from art import *
from PIL import Image, ImageDraw, ImageFilter, ImageChops
import math

# Luminance floor for role layers. Started near 100, which multiplied against an
# already-dark role colour (Jester purple, Traitor red) into mud. These keep the
# hue readable while still reading as shaded material.
LO = (156, 156, 156, 255)
LO_SOFT = (188, 188, 188, 255)
HI = (255, 255, 255, 255)
AMBER = (216, 158, 51)

def fill(m, colour):
    o = blank(); o.paste(Image.new("RGBA", (S, S), colour), (0, 0), m); return o

# The balance's backing is deliberately NOT baked into any texture. Baked bands
# left a black hole on Jester/Innocent - roles with no credits - which is exactly
# the "omitted without notice" requirement broken. It's two flat RscText rects in
# the credits group instead, so it disappears with the number and the crest is
# left whole. Flat rects are also the technique with no failure history here.

# Per-style letter colour. The material already carries the role colour, so a
# role-tinted letter on a role-coloured field half-vanishes. Where the letter
# sits on the role element it's a knockout; where it sits on pale card (the two
# paper crests) it's the role colour, reading as ink; on the stencil it's the
# plank showing through, because on a real stencil the glyph is the UNPAINTED
# part.
LETTER = {
    1: "cream", 2: "cream", 3: "cream", 4: "cream",
    5: "plank", 6: "role", 7: "cream", 8: "role",
}

# ---------------------------------------------------------------- 1 Struck Coin
def struck_coin():
    """Heritage. The disc-and-letter as a struck coin: milled rim, recessed
    field, exergue at the foot where the balance is stamped."""
    disc = ellipse([14, 14, 242, 242])
    base = shadow(disc, (5, 6), 7, 150)

    role = shade(disc, HI, LO, 135)
    rim = ImageChops.subtract(disc, ellipse([34, 34, 222, 222]))
    milling = mask(); d = drawon(milling)
    for i in range(96):
        a = i * math.pi / 48
        d.line([128 + 100*math.cos(a), 128 + 100*math.sin(a),
                128 + 124*math.cos(a), 128 + 124*math.sin(a)],
               fill=255 if i % 2 else 80, width=3)
    role.alpha_composite(fill(ImageChops.multiply(milling, rim), (255, 255, 255, 80)))
    role = bevel(role, disc, 6, (255,255,255,130), (0,0,0,120))
    role = bevel(role, ellipse([36, 36, 220, 220]), 4, (0,0,0,80), (255,255,255,90))
    spec = ellipse([34, 24, 196, 118]).filter(ImageFilter.GaussianBlur(20))
    role.alpha_composite(fill(ImageChops.multiply(spec, disc), (255, 255, 255, 70)))
    role = grain(role, 10, 3, 11)

    det = blank()
    ex = ImageChops.multiply(rectm([48, 176, 208, 212]), ellipse([20, 20, 236, 236]))
    return base, role, det, (28, 32, 200, 130), (48, 178, 160, 32)

# ---------------------------------------------------------------- 2 Enamel Pin
def enamel_pin():
    """Heritage, dressed up. Cloisonné enamel in a polished brass cloison - the
    same disc, but jewellery rather than a sticker."""
    outer = ellipse([16, 16, 240, 240])
    enam = ellipse([36, 36, 220, 220])
    base = shadow(outer, (5, 7), 8, 155)

    role = shade(enam, HI, LO, 118)
    gl = ImageChops.multiply(ellipse([50, 44, 208, 138]), enam)
    role.alpha_composite(fill(gl.filter(ImageFilter.GaussianBlur(6)), (255,255,255,110)))
    role = bevel(role, enam, 3, (255,255,255,150), (0,0,0,90), 118)

    det = blank()
    cloison = ImageChops.subtract(outer, enam)
    det.alpha_composite(shade(cloison, (240, 200, 116, 255), (132, 96, 32, 255), 118))
    det.alpha_composite(fill(edge(outer, 3), (58, 40, 12, 165)))
    det.alpha_composite(fill(edge(enam, 2, inner=False), (72, 50, 16, 140)))
    return base, role, det, (40, 46, 176, 116), (52, 181, 152, 26)

# ---------------------------------------------------------------- 3 Dog Tag
def dog_tag():
    """Military identity. A stamped tag on its bead chain - debossed border,
    brushed steel, the punched hole an actual hole."""
    body = roundrect([18, 74, 238, 186], 54)
    hole = [30, 116, 62, 148]
    base = punch(shadow(body, (5, 7), 7, 150), hole)

    role = shade(body, HI, LO, 160)
    st = noise(21, 1).resize((S, 8), Image.BILINEAR).resize((S, S), Image.BILINEAR)
    role.alpha_composite(fill(ImageChops.multiply(
        st.point(lambda v: max(0, v - 145)), body), (255, 255, 255, 60)))
    role = bevel(role, body, 5, (255,255,255,130), (0,0,0,120), 160)
    role = bevel(role, roundrect([32, 88, 224, 172], 42), 3, (0,0,0,90), (255,255,255,80), 160)
    role = wear(role, 24, 4, 13)
    role = punch(role, hole)

    det = blank()
    det.alpha_composite(fill(edge(ellipse(hole), 3, inner=False), (26, 26, 22, 200)))
    dd = drawon(det)
    for t in (0.0, 0.16, 0.32, 0.48, 0.64, 0.80):
        cx, cy = 46 - 40 * t, 132 - 128 * t
        r = 7.5 - t * 2
        dd.ellipse([cx-r, cy-r, cx+r, cy+r], fill=(202, 204, 196, 255), outline=(58, 60, 54, 255))
    det = punch(det, hole)
    # Mirrored. Drawn with the eyelet and chain on the left, but the crest lives in
    # the bottom-RIGHT of the screen: a chain running up-left points back across
    # the HUD, while up-right reads as the tag hanging from something past the
    # corner. It also moves the hole off the side the letter wants.
    flip = lambda im: im.transpose(Image.FLIP_LEFT_RIGHT)
    return flip(base), flip(role), flip(det), (70, 78, 116, 70), (46, 152, 164, 24)

# ---------------------------------------------------------------- 4 Unit Patch
def unit_patch():
    """Military identity. An embroidered patch: satin-stitch field, merrowed
    amber edge, canvas tooth. Cloth, not metal."""
    body = polym([(40, 26), (216, 26), (216, 156), (128, 228), (40, 156)])
    inner = polym([(54, 40), (202, 40), (202, 150), (128, 210), (54, 150)])
    base = shadow(body, (5, 7), 8, 150)

    role = shade(inner, HI, LO, 125)
    stitch = mask(); ds = drawon(stitch)
    for i in range(-S, S * 2, 5):
        ds.line([i, 0, i + S, S], fill=255, width=2)
    role.alpha_composite(fill(ImageChops.multiply(stitch, inner), (255,255,255,60)))
    role.alpha_composite(fill(ImageChops.multiply(
        stitch.transform((S,S), Image.AFFINE, (1,0,2,0,1,2)), inner), (0,0,0,50)))
    role = grain(role, 22, 1, 17)

    det = blank()
    merrow = ImageChops.subtract(body, inner)
    det.alpha_composite(shade(merrow, (234, 190, 100, 255), (130, 92, 30, 255), 125))
    ridge = mask(); dr = drawon(ridge)
    for i in range(-S, S * 2, 9):
        dr.line([i, 0, i + 44, S], fill=255, width=3)
    det.alpha_composite(fill(ImageChops.multiply(ridge, merrow), (62, 44, 14, 130)))
    band = polym([(60, 152), (196, 152), (196, 174), (128, 196), (60, 174)])
    return base, role, det, (58, 46, 140, 100), (64, 154, 128, 24)

# ---------------------------------------------------------------- 5 Crate Stencil
def crate_stencil():
    """Military identity. Spray paint through a stencil onto a crate plank -
    overspray, ragged edges, plank seams. The only crest that is a mark ON
    something rather than an object, so the plank is the base layer."""
    plank = rectm([16, 44, 240, 212])
    base = shadow(plank, (5, 6), 7, 145)
    base.alpha_composite(shade(plank, (108, 112, 82, 255), (60, 64, 44, 255), 140))
    wg = noise(43, 1).resize((24, S), Image.BILINEAR).resize((S, S), Image.BILINEAR)
    base.alpha_composite(fill(ImageChops.multiply(
        wg.point(lambda v: max(0, v - 138)), plank), (26, 28, 16, 140)))
    bd = drawon(base)
    for y in (44, 128, 212):
        bd.line([16, y, 240, y], fill=(32, 34, 22, 215), width=3)
    base.alpha_composite(fill(edge(plank, 3), (28, 30, 18, 165)))

    block = rectm([36, 62, 220, 190])
    st = rough(block, 68, 7, 23)
    st = ImageChops.subtract(st, rough(edge(block, 5), 95, 9, 29))
    # Patchy coverage across the face - a stencilled crate is never solid.
    st = ImageChops.subtract(st, noise(47, 3).point(lambda v: max(0, (v - 196) * 4)))
    role = shade(st, HI, LO_SOFT, 150)
    role = grain(role, 34, 1, 31)
    hz = ImageChops.multiply(noise(37, 2).point(lambda v: max(0, (v - 203) * 4)),
                             edge(block, 14, inner=False))
    role.alpha_composite(fill(hz, (255, 255, 255, 130)))
    role = wear(role, 44, 6, 41)

    det = blank()
    dd = drawon(det)
    for x in (24, 232):
        dd.rectangle([x - 3, 118, x + 3, 138], fill=AMBER + (215,))
    return base, role, det, (46, 64, 164, 94), (46, 168, 164, 24)

# ---------------------------------------------------------------- 6 Case File
def case_file():
    """Evidence. A manila file cover with a rubber clearance stamp - the stamp is
    the role, the folder is fixed. Ink over card, so the card is the base."""
    card = rectm([14, 22, 242, 232])
    base = shadow(card, (5, 7), 7, 150)
    base.alpha_composite(shade(card, (216, 198, 154, 255), (170, 152, 112, 255), 140))
    fib = noise(67, 1).point(lambda v: max(0, v - 162))
    base.alpha_composite(fill(ImageChops.multiply(fib, card), (122, 106, 72, 140)))
    bd = drawon(base)
    bd.line([14, 22, 242, 22], fill=(240, 228, 192, 225), width=3)
    base.alpha_composite(fill(edge(card, 2), (108, 94, 62, 175)))

    stamp_o = roundrect([34, 42, 222, 148], 10)
    ring = ImageChops.subtract(stamp_o, roundrect([46, 54, 210, 136], 6))
    ink = ImageChops.lighter(ring, ImageChops.multiply(
        roundrect([46, 54, 210, 136], 6), noise(53, 4).point(lambda v: 255 if v > 212 else 0)))
    ink = rough(ink, 76, 5, 59)
    role = shade(ink, HI, LO_SOFT, 130)
    role = grain(role, 46, 1, 61)
    role = role.rotate(-7, resample=Image.BICUBIC)

    det = blank()
    dd = drawon(det)
    dd.rounded_rectangle([174, 6, 232, 44], radius=6, fill=(182, 184, 176, 255),
                         outline=(66, 68, 62, 255), width=2)
    dd.line([182, 25, 224, 25], fill=(94, 96, 90, 225), width=2)
    return base, role, det, (40, 48, 176, 94), (30, 200, 196, 24)

# ---------------------------------------------------------------- 7 Chalk Mark
def chalk_mark():
    """Evidence. A chalk mark on asphalt - the crest as something drawn at the
    scene rather than issued. Dusty, broken, no object at all."""
    asphalt = rough(rectm([6, 12, 250, 242]), 30, 9, 127)
    base = shade(asphalt, (78, 78, 76, 240), (42, 42, 41, 240), 130)
    ag = noise(97, 1).point(lambda v: max(0, v - 118))
    base.alpha_composite(fill(ImageChops.multiply(ag, asphalt), (144, 144, 140, 100)))
    base.alpha_composite(fill(ImageChops.multiply(
        noise(101, 2).point(lambda v: max(0, (v - 188) * 3)), asphalt), (16, 16, 16, 160)))

    ring = ImageChops.subtract(rectm([38, 38, 218, 198]), rectm([60, 60, 196, 176]))
    corner = mask(); dc = drawon(corner)
    for (x, y) in [(38, 38), (218, 38), (38, 198), (218, 198)]:
        dc.line([x - 30, y, x + 30, y], fill=255, width=11)
        dc.line([x, y - 30, x, y + 30], fill=255, width=11)
    stroke = ImageChops.lighter(rough(ring, 70, 5, 71), rough(corner, 48, 6, 73))
    stroke = ImageChops.subtract(stroke, noise(79, 3).point(lambda v: max(0, (v - 190) * 3)))
    role = shade(stroke, HI, (222, 222, 222, 255), 120)
    role = grain(role, 58, 1, 83)   # chalk is dusty, not flat
    dust = ImageChops.multiply(noise(89, 2).point(lambda v: max(0, (v - 210) * 5)),
                               edge(ring, 20, inner=False))
    role.alpha_composite(fill(dust, (255, 255, 255, 165)))

    det = blank()
    return base, role, det, (56, 56, 144, 112), (56, 204, 144, 26)

# ---------------------------------------------------------------- 8 Evidence Tag
def evidence_tag():
    """Evidence. A narrow manila tag, brass eyelet punched through the TOP RIGHT,
    ink stamp across it - the column-with-a-tag-in-the-corner shape made literal."""
    body = polym([(74, 44), (162, 24), (196, 58), (196, 238), (74, 238)])
    eye = [156, 34, 188, 66]
    base = shadow(body, (5, 7), 7, 150)
    base.alpha_composite(shade(body, (218, 200, 156, 255), (168, 150, 110, 255), 140))
    fib = noise(113, 1).point(lambda v: max(0, v - 164))
    base.alpha_composite(fill(ImageChops.multiply(fib, body), (120, 104, 70, 145)))
    base.alpha_composite(fill(edge(body, 2), (106, 92, 60, 180)))
    base = punch(base, eye)

    stamp = roundrect([80, 62, 192, 156], 8)
    ink = rough(ImageChops.subtract(stamp, roundrect([90, 72, 182, 146], 5)), 74, 5, 103)
    ink = ImageChops.lighter(ink, ImageChops.multiply(
        roundrect([90, 72, 182, 146], 5), noise(107, 4).point(lambda v: 255 if v > 216 else 0)))
    role = shade(ink, HI, LO_SOFT, 130)
    role = grain(role, 46, 1, 109)
    role = role.rotate(-5, resample=Image.BICUBIC)
    role = punch(role, eye)

    det = blank()
    det.alpha_composite(fill(edge(ellipse([150, 28, 194, 72]), 5), (208, 168, 76, 255)))
    dd = drawon(det)
    dd.ellipse([150, 28, 194, 72], outline=(118, 86, 28, 255), width=3)
    dd.line([172, 42, 148, 6], fill=(228, 222, 200, 240), width=4)
    dd.line([172, 42, 198, 10], fill=(198, 192, 170, 215), width=3)
    det = punch(det, eye)
    return base, role, det, (90, 74, 92, 72), (82, 200, 108, 26)

CRESTS = [("struckCoin", struck_coin), ("enamelPin", enamel_pin), ("dogTag", dog_tag),
          ("unitPatch", unit_patch), ("crateStencil", crate_stencil),
          ("caseFile", case_file), ("chalkMark", chalk_mark), ("evidenceTag", evidence_tag)]

if __name__ == "__main__":
    import json
    boxes = {}
    for i, (name, fn) in enumerate(CRESTS, start=1):
        b, r, d, lb, cb = fn()
        save(b, "%s_base" % name); save(r, "%s_role" % name); save(d, "%s_detail" % name)
        boxes[i] = {"name": name, "letter": lb, "credit": cb, "letterColour": LETTER[i]}
        print("%d %-13s letter=%s credit=%s" % (i, name, lb, cb))
    json.dump(boxes, open("art/boxes.json", "w"), indent=1)
