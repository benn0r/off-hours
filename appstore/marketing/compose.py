"""Composes the App Store header and search-results assets.

Backgrounds in source/ were generated with OpenAI gpt-image-2 (see README in this folder);
text and the phone screenshot are drawn here so they stay crisp and show the real app.
Run with a Python that has Pillow:  python compose.py
"""

from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

HERE = Path(__file__).parent
ROOT = HERE.parent.parent
FONT = "/System/Library/Fonts/SFNS.ttf"
ICON = ROOT / "OffHours/Assets.xcassets/AppIcon.appiconset/AppIcon.png"
SCREENSHOT = ROOT / "screenshots/appstore/home.png"
WHITE = (255, 255, 255, 255)
SOFT = (255, 255, 255, 215)


def font(size: int, weight: str = "Bold") -> ImageFont.FreeTypeFont:
    f = ImageFont.truetype(FONT, size)
    try:
        f.set_variation_by_name(weight)
    except Exception:
        pass
    return f


def rounded(image: Image.Image, radius: int) -> Image.Image:
    mask = Image.new("L", image.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, *image.size), radius, fill=255)
    out = image.convert("RGBA")
    out.putalpha(mask)
    return out


def shadow(canvas: Image.Image, box: tuple[int, int, int, int], radius: int, blur: int, alpha: int) -> None:
    layer = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    ImageDraw.Draw(layer).rounded_rectangle(box, radius, fill=(10, 6, 40, alpha))
    canvas.alpha_composite(layer.filter(ImageFilter.GaussianBlur(blur)))


def text(canvas: Image.Image, xy, content: str, f, fill, spacing: int = 0) -> None:
    layer = Image.new("RGBA", canvas.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)
    draw.multiline_text((xy[0], xy[1] + 4), content, font=f, fill=(20, 10, 60, 90), spacing=spacing)
    canvas.alpha_composite(layer.filter(ImageFilter.GaussianBlur(6)))
    ImageDraw.Draw(canvas).multiline_text(xy, content, font=f, fill=fill, spacing=spacing)


def phone(screenshot: Image.Image, height: int) -> Image.Image:
    """A simple black-bezel phone around a real screenshot."""
    shot = screenshot.resize((round(screenshot.width * height / screenshot.height), height), Image.LANCZOS)
    bezel = round(height * 0.022)
    radius = round(height * 0.085)
    body = Image.new("RGBA", (shot.width + 2 * bezel, shot.height + 2 * bezel), (0, 0, 0, 0))
    ImageDraw.Draw(body).rounded_rectangle((0, 0, *body.size), radius, fill=(18, 18, 22, 255))
    body.alpha_composite(rounded(shot, radius - bezel), (bezel, bezel))
    return body


def header() -> None:
    canvas = Image.open(HERE / "source/header-bg.png").convert("RGBA")
    canvas = canvas.crop((0, 0, 3840, 1646))
    icon_size = 300
    icon = rounded(Image.open(ICON).resize((icon_size, icon_size), Image.LANCZOS), 68)
    x, y = 420, 470
    shadow(canvas, (x, y + 20, x + icon_size, y + icon_size + 20), 68, 40, 140)
    canvas.alpha_composite(icon, (x, y))
    text(canvas, (x + icon_size + 70, y + 20), "Clock out.\nFor real.", font(150), WHITE, spacing=10)
    text(
        canvas,
        (x, y + icon_size + 120),
        "Work apps off after hours, back on when you're on call.",
        font(72, "Medium"),
        SOFT,
    )
    canvas.convert("RGB").save(HERE / "header-3840x1646.png", optimize=True)


def search_results() -> None:
    canvas = Image.open(HERE / "source/search-bg.png").convert("RGBA")
    device = phone(Image.open(SCREENSHOT), 1080)
    dx = canvas.width - device.width - 170
    dy = (canvas.height - device.height) // 2 + 30
    shadow(canvas, (dx + 10, dy + 40, dx + device.width - 10, dy + device.height + 20), 90, 50, 170)
    canvas.alpha_composite(device, (dx, dy))
    x = 140
    icon = rounded(Image.open(ICON).resize((150, 150), Image.LANCZOS), 34)
    shadow(canvas, (x, 330, x + 150, 490), 34, 24, 120)
    canvas.alpha_composite(icon, (x, 320))
    text(canvas, (x, 530), "Work apps off\nafter hours.", font(108), WHITE, spacing=8)
    text(canvas, (x, 820), "Back on when you're on call.\nBlocked on days off.", font(52, "Medium"), SOFT, spacing=14)
    canvas.convert("RGB").save(HERE / "search-results-1920x1280.png", optimize=True)


if __name__ == "__main__":
    header()
    search_results()
    print("ok")
