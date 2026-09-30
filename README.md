# House Keychain Phone Stand

A 1" × 1" × 0.75" (25.4 × 25.4 × 19 mm) house keychain. The front half swings
down on a print-in-place hinge and turns into a phone stand. The lid's roof
edge overlaps the back half's roof like a shingle and snaps shut: two small ridges under
its edge click into pockets in the back half's roof.

## Files

- `house_keychain.scad`: the model. Set `part` to `closed`, `open`, `print`, `body`, or `lid`.
- `house_keychain_print.stl`: the whole keychain as one print, with the lid folded open.

- `hotel_keychain.scad`: the hotel, a 1" × 2.5" × 0.75" version (see below). It includes the house model and only changes a few values.
- `hotel_keychain_print.stl`: the hotel as one print, with the lid folded open.

## Printing

- Print `house_keychain_print.stl` as exported: body upright and lid flat, joined only by the hinge.
- No supports needed.
- PETG (tougher and more heat-resistant than PLA, which matters for a keychain). 0.4 mm nozzle, 0.12 mm layers or finer.
- Use a textured plate or glue stick: PETG can bond too well to smooth PEI.
- In the slicer preview, check that the 0.35 mm hinge gaps show up as gaps and aren't filled in.
- After printing, work the hinge back and forth a few times to free it. Then fold the lid up until it clicks.

## Using it as a stand

Fold the lid down flat. Set the phone's bottom edge on the open lid, just in
front of the hinge. The phone leans back against the roof ridge at about 15°,
and the lid's roof edge acts as a lip that stops it sliding forward. Phones up
to about 12 mm thick, case included, fit between the hinge and the lip.

The stand is tiny, so **landscape is the stable orientation**. Portrait works
with lighter phones, but it can tip backward.

## The hotel

The hotel is 2.5" (63.5 mm) tall with the same footprint, hinge and roof snap.
Its whole front wall folds down into a 2.5" base. The phone's bottom edge sits
out on that base against a rib and leans back on the roof ridge at 20°. Because
the phone stands well forward of the hotel and is held 2.5" up, portrait is
stable too.

- `phone_lean`: the lean angle (20°). It sets how far out on the base the phone sits. 0 gives the house layout.
- `lip_h`: rib height (6 mm). The rib sits just past the front of a `phone_t` phone and folds away inside the closed hotel.
- `roof_h`: eave-to-peak height (9 mm).
- `floors`, `floor_h`: rows of windows and their spacing.

## Tuning

- `pip_clr`: hinge gap, 0.35 mm for PETG. Raise to 0.4 if the hinge prints fused. Lower it (0.3 suits PLA) if it's floppy.
- `open_stop`: blocks under the front of the outer hinge knuckles stop the lid about 10° past flat, instead of
  letting it swing all the way round. Printed, they sit `clr` (0.3 mm) from the lid's front wall, and that gap
  is why it stops just past 90° rather than exactly at it.
- `snap`: how firmly the lid clicks shut (how far the lid's ridges reach into the body's roof). 0.35 mm for PETG. Use 0.3 for PLA: it gives a good click in PLA but was too soft in PETG.
  The part that flexes is mostly the lid's thin roof edge. The ridges print as horizontal ribs on it, so
  their height comes from the XY accuracy of the printer, not from the layer height.
- `overlap`, `lip_t`, `fit`: how far the lid's roof edge laps over the body's roof,
  how thick that edge is, and the gap under it. `under_t` thickens the body roof
  under the overlap. `bump_dx` sets how far the ridges sit from the peak.
- `snap_ridge`: how long each ridge is along the roof slope (4 mm by default), for a firmer
  click in PETG. Set it to 0 for round bumps.
- `phone_t`: the thickest phone, case included, that the stand fits (12 mm by default). The eave
  height is calculated from it: thicker phones mean higher walls and a flatter roof. Anything over
  about 16 mm is rejected with an error. When run, the `open` view echoes the lean angle and where the lip is.
- `roof_split`: a higher value gives a more upright phone but a smaller lip.
- `keyring_d`: keyring hole size, 3 mm by default and up to about 5 mm. The hole runs sideways through the top of the
  chimney, so the ring loops over the chimney when closed and lies flat past the end of the lid
  when it's open. The chimney gets deeper and taller to fit bigger holes, and rises above the 1"
  peak from about 3 mm up. `chim_rim` sets the material around the hole and `chim_cap` the material above it.
- `chamfer`: bevel on all the outside edges (0.8 mm) so it doesn't snag in a pocket.
- `details`: door and windows. Off by default for the house; the hotel turns them on.
