#!/usr/bin/env python3
"""Generate notepadGTX icon - a unique notepad-style icon with GTX branding"""

from PIL import Image, ImageDraw

def create_notepadgtx_icon(size=256):
    """Create a notepad icon with GTX styling"""
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    # Scale factor for different sizes
    s = size / 256

    # Colors - GTX theme (green/teal accent on dark notepad)
    pad_color = (45, 52, 64)           # Dark slate for notepad body
    pad_highlight = (59, 66, 82)       # Lighter edge
    binding_color = (136, 192, 208)    # Teal/cyan for binding rings
    paper_color = (236, 239, 244)      # Off-white paper
    line_color = (180, 190, 200)       # Faint lines on paper
    accent_color = (163, 190, 140)     # Green accent (GTX brand)
    text_color = (76, 86, 106)         # Dark gray for "text"

    # Main notepad body (rounded rectangle) - slightly tilted appearance
    pad_left = int(30 * s)
    pad_top = int(20 * s)
    pad_right = int(226 * s)
    pad_bottom = int(240 * s)
    corner = int(12 * s)

    # Shadow
    shadow_offset = int(4 * s)
    draw.rounded_rectangle(
        [pad_left + shadow_offset, pad_top + shadow_offset,
         pad_right + shadow_offset, pad_bottom + shadow_offset],
        radius=corner,
        fill=(0, 0, 0, 80)
    )

    # Main pad body
    draw.rounded_rectangle(
        [pad_left, pad_top, pad_right, pad_bottom],
        radius=corner,
        fill=pad_color
    )

    # Highlight edge (top-left)
    draw.rounded_rectangle(
        [pad_left, pad_top, pad_right - int(4*s), pad_bottom - int(4*s)],
        radius=corner,
        fill=pad_highlight
    )

    # Inner darker area
    draw.rounded_rectangle(
        [pad_left + int(4*s), pad_top + int(4*s), pad_right - int(4*s), pad_bottom - int(4*s)],
        radius=corner - int(2*s),
        fill=pad_color
    )

    # Paper area (white rectangle inside)
    paper_left = int(50 * s)
    paper_top = int(45 * s)
    paper_right = int(210 * s)
    paper_bottom = int(220 * s)

    draw.rounded_rectangle(
        [paper_left, paper_top, paper_right, paper_bottom],
        radius=int(4 * s),
        fill=paper_color
    )

    # Lines on paper
    line_start = int(65 * s)
    line_spacing = int(18 * s)
    for i in range(9):
        y = line_start + i * line_spacing
        if y < paper_bottom - int(10 * s):
            draw.line(
                [(paper_left + int(10*s), y), (paper_right - int(10*s), y)],
                fill=line_color,
                width=max(1, int(1 * s))
            )

    # "Text" lines (simulated text on some lines)
    text_lines = [
        (0, 0.8),   # line index, width fraction
        (1, 0.6),
        (2, 0.9),
        (3, 0.4),
        (5, 0.7),
        (6, 0.5),
    ]
    for line_idx, width_frac in text_lines:
        y = line_start + line_idx * line_spacing - int(8 * s)
        x_start = paper_left + int(12 * s)
        x_end = x_start + int((paper_right - paper_left - 24*s) * width_frac)
        draw.rounded_rectangle(
            [x_start, y, x_end, y + int(6*s)],
            radius=int(2*s),
            fill=text_color
        )

    # Binding rings on top (spiral binding look)
    ring_y = int(32 * s)
    ring_radius = int(8 * s)
    ring_positions = [70, 110, 150, 190]
    for rx in ring_positions:
        cx = int(rx * s)
        # Ring hole
        draw.ellipse(
            [cx - ring_radius, ring_y - ring_radius,
             cx + ring_radius, ring_y + ring_radius],
            fill=binding_color,
            outline=(100, 150, 170),
            width=max(1, int(2 * s))
        )
        # Inner hole
        inner_r = int(4 * s)
        draw.ellipse(
            [cx - inner_r, ring_y - inner_r,
             cx + inner_r, ring_y + inner_r],
            fill=pad_color
        )

    # GTX accent - green stripe/tab on the side
    tab_width = int(12 * s)
    tab_height = int(50 * s)
    tab_top = int(80 * s)
    draw.rounded_rectangle(
        [pad_right - int(3*s), tab_top, pad_right + tab_width, tab_top + tab_height],
        radius=int(4 * s),
        fill=accent_color
    )

    # Small "GTX" indicator - three small bars
    bar_x = pad_right + int(1 * s)
    bar_width = int(8 * s)
    bar_height = int(8 * s)
    bar_gap = int(12 * s)
    for i in range(3):
        bar_y = tab_top + int(8*s) + i * bar_gap
        draw.rounded_rectangle(
            [bar_x, bar_y, bar_x + bar_width, bar_y + bar_height],
            radius=int(2*s),
            fill=(255, 255, 255, 200)
        )

    # Pencil/cursor accent in corner
    pencil_tip_x = int(195 * s)
    pencil_tip_y = int(205 * s)
    pencil_size = int(25 * s)

    # Pencil body (angled)
    pencil_points = [
        (pencil_tip_x, pencil_tip_y),  # tip
        (pencil_tip_x - int(6*s), pencil_tip_y - int(10*s)),  # left
        (pencil_tip_x + pencil_size - int(6*s), pencil_tip_y - pencil_size - int(10*s)),  # top left
        (pencil_tip_x + pencil_size + int(6*s), pencil_tip_y - pencil_size + int(2*s)),  # top right
        (pencil_tip_x + int(6*s), pencil_tip_y - int(2*s)),  # right
    ]
    draw.polygon(pencil_points, fill=accent_color)

    # Pencil tip (darker)
    tip_points = [
        (pencil_tip_x, pencil_tip_y),
        (pencil_tip_x - int(4*s), pencil_tip_y - int(8*s)),
        (pencil_tip_x + int(4*s), pencil_tip_y - int(6*s)),
    ]
    draw.polygon(tip_points, fill=(80, 100, 70))

    return img

def main():
    # Create icons at different sizes
    sizes = [256, 128, 64, 48, 32, 16]
    images = []

    for size in sizes:
        img = create_notepadgtx_icon(size)
        images.append(img)
        # Save PNG version of largest
        if size == 256:
            img.save('assets/icon.png', 'PNG')
            print(f'Created assets/icon.png ({size}x{size})')

    # Save as ICO (Windows) with multiple sizes
    images[0].save(
        'assets/icon.ico',
        format='ICO',
        sizes=[(img.width, img.height) for img in images]
    )
    print(f'Created assets/icon.ico (multi-size)')

    # Also save 512x512 for Linux
    img_512 = create_notepadgtx_icon(512)
    img_512.save('assets/icon-512.png', 'PNG')
    print('Created assets/icon-512.png (512x512)')

if __name__ == '__main__':
    main()
