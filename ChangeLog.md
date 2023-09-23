# GameGUI Change Log

# v1.3 (September 23, 2023)
Aspect-Fit and Aspect-Fill sizing modes can now be mixed and matched, with e.g. one dimension using Fit and the other using Fill.

There are four possible aspect-mode combinations:

Horizontal Mode | Vertical Mode | Effect
----------------|---------------|-------
Aspect-Fit      | Aspect-Fit    | Component maintains the specified aspect ratio and is sized as large as possible while still fitting in the available area.
Aspect-Fill     | Aspect-Fill   | Component maintains the specified aspect ratio and is sized as small as possible while still completely filling the available area.
Aspect-Fill     | Aspect-Fit    | Component occupies all available width while maintaining the specified aspect ratio.
Aspect-Fit      | Aspect-Fill   | Component occupies all available height while maintaining the specified aspect ratio.

# v1.2 (September 9, 2023)

## GGOverlay supports scale > 1.0

H&V Scale Constants can now be manually set to values > 1.0.

## GGHBox and GGVBox Content Alignment <font color=red>[breaking change]</font>

GGHBox and GGVBox now have a **Content Alignment** property which specifies how the content as a whole is aligned
if it is larger than or smaller than the size of the box. For GGHBox the options are **Left**, **Center**, and **Right**.
For GGVBox the options are **Top**, **Center**, and **Bottom**.

This is a breaking change because the default for both is **Center** whereas the previous layout behavior matched
a default of **Left** for GGHBox or **Top** for GGVBox. If an existing GameGUI project has misaligned elements
after the update then there are GGHBox and GGVBox components that need their Content Alignment to be set to Left or Top.

# v1.1 (September 5, 2023)

## GGHBox and GGVBox more robust

More robust layout of Shrink-to-Fit children.

- OLD:
    - Shrink-to-Fit children counted as fixed size for layout purposes.
    - Assumption was that STF children had fixed-size children.

- NEW
    - STF children given their maximum size during layout.
    - STF children may base their size on the available space given to STF, which in turn affects STF final size.
    - STF child sizes no longer prematurely assumed.

# v1.0.1 (September 3, 2023)
- Original release.
