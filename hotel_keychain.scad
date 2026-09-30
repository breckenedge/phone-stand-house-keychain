// Hotel Keychain Phone Stand
// The house's tall sibling: 1" x 2.5" x 0.75". Same hinge and roof snap, but the
// whole front wall folds down into a 2.5" base. The phone's bottom edge sits out
// on that base against a rib and leans on the roof ridge, 2.5" up.
// Everything is modelled in house_keychain.scad; this file only sets the hotel's
// values (the ones here win over the house's defaults).

include <house_keychain.scad>

part = "open"; // [closed, open, print, body, lid]
H = 63.5;           // height to roof peak (2.5")
phone_lean = 20;    // degrees
floors = 4;
details = true;     // keeps its door and windows (the house has none by default)
