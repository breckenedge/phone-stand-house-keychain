# House Keychain Phone Stand

A 1" × 1" × 0.75" (25.4 × 25.4 × 19 mm) house keychain. The front half swings
down on a print-in-place hinge and turns into a phone stand. The lid's roof
edge overlaps the back half's roof like a shingle and snaps shut over two small
bumps.

## Files

- `house_keychain.scad`: the model. Set `part` to `closed`, `open`, `print`, `body`, or `lid`.
- `house_keychain_print.stl`: the whole keychain as one print, with the lid folded open.

## Printing

- Print `house_keychain_print.stl` as exported: body upright and lid flat, joined only by the hinge.
- No supports needed.
- 0.4 mm nozzle, 0.12 mm layers or finer.
- In the slicer preview, check that the 0.3 mm hinge gaps show up as gaps and aren't filled in.
- After printing, work the hinge back and forth a few times to free it. Then fold the lid up until it clicks.

## Using it as a stand

Fold the lid down flat. Set the phone's bottom edge on the open lid, just in
front of the hinge. The phone leans back against the roof ridge at about 15°,
and the lid's roof edge acts as a lip that stops it sliding forward.

The stand is tiny, so **landscape is the stable orientation**. Portrait works
with lighter phones, but it can tip backward.

## Tuning

- `pip_clr`: hinge gap. Raise to 0.35–0.4 if the hinge prints fused. Lower it if it's floppy.
- `snap`: how firmly the lid clicks shut (how far the roof bumps overlap the lid's edge).
  The part that flexes is the body's roof, which prints upright, so it bends
  along its layers rather than across them.
- `overlap`, `lip_t`, `fit`: how far the lid's roof edge laps over the body's roof,
  how thick that edge is, and the gap under it. `under_t` thickens the body roof
  under the overlap. `bump_dx` sets how far the bumps sit from the peak.
- `phone_t`: phone thickness in the ghost preview. When run, the `open` view echoes the lean angle and how much the lip catches.
- `roof_split`: a higher value gives a more upright phone but a smaller lip.
