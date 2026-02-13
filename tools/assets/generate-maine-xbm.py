#!/usr/bin/env python3
"""
Generate a Maine state silhouette as an XBM bitmap for Meshtastic boot splash.

Output:
  - firmware/meshtastic/assets/maine-logo.xbm  (60x50 monochrome XBM)
  - firmware/meshtastic/assets/maine-logo-preview.pbm (portable bitmap preview)
  - firmware/meshtastic/assets/maine-logo-preview.png (if Pillow available)

The XBM uses LSB-first bit ordering (bit 0 = leftmost pixel).
1 = foreground (drawn), 0 = background.

Usage:
  python3 tools/assets/generate-maine-xbm.py

Requires only Python 3 standard library. Pillow is optional (for PNG preview).
"""

import os
import sys

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------
WIDTH = 60
HEIGHT = 50
XBM_NAME = "maine_logo"

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
REPO_ROOT = os.path.abspath(os.path.join(SCRIPT_DIR, "..", ".."))
ASSET_DIR = os.path.join(REPO_ROOT, "firmware", "meshtastic", "assets")

XBM_PATH = os.path.join(ASSET_DIR, "maine-logo.xbm")
PBM_PATH = os.path.join(ASSET_DIR, "maine-logo-preview.pbm")
PNG_PATH = os.path.join(ASSET_DIR, "maine-logo-preview.png")

# ---------------------------------------------------------------------------
# Maine state outline coordinates (clockwise from SW corner)
#
# Coordinate system: (0,0) = top-left, x increases right, y increases down.
# The polygon is designed for a 60x50 pixel canvas.
#
# Geographic reference (approximate):
#   - Western border: straight NH border
#   - Northern border: Quebec/New Brunswick, with Aroostook County bump
#   - Eastern coast: jagged with bays (Penobscot, Casco, etc.)
#   - Southern coast: short Atlantic coast (Kittery to Portland)
# ---------------------------------------------------------------------------
MAINE_OUTLINE = [
    # SW corner - Kittery area (southern tip of Maine)
    # Maine is oriented: narrow at south, wider at north, tall state
    # Western border (NH) is on the left, coast on the right
    # The state leans NE - Aroostook County extends far north-northeast
    #
    # NOTE: At 60x50 pixels, each pixel ~= 5-6 miles. We exaggerate
    # coastal features slightly so they read at this resolution.

    # ---- Southern coast (Kittery heading east to Portland) ----
    (13, 47),   # Kittery - SW tip
    (16, 48),   # York
    (19, 48),   # Wells/Kennebunk
    (22, 47),   # Old Orchard Beach / Saco
    (25, 46),   # Portland area

    # ---- Midcoast heading NE (Casco Bay to Penobscot Bay) ----
    (27, 45),   # Cape Elizabeth / Freeport
    (29, 44),   # Brunswick area
    (30, 43),   # Bath
    (32, 42),   # Wiscasset
    (34, 42),   # Boothbay peninsula tip (bump out)
    (33, 41),   # back in from Boothbay
    (35, 40),   # Pemaquid peninsula (bump out)
    (33, 39),   # back in - Muscongus Bay
    (35, 38),   # east shore Muscongus
    (36, 37),   # Rockland / Thomaston
    (37, 36),   # Owls Head

    # ---- Penobscot Bay (major indentation) ----
    (36, 35),   # west shore Penobscot Bay
    (34, 34),   # deep into Penobscot Bay
    (36, 33),   # Castine/Islesboro
    (38, 33),   # eastern shore Penobscot
    (39, 32),   # Deer Isle / Stonington

    # ---- Blue Hill / Mount Desert / Acadia ----
    (38, 31),   # Blue Hill Bay indent
    (40, 30),   # MDI west approach
    (42, 30),   # Mount Desert Island - Acadia (big bump)
    (43, 29),   # MDI east / Bar Harbor
    (40, 28),   # Frenchman Bay indent
    (43, 27),   # Schoodic peninsula

    # ---- Downeast coast (Bold Coast) ----
    (41, 26),   # Milbridge
    (44, 25),   # Jonesport
    (45, 24),   # Machias
    (43, 23),   # Cutler indent
    (46, 22),   # Bold Coast bump
    (47, 21),   # Lubec approach

    # ---- Easternmost point (Quoddy Head) ----
    (49, 20),   # West Quoddy Head - easternmost US point
    (48, 19),   # Eastport
    (47, 18),   # Passamaquoddy Bay

    # ---- NB border heading north up St. Croix ----
    (46, 16),   # Calais
    (45, 14),   # St. Croix river border
    (44, 12),   # Vanceboro
    (43, 10),   # Orient/Danforth

    # ---- Aroostook County - northern Maine ----
    (43, 8),    # Houlton area
    (44, 6),    # Mars Hill
    (45, 5),    # Presque Isle / Caribou
    (47, 4),    # Van Buren
    (48, 3),    # Madawaska - northernmost populated

    # ---- Northern border (St. John River, heading west) ----
    (46, 2),    # Fort Kent
    (43, 2),    # Allagash
    (40, 2),    # St. Francis
    (37, 3),    # heading west along border
    (34, 4),    # NW Maine highlands
    (31, 5),    # near Moosehead

    # ---- NW corner (Quebec border angles SW) ----
    (28, 6),    # near Jackman
    (25, 7),    # border continues SW
    (22, 8),    # Coburn Gore area
    (20, 9),    # Chain of Ponds

    # ---- Western border (NH border - heading south) ----
    # This border runs roughly straight with a slight westward lean
    (18, 11),
    (17, 13),
    (16, 15),
    (15, 17),
    (14, 19),
    (14, 21),
    (13, 23),
    (13, 25),
    (12, 27),
    (12, 29),
    (12, 31),
    (11, 33),
    (11, 35),
    (11, 37),
    (11, 39),
    (12, 41),
    (12, 43),
    (13, 45),
    (13, 47),   # back to SW corner
]


# ---------------------------------------------------------------------------
# Scanline polygon fill algorithm (no external dependencies)
# ---------------------------------------------------------------------------
def fill_polygon(width, height, polygon):
    """
    Fill a polygon on a width x height grid using scanline algorithm.
    Returns a list of lists (rows of pixel values, 0 or 1).
    """
    grid = [[0] * width for _ in range(height)]
    n = len(polygon)

    for y in range(height):
        # Find all x-intersections of scanline y+0.5 with polygon edges
        intersections = []
        for i in range(n):
            x0, y0 = polygon[i]
            x1, y1 = polygon[(i + 1) % n]

            # Check if this edge crosses the scanline at y + 0.5
            scan_y = y + 0.5
            if (y0 <= scan_y < y1) or (y1 <= scan_y < y0):
                # Linear interpolation to find x at the intersection
                if y1 != y0:
                    x_intersect = x0 + (scan_y - y0) * (x1 - x0) / (y1 - y0)
                    intersections.append(x_intersect)

        # Sort intersections and fill between pairs
        intersections.sort()
        for j in range(0, len(intersections) - 1, 2):
            x_start = int(intersections[j])
            x_end = int(intersections[j + 1])
            # Clamp to grid
            x_start = max(0, x_start)
            x_end = min(width - 1, x_end)
            for x in range(x_start, x_end + 1):
                grid[y][x] = 1

    return grid


# ---------------------------------------------------------------------------
# Draw the outline on top of fill (ensures clean edges)
# ---------------------------------------------------------------------------
def draw_outline(grid, polygon, width, height):
    """Draw polygon edges using Bresenham's line algorithm."""
    n = len(polygon)
    for i in range(n):
        x0, y0 = polygon[i]
        x1, y1 = polygon[(i + 1) % n]
        draw_line(grid, x0, y0, x1, y1, width, height)


def draw_line(grid, x0, y0, x1, y1, width, height):
    """Bresenham's line algorithm."""
    dx = abs(x1 - x0)
    dy = abs(y1 - y0)
    sx = 1 if x0 < x1 else -1
    sy = 1 if y0 < y1 else -1
    err = dx - dy

    while True:
        if 0 <= x0 < width and 0 <= y0 < height:
            grid[y0][x0] = 1
        if x0 == x1 and y0 == y1:
            break
        e2 = 2 * err
        if e2 > -dy:
            err -= dy
            x0 += sx
        if e2 < dx:
            err += dx
            y0 += sy


# ---------------------------------------------------------------------------
# XBM output
# ---------------------------------------------------------------------------
def grid_to_xbm(grid, width, height, name):
    """Convert a pixel grid to XBM format string."""
    bytes_per_row = (width + 7) // 8
    xbm_bytes = []

    for y in range(height):
        for byte_idx in range(bytes_per_row):
            byte_val = 0
            for bit in range(8):
                x = byte_idx * 8 + bit
                if x < width and grid[y][x]:
                    byte_val |= (1 << bit)  # LSB = leftmost pixel
            xbm_bytes.append(byte_val)

    # Format as C array
    lines = []
    lines.append(f"#define {name}_width {width}")
    lines.append(f"#define {name}_height {height}")
    lines.append(f"static unsigned char {name}_bits[] = {{")

    hex_values = [f"0x{b:02x}" for b in xbm_bytes]
    # 12 values per line for readability
    for i in range(0, len(hex_values), 12):
        chunk = hex_values[i:i + 12]
        line = "   " + ", ".join(chunk)
        if i + 12 < len(hex_values):
            line += ","
        lines.append(line)

    lines.append("};")
    return "\n".join(lines) + "\n"


# ---------------------------------------------------------------------------
# PBM output (portable bitmap - no dependencies needed)
# ---------------------------------------------------------------------------
def grid_to_pbm(grid, width, height):
    """Convert pixel grid to PBM (P1 ASCII) format."""
    lines = ["P1", f"{width} {height}"]
    for y in range(height):
        row = " ".join(str(grid[y][x]) for x in range(width))
        lines.append(row)
    return "\n".join(lines) + "\n"


# ---------------------------------------------------------------------------
# PNG output (optional, requires Pillow)
# ---------------------------------------------------------------------------
def grid_to_png(grid, width, height, path, scale=4):
    """Save grid as scaled PNG using Pillow (optional)."""
    try:
        from PIL import Image
    except ImportError:
        print(f"  Pillow not available, skipping PNG preview: {path}")
        return False

    img = Image.new("1", (width * scale, height * scale), 0)
    pixels = img.load()
    for y in range(height):
        for x in range(width):
            if grid[y][x]:
                for sy in range(scale):
                    for sx in range(scale):
                        pixels[x * scale + sx, y * scale + sy] = 1
    img.save(path)
    return True


# ---------------------------------------------------------------------------
# ASCII art preview (always works)
# ---------------------------------------------------------------------------
def grid_to_ascii(grid, width, height):
    """Render grid as ASCII art for terminal preview."""
    lines = []
    for y in range(height):
        row = ""
        for x in range(width):
            row += "##" if grid[y][x] else "  "
        lines.append(row)
    return "\n".join(lines)


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
def main():
    os.makedirs(ASSET_DIR, exist_ok=True)

    print(f"Generating Maine state silhouette ({WIDTH}x{HEIGHT} pixels)...")

    # Generate the filled silhouette
    grid = fill_polygon(WIDTH, HEIGHT, MAINE_OUTLINE)
    draw_outline(grid, MAINE_OUTLINE, WIDTH, HEIGHT)

    # Count filled pixels
    filled = sum(sum(row) for row in grid)
    total = WIDTH * HEIGHT
    print(f"  Filled pixels: {filled}/{total} ({100*filled/total:.1f}%)")

    # Write XBM
    xbm_data = grid_to_xbm(grid, WIDTH, HEIGHT, XBM_NAME)
    with open(XBM_PATH, "w") as f:
        f.write(xbm_data)
    print(f"  XBM written: {XBM_PATH}")

    # Write PBM preview
    pbm_data = grid_to_pbm(grid, WIDTH, HEIGHT)
    with open(PBM_PATH, "w") as f:
        f.write(pbm_data)
    print(f"  PBM preview: {PBM_PATH}")

    # Try PNG preview
    grid_to_png(grid, WIDTH, HEIGHT, PNG_PATH)

    # ASCII preview
    print("\nASCII Preview:")
    print(grid_to_ascii(grid, WIDTH, HEIGHT))

    print(f"\nDone. XBM file ready for Meshtastic firmware at:")
    print(f"  {XBM_PATH}")


if __name__ == "__main__":
    main()
