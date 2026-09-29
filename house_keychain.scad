// House Keychain Phone Stand
// A 1" x 1" x 0.75" house. The front half folds down on a hinge and becomes a
// phone stand: the phone's bottom edge sits on the open lid just past the hinge,
// leans on the roof ridge, and the lid's roof edge is the lip in front.
// A flexible latch arm up in the roof peak snaps the lid shut.
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

/* [Hinge] */
hinge_r = 2.2;      // knuckle radius
pin_r = 1.0;        // print-in-place pin radius
pip_clr = 0.3;      // pin-to-hole and knuckle-to-knuckle gap; raise if it prints fused
clr = 0.3;          // moving clearance elsewhere
gap = 0.25;         // seam between body and lid
knuckle_w = 6;      // width of each outer (body) knuckle

/* [Split] */
roof_split = 13.0;  // body roof ends here (phone leans on this ridge edge)
eave = 13.5;        // wall height; also sets how far out the phone lip sits

/* [Snap latch] */
snap = 0.3;         // how far the latch bump overlaps the catch; more = firmer
arm_t = 0.9;        // flexing latch arm thickness; thinner = easier to open
catch_t = 2.5;      // rigid catch block thickness on the lid
latch_y = 9.5;      // bump position
latch_z = 19.2;

/* [Phone] */
phone_t = 9;        // phone thickness incl. case (ghost preview only)

/* [Features] */
keyring_d = 2.2;

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
phone_by = ay + hinge_r + 0.5;
lean = atan((phone_by - roof_split) / (H - wall));
// latch: a flexing arm on the body (printed upright, so it bends along its layers)
// snaps its bump into a dimple in a rigid catch block on the lid
arm_x1 = W / 2;                      // arm's +x face, where the bump sits
catch_x0 = arm_x1 + clr;
latch_bot = latch_z - 1.7;
latch_top = latch_z + 1.1;
bump_r = clr + snap;

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

// extrude a profile in the YZ plane between x0 and x1
module yz_prism(x0, x1) { translate([x0, 0, 0]) rotate([90, 0, 90]) linear_extrude(x1 - x0) children(); }

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

// the part of the side walls that must move with the lid so the phone clears them
module side_wedges() {
    intersection() {
        phone_side(0.2 - gap);
        union() for (x = [-1, lid_x1]) translate([x, 0, lid_z0]) cube([lid_x0 + 1, D + 1, eave + gap - lid_z0]);
    }
}

// ---------- body (back half + floor) ----------

// body keeps the back roof, full-depth side walls and the floor up to the hinge
module body_region() {
    translate([-1, -1, -1]) cube([W + 2, roof_split - gap / 2 + 1, H + 2]);
    difference() {
        translate([-1, -1, -1]) cube([W + 2, D + 2, eave - gap / 2 + 1]);
        translate([lid_x0 - clr, D - wall - gap, -2]) cube([lid_x1 - lid_x0 + 2 * clr, 5, H]);
        translate([wall, floor_end, -2]) cube([W - 2 * wall, D, floor_t + 2 + e]);
        phone_side(0.2);
    }
}

module body_knuckles() {
    for (x = [[0, knuckle_w], [W - knuckle_w, W]]) {
        along_axis(x[0], x[1], hinge_r);
        translate([x[0], floor_end - 1, 0]) cube([x[1] - x[0], ay - floor_end + 1, az]);
    }
}

// Latch arm: cantilevered forward from the back wall only (clear of the roof),
// deep at the root and tapering to the bump. Its underside slopes at 45 degrees
// so it prints without support.
module latch_arm() {
    tip_y = latch_y + 1.2;
    yz_prism(arm_x1 - arm_t, arm_x1)
        polygon([[wall - e, latch_bot - (tip_y - wall)], [tip_y, latch_bot],
                 [tip_y, latch_top], [wall - e, latch_top]]);
    translate([arm_x1, latch_y, latch_z]) sphere(r = bump_r, $fn = 24);
}

module chimney() {
    difference() {
        translate([17.5, 0, 14]) cube([5, 4.5, 24.2 - 14]);
        prism(wall, D) inner2d();
        translate([20, -1, 22.2]) rotate([-90, 0, 0]) cylinder(d = keyring_d, h = 7);
    }
}

module side_window(x) {
    // through-window with a cross muntin
    wy = 5; wz = 6; ws = 4; m = 0.8;
    translate([x - 1, wy, wz]) difference() {
        cube([wall + 2, ws, ws]);
        translate([0, ws / 2 - m / 2, 0]) cube([wall + 2, m, ws]);
        translate([0, 0, ws / 2 - m / 2]) cube([wall + 2, ws, m]);
    }
}

module body() {
    difference() {
        union() {
            intersection() { shell(); body_region(); }
            body_knuckles();
            latch_arm();
            chimney();
        }
        pin_holes();
        side_window(0);
        side_window(W - wall);
    }
}

// ---------- lid (front half) ----------

module lid_region() {
    translate([-1, roof_split + gap / 2, eave + gap / 2]) cube([W + 2, D, H]);
    translate([lid_x0, D - wall - e, lid_z0]) cube([lid_x1 - lid_x0, wall + 1, H]);
    translate([mid_x0, D - wall - e, az]) cube([mid_x1 - mid_x0, wall + 1, H]);
    side_wedges();
}

// the knuckle overlaps the front wall, which runs down to the axis in this span
module lid_knuckle() { along_axis(mid_x0, mid_x1, hinge_r); }

// rigid block from the inside of the front wall, with the dimple the arm's bump
// snaps into (with_dimple = false fills it, for interference checks)
module latch_catch(with_dimple = true) {
    difference() {
        intersection() {
            translate([catch_x0, latch_y - 1.2, latch_bot]) cube([catch_t, D - wall - latch_y + 1.2 + e, latch_top - latch_bot]);
            prism(0, D) offset(delta = -1.5) inner2d();  // clears the body roof as it swings
        }
        if (with_dimple) translate([catch_x0, latch_y, latch_z]) sphere(r = bump_r + 0.1, $fn = 24);
    }
}

module front_details() {
    d = 0.5;  // deboss depth
    translate([0, D - d, 0]) {
        translate([W / 2 - 2.5, 0, lid_z0 + 0.3]) cube([5, 1, 7.5]);          // door
        for (x = [2.6, W - 2.6 - 4.2]) translate([x, 0, 7]) difference() {  // windows
            cube([4.2, 1, 3.8]);
            translate([2.1 - 0.35, -1, 0]) cube([0.7, 3, 3.8]);
            translate([0, -1, 1.9 - 0.35]) cube([4.2, 3, 0.7]);
        }
    }
    translate([W / 2, D - d, eave + 4.2]) rotate([-90, 0, 0]) cylinder(r = 1.8, h = 1); // attic window
}

module lid(with_dimple = true) {
    difference() {
        union() {
            intersection() { shell(); lid_region(); }
            lid_knuckle();
            lid_pin();
            latch_catch(with_dimple);
        }
        front_details();
    }
}

// lid folded flat forward, rotated about the hinge axis
module lid_open() { translate([0, ay, az]) rotate([-90, 0, 0]) translate([0, -ay, -az]) children(); }

// ---------- phone ghost ----------

module phone_ghost(t = phone_t) {
    %translate([-20, phone_by, wall]) rotate([lean, 0, 0]) cube([W + 40, t, 70]);
    lip_y = ay + (eave + gap / 2 - az);
    echo(str("lean ", lean, " deg; phone front corner y=", phone_by + t * cos(lean), " z=", wall + t * sin(lean),
             "; lip at y=", lip_y, " top z=", az + ay - roof_split - gap / 2));
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
