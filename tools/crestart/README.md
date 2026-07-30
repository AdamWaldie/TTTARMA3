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

## Regenerating

```sh
pip install Pillow
python3 crests.py                       # writes art/*.png + art/boxes.json
cd png2paa && go build -o ../png2paa-bin .
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
