# Role crest artwork

The crests in `ui/crests/` are generated, not hand-painted, so they can be
re-derived and adjusted. `crests.py` is the source of truth for what each one
looks like; `art.py` is the material toolkit under it (bevels, grain, wear,
fibre, spray roughening, punched holes).

## Why three layers per crest

Arma's only reliable runtime tint is `ctrlSetTextColor` on an `RscPicture`, and
it multiplies the **whole** texture. So each crest ships as three:

| file | tinted? | contains |
|---|---|---|
| `*_base.paa` | no | what the role element sits **on** — drop shadow, crate plank, asphalt, manila card |
| `*_role.paa` | **yes** | luminance-only art (RGB = how lit the material is, A = shape) |
| `*_detail.paa` | no | what sits **over** — amber fittings, bead chain, brass eyelet, clip |

That split is what lets one crest be role-coloured *and* keep fixed amber
detailing, using only mechanisms already proven in this repo: an `RscPicture`
with no colour property renders as authored, and `ctrlSetTextColor` tints one
(`roleTextBG` does exactly this every round).

The balance's dark backing is deliberately **not** baked into any texture — a
baked band left a black hole on Jester/Innocent, which is the "credits omitted
without notice" requirement broken. It's flat `RscText` rects in the credits
group instead, so it vanishes with the number.

## Letter boxes are measured, not chosen

`fitletters.py` derives each crest's letter box and font size instead of anyone
eyeballing them. For every crest it takes a BODY mask - the face a letter is
allowed to occupy, kept as explicit geometry because the rendered layers also
contain the drop shadow, bead chain, string and eyelet - subtracts the balance
band, then grows the largest rectangle that stays wholly inside, centred on that
region. It reports containment per crest, and the sheet draws the box so it can
be checked by eye as well.

Two things it has to get right:

- **Horizontal centre from the bounding box, vertical centre from the centre of
  area.** Different rules on purpose. Horizontally the eye reads the glyph
  against the outline, and a centre of area gets dragged sideways by the dog
  tag's punched hole and the rotated stamps. Vertically the centre of area keeps
  the glyph in the wide part of a tapering shape like the patch's shield.
- **The ink allowance must clear a DESCENDER.** `J` drops below the baseline;
  assuming cap height was the sole cause of every overflow, and every worst case
  was a Jester `J`. Purista isn't available here to measure against, so
  `INK_W/INK_H` stay deliberately generous.

## Alpha bleed is mandatory

`art.bleed()` runs on every layer before conversion, and skipping it is a visible
bug rather than a nicety. DXT compresses RGB independently of alpha, and the GPU
bilinearly filters across fully-transparent pixels whenever the texture is drawn
at any scale. Those pixels still carry RGB, so left at the default black every
crest renders with a dark halo and every punched hole fringes. Flooding each
transparent pixel with the nearest opaque colour makes what bleeds in match what
it bleeds into. Alpha is untouched, so nothing visible moves.

## Regenerating

```sh
pip install Pillow numpy
python3 crests.py       # writes art/*.png
python3 fitletters.py   # measures letter boxes -> art/boxes.json, reports containment
python3 -c 'import glob;from PIL import Image;from art import bleed;\
[bleed(Image.open(f).convert("RGBA")).save(f) for f in glob.glob("art/*.png")]'
cd png2paa && go build -o ../png2paa-bin . && cd ..
for f in art/*.png; do ./png2paa-bin "$f" "${f%.png}.paa"; done
cp art/*.paa ../../ui/crests/
```

`boxes.json` carries each crest's letter and balance boxes in canvas pixels, so
the config offsets are derived from the art rather than guessed alongside it.

`png2paa` wraps `github.com/woozymasta/paa` — the same encoder the existing
`role.paa`/`rolebg.paa`/`roleshadow.paa` were made with. Verified: its output is
structurally identical to those files (same DXT5 magic, same GGAT tag layout,
same size for the same dimensions). A hand-rolled PAA writer just trades one
silent texture-load failure for another.
