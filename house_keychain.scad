// House Keychain Phone Stand
// A 1" x 1" x 0.75" house. The front half folds down on a hinge and becomes a
// phone stand: the phone's bottom edge sits on the open lid just past the hinge,
// leans on the roof ridge, and the lid's roof edge is the lip in front.
// The body/lid seam is one slanted line along the phone's lean. On the roof, the
// lid's edge overlaps the body's roof like a shingle and snaps over two bumps.
//
// Coordinates: X = width, Y = depth (0 = back, D = front), Z = up.
// Print-in-place hinge: the lid's middle knuckle carries a pin that runs into
// blind holes in the body's end knuckles. Print the whole thing in one piece
// with the lid folded open (part = "print").

/* [View] */
part = "open"; // [closed, open, print, body, lid]
show_phone = true; // ghost phone in the "open" view

/* [Size] */
W = 25.4;           // width  (1")
H = 25.4;           // height to roof peak (1")
D = 19.05;          // depth  (0.75")
wall = 1.2;
floor_t = 1.5;
chamfer = 0.8;      // bevel on the outside edges so it doesn't snag in a pocket

/* [Hinge] */
hinge_r = 3;        // knuckle radius
pin_r = 1.0;        // print-in-place pin radius
pip_clr = 0.35;     // pin-to-hole and knuckle-to-knuckle gap; raise if it prints fused
clr = 0.3;          // moving clearance elsewhere
gap = 0.25;         // seam between body and lid
knuckle_w = 6;      // width of each outer (body) knuckle
open_stop = true;   // square foot on the lid's knuckle: it butts into the end of the body's floor just past flat

/* [Split] */
roof_split = 13.0;  // seam crosses the roof peak here (the phone leans on this edge)

/* [Roof snap] */
overlap = 3.0;      // how far the lid's roof edge laps over the body's roof
lip_t = 0.8;        // thickness of the lid's overlapping edge
fit = 0.1;          // gap under the overlapping edge
under_t = 1.2;      // body roof thickness under the overlap (thickened inward)
snap = 0.35;        // how far the lid's ridges reach into the body's roof; more = firmer
bump_dx = 5;        // ridge distance from the roof peak, on each slope
snap_ridge = 4;     // bumps stretched into ridges this long (along the slope); 0 = round bumps

/* [Phone] */
phone_t = 12;       // thickest phone (incl. case) the stand fits; sets the eave height
phone_fit = 0.1;    // extra room between that phone and the lip

/* [Hotel] */
// These turn the house into the tall hotel (see hotel_keychain.scad).
phone_lean = 0;     // phone's lean in degrees; its bottom edge then sits out on the open lid against a rib. 0 = house
roof_h = 9;         // eave-to-peak height when phone_lean is set (the house's eave comes from phone_t)
lip_h = 6;          // how far the rib stands up from the open lid
lip_w = 1.2;        // rib thickness at its top edge
floors = 1;         // rows of windows
floor_h = 12;       // spacing between the rows

/* [Features] */
details = false;    // door and windows
keyring_d = 3;      // keyring hole; the chimney grows (deeper, taller) to fit it
chim_rim = 0.8;     // chimney material beside the keyring hole and between it and the roof
chim_cap = 1.6;     // chimney material above the keyring hole

/* [Hidden] */
$fn = 40;
e = 0.01;
ay = D - hinge_r;                    // hinge axis
az = hinge_r;
floor_end = ay - hinge_r - clr;      // body floor ends here
lid_z0 = az + hinge_r + clr;         // lid front wall starts above body knuckles
lid_x0 = wall + clr;                 // lid front wall sits between body side walls
lid_x1 = W - wall - clr;
mid_x0 = knuckle_w + pip_clr;        // lid knuckle span
mid_x1 = W - knuckle_w - pip_clr;
pin_cap = 1.0;                       // closed outer end of each body knuckle
// phone's back face: bottom edge just past the hinge knuckles, leaning on the ridge
// (hotel: further out on the open lid, wherever phone_lean puts it)
rib = phone_lean > 0;
// house: far enough out that the leaning phone's back clears the knuckle by about 0.2 mm
// (worked out at the lean of a first guess; the real lean is a touch steeper, costing ~0.03 mm)
lean0 = atan((ay + hinge_r + 0.5 - roof_split) / (H - wall));
phone_by = rib ? roof_split + (H - wall) * tan(phone_lean)
               : ay + ((hinge_r - wall) * sin(lean0) + hinge_r + 0.2) / cos(lean0);
lean = atan((phone_by - roof_split) / (H - wall));
// wall height: puts the lip (the lid's roof edge at the eave, once open) just past
// the front of a phone_t phone (hotel: the rib is the lip, so the eave is free)
eave = rib ? H - roof_h : phone_by + phone_t * cos(lean) + phone_fit - ay + az - gap / 2;
assert(eave < H - 5, str("phone_t too thick: eave ", eave, " leaves too little roof"));
echo(str("eave ", eave, ", roof pitch ", atan((H - eave) / (W / 2)), " deg"));
// roof snap: ridges under the lid's edge click into pockets in the body's recessed roof
roof_k = (H - eave) / (W / 2);       // roof slope
roof_a = atan(roof_k);
recess = lip_t + fit;                // depth of the body roof's recess
bump_r = fit + snap;
assert(bump_dx - snap_ridge / 2 > 1, "snap_ridge too long: the ridges would cross the roof peak");
// hotel's rib: its phone-side face, as a height on the closed lid's front wall
rib_z = az + phone_by + phone_t * cos(lean) + phone_fit - ay;
rib_base = lip_w + lip_h / 2;        // thickness at the root
if (rib) {
    assert(rib_z + rib_base < eave, "phone_lean too steep: the rib would land on the lid's roof");
    assert(lip_h > phone_t * sin(lean) + 1, "lip_h too low to catch the phone's front corner");
    assert(lip_h < D - 2 * wall - 1, "lip_h too tall to fit inside the closed hotel");
}
function seam_y(z) = phone_by - (z - wall) * tan(lean);
function bump_pos(x) = let (z = H - abs(x - W / 2) * roof_k - recess / cos(roof_a))
    [x, seam_y(z) - overlap / 2 / cos(lean), z];

// ---------- basic shapes ----------

module pent2d() { polygon([[0, 0], [W, 0], [W, eave], [W / 2, H], [0, eave]]); }

module inner2d() {
    intersection() {
        offset(delta = -wall) pent2d();
        translate([-1, floor_t]) square([W + 2, H]);
    }
}

// extrude a profile in the XZ plane between y0 and y1
module prism(y0, y1) { translate([0, y1, 0]) rotate([90, 0, 0]) linear_extrude(y1 - y0) children(); }

// the house's outside with every edge chamfered; body and lid are clipped to it
module pent_ch(i = 0) { offset(delta = chamfer - i, chamfer = true) offset(delta = -chamfer) pent2d(); }
module envelope(i = 0) {  // i: inset
    hull() {
        prism(chamfer, D - chamfer) pent_ch(i);
        prism(i, D - i) offset(delta = -chamfer) pent_ch(i);
    }
}

// box with its top and vertical edges chamfered
module chamfered_box(s, c) {
    hull() {
        translate([c, 0, 0]) cube([s.x - 2 * c, s.y, s.z - c]);
        translate([0, c, 0]) cube([s.x, s.y - 2 * c, s.z - c]);
        translate([c, c, 0]) cube([s.x - 2 * c, s.y - 2 * c, s.z]);
    }
}

module shell() {
    difference() {
        prism(0, D) pent2d();
        prism(wall, D - wall) inner2d();
    }
}

module along_axis(x0, x1, r) {
    translate([x0, ay, az]) rotate([0, 90, 0]) cylinder(r = r, h = x1 - x0);
}

// blind holes in the body knuckles that the lid's pin turns in
module pin_holes() {
    along_axis(pin_cap, knuckle_w + e, pin_r + pip_clr);
    along_axis(W - knuckle_w - e, W - pin_cap, pin_r + pip_clr);
}

module lid_pin() { along_axis(pin_cap + pip_clr, W - pin_cap - pip_clr, pin_r); }

// everything on the phone side of its back face, grown by `off` toward the house
module phone_side(off = 0) {
    translate([-1, phone_by, wall]) rotate([lean, 0, 0]) translate([0, -off, -50]) cube([W + 2, 40, 200]);
}

// outer skin of the roof above z0, `t` thick, between planes parallel to the seam
module roof_skin(t, back, front, z0 = eave) {
    difference() {
        intersection() {
            prism(0, D) difference() { pent2d(); offset(delta = -t) pent2d(); }
            translate([-1, -1, z0]) cube([W + 2, D + 2, H]);
        }
        phone_side(-front);
        difference() { translate([-1, -1, -1]) cube([W + 2, D + 2, H + 2]); phone_side(back); }
    }
}

// ---------- body (back half + floor) ----------

// cut from the shell to leave the body: everything in front of the seam, the
// front wall, the floor in front of the hinge, and the recess under the lid's
// overlapping roof edge
module body_cuts() {
    union() {
        phone_side(0);
        translate([lid_x0 - clr, D - wall - gap, -2]) cube([lid_x1 - lid_x0 + 2 * clr, 5, H]);
        translate([wall, floor_end, -2]) cube([W - 2 * wall, D, floor_t + 2 + e]);
        roof_skin(recess, overlap + gap, 1);
    }
}

// thickens the body roof inward under the overlap so the recess isn't paper-thin
module roof_underlay() {
    difference() {
        intersection() {
            prism(0, D) difference() { offset(delta = -recess) pent2d(); offset(delta = -recess - under_t) pent2d(); }
            translate([-1, -1, eave]) cube([W + 2, D + 2, H]);
            phone_side(overlap + gap + 1);
        }
        phone_side(0);
    }
}

module snap_bumps(r = bump_r) {
    // a ridge runs along the seam edge; bump_pos is linear along each slope, so the hull is straight.
    // Centred on the lid edge's underside (fit above the body's roof), so it reaches snap into the body.
    for (s = [-1, 1]) hull() for (d = [-snap_ridge / 2, snap_ridge / 2])
        translate(bump_pos(W / 2 + s * (bump_dx + d)) + fit * [s * sin(roof_a), 0, cos(roof_a)]) sphere(r = r, $fn = 24);
}

module body_knuckles() {
    for (x = [[0, knuckle_w], [W - knuckle_w, W]]) {
        along_axis(x[0], x[1], hinge_r);
        translate([x[0], floor_end - 1, 0]) cube([x[1] - x[0], ay - floor_end + 1, az]);    }
}

// through-window with a cross muntin: ws square, bottom at wz, cut along X
win_z = 6; win_s = 4;
module window_cut() {
    m = 0.8;
    difference() {
        cube([wall + 2, win_s, win_s]);
        translate([0, win_s / 2 - m / 2, 0]) cube([wall + 2, m, win_s]);
        translate([0, 0, win_s / 2 - m / 2]) cube([wall + 2, win_s, m]);
    }
}

module side_window(x) {  // centered on the closed house
    for (f = [0 : floors - 1]) translate([x - 1, D / 2 - win_s / 2, win_z + f * floor_h]) window_cut();
}

module body() {
    intersection() { envelope(); body_raw(); }
}

module body_raw() {
    difference() {
        union() {
            difference() { shell(); body_cuts(); }
            body_knuckles();
            roof_underlay();
        }
        pin_holes();
        snap_bumps(bump_r + 0.1);  // pockets in the roof under the lid's edge, for its ridges
        if (details) { side_window(0); side_window(W - wall); back_details(); }
    }
}

// door and windows on the back wall, which is the house's face when closed;
// windows go through and match the side windows, the door is debossed
module back_details() {
    translate([W / 2 - 2.5, 0.5 - 1, floor_t]) cube([5, 1, 10]);            // door
    for (f = [0 : floors - 1], x = concat([2.8, W - 2.8 - win_s], f > 0 ? [W / 2 - win_s / 2] : []))  // windows (one more over the door)
        translate([x + win_s, -1, win_z + f * floor_h]) rotate([0, 0, 90]) window_cut();
}

// ---------- lid (front half) ----------

// lid: everything in front of the seam (above the body knuckles), the front wall,
// and the overlapping roof edge
module lid_region() {
    intersection() { phone_side(-gap); translate([-1, -1, lid_z0]) cube([W + 2, D + 2, H]); }
    translate([lid_x0, D - wall - e, lid_z0]) cube([lid_x1 - lid_x0, wall + 1, H]);
    translate([mid_x0, D - wall - e, az]) cube([mid_x1 - mid_x0, wall + 1, H]);
    roof_skin(lip_t, overlap, gap + 1, eave + gap / 2);  // starts just above the eave so the phone clears it
}

// the knuckle overlaps the front wall, which runs down to the axis in this span
module lid_knuckle() {
    along_axis(mid_x0, mid_x1, hinge_r);
    // open stop: the knuckle's front-bottom corner squared off, so the house's bottom is flat.
    // Folded open, that corner is behind and under the axis, and past flat its flat face
    // (the bottom, when closed) runs head-on into the end of the body's floor.
    if (open_stop) translate([mid_x0, ay, 0]) cube([mid_x1 - mid_x0, hinge_r, az]);
}

// chimney on the lid's roof, flush with the lid's front face (which lies on the
// bed when printing). Its straight back face may reach back over the lid's
// overlapping roof edge, which is lid too. The keyring hole runs sideways (X)
// through the top, so the ring loops over the top when closed and lies flat past
// the end of the lid when the lid is folded open.
chim_x1 = 23.4;                                  // outer (low) side of the chimney
chim_w = 5;
chim_x0 = chim_x1 - chim_w;
chim_d = max(4, keyring_d + 2 * chim_rim);       // front-to-back depth
chim_y0 = D - chim_d;
assert(chim_y0 >= seam_y(H - (chim_x1 - W / 2) * roof_k) - (overlap - 0.5) / cos(lean),
       "keyring_d too big: the chimney would reach past the lid's overlapping roof edge");
// hole clears the roof on the chimney's uphill side, where the ring passes
chim_top = max(H - 0.2, H - max(0, chim_x0 - W / 2) * roof_k + keyring_d + chim_rim + chim_cap);
keyring_z = chim_top - chim_cap - keyring_d / 2;
if (chim_top > H) echo(str("chimney top ", chim_top, " mm is above the roof peak"));
module chimney() {
    difference() {
        translate([chim_x0, chim_y0, eave]) chamfered_box([chim_w, D - chim_y0, chim_top - eave], chamfer);
        // only above the roof (the lid roof is under it); fills the roof's front chamfer below it
        envelope(e);
        translate([chim_x0 - 1, D - chim_d / 2, keyring_z]) rotate([0, 90, 0]) cylinder(d = keyring_d, h = chim_w + 2);
    }
}

// hotel: rib across the inside of the lid's front wall. It stands up once the lid
// is open, just past the front of a phone_t phone. Square face toward the phone.
module lip_rib() {
    hull() {
        translate([lid_x0, D - wall - e, rib_z]) cube([lid_x1 - lid_x0, e, rib_base]);
        translate([lid_x0, D - wall - lip_h, rib_z]) cube([lid_x1 - lid_x0, e, lip_w]);
    }
}

module lid() {
    intersection() {
        envelope();
        union() { intersection() { shell(); lid_region(); } lid_knuckle(); lid_pin(); if (rib) lip_rib(); }
    }
    chimney();
    snap_bumps();  // ridges under the overlapping edge
}

// lid folded flat forward, rotated about the hinge axis
module lid_open() { translate([0, ay, az]) rotate([-90, 0, 0]) translate([0, -ay, -az]) children(); }

// ---------- phone ghost ----------

module phone_ghost(t = phone_t) {
    %translate([-20, phone_by, wall]) rotate([lean, 0, 0]) cube([W + 40, t, max(70, 2 * H)]);
    // the stop is the lid's roof edge at the eave (overlap included), once folded open
    // (hotel: the rib)
    lip_y = ay + ((rib ? rib_z : eave + gap / 2) - az);
    lip_top = rib ? wall + lip_h : az + ay - (seam_y(eave) - overlap / cos(lean));
    echo(str("lean ", lean, " deg; phone front corner y=", phone_by + t * cos(lean), " z=", wall + t * sin(lean),
             "; lip at y=", lip_y, " top z=", lip_top));
}

// ---------- output ----------

if (part == "closed") { body(); lid(); }
else if (part == "open") {
    body();
    color("tomato") lid_open() lid();
    if (show_phone) phone_ghost();
}
else if (part == "body") body();
else if (part == "lid") lid_open() lid();
else if (part == "print") { body(); lid_open() lid(); }  // one piece, lid folded open
