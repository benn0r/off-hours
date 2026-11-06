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
SCREENSHOTS = ROOT / "screenshots/appstore"

# language: (header title, header line, search title, search lines)
TEXT = {
    "en": (
        "Clock out.\nFor real.",
        "Work apps off after hours, back on when you're on call.",
        "Work apps off\nafter hours.",
        "Back on when you're on call.\nBlocked on days off.",
    ),
    "fr": (
        "Fini le boulot.\nVraiment.",
        "Apps pro coupées après le travail, actives pendant l'astreinte.",
        "Apps pro coupées\naprès le travail.",
        "Actives pendant l'astreinte.\nBloquées pendant les congés.",
    ),
    "it": (
        "Fine lavoro.\nDavvero.",
        "App di lavoro spente fuori orario, attive quando sei reperibile.",
        "App di lavoro\nspente fuori orario.",
        "Attive quando sei reperibile.\nBloccate nei giorni liberi.",
    ),
    "es": (
        "Fin de la jornada.\nDe verdad.",
        "Apps de trabajo apagadas fuera de horario, activas si estás de guardia.",
        "Apps de trabajo\napagadas al salir.",
        "Activas si estás de guardia.\nBloqueadas en días libres.",
    ),
    "de": (
        "Feierabend.\nWirklich.",
        "Arbeits-Apps aus nach Feierabend, wieder an bei Bereitschaft.",
        "Arbeits-Apps aus\nnach Feierabend.",
        "Wieder an bei Bereitschaft.\nGesperrt an freien Tagen.",
    ),
    "pt-PT": (
        "Fim do trabalho.\nA sério.",
        "Apps de trabalho desligadas fora do horário, ativas quando está de prevenção.",
        "Apps de trabalho\ndesligadas à noite.",
        "Ativas quando está de prevenção.\nBloqueadas nas folgas.",
    ),
    "pt-BR": (
        "Fim do expediente.\nDe verdade.",
        "Apps de trabalho desligados fora do expediente, ativos no plantão.",
        "Apps de trabalho\ndesligados à noite.",
        "Ativos quando você está de plantão.\nBloqueados nas folgas.",
    ),
    "nl": (
        "Klaar met werk.\nEcht.",
        "Werk-apps uit na werktijd, weer aan als je piket hebt.",
        "Werk-apps uit\nna werktijd.",
        "Weer aan als je piket hebt.\nGeblokkeerd op vrije dagen.",
    ),
}
WHITE = (255, 255, 255, 255)
SOFT = (255, 255, 255, 215)


def font(size: int, weight: str = "Bold") -> ImageFont.FreeTypeFont:
    f = ImageFont.truetype(FONT, size)
    try:
        f.set_variation_by_name(weight)
    except Exception:
        pass
    return f


def fitted(content: str, size: int, max_width: int, weight: str = "Bold") -> ImageFont.FreeTypeFont:
    """The largest font up to `size` whose widest line fits in `max_width`."""
    probe = ImageDraw.Draw(Image.new("RGBA", (1, 1)))
    while size > 10:
        f = font(size, weight)
        if probe.multiline_textbbox((0, 0), content, font=f)[2] <= max_width:
            return f
        size -= 2
    return font(size, weight)


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


def header(language: str, out: Path) -> None:
    title, line, _, _ = TEXT[language]
    canvas = Image.open(HERE / "source/header-bg.png").convert("RGBA")
    canvas = canvas.crop((0, 0, 3840, 1646))
    icon_size = 300
    icon = rounded(Image.open(ICON).resize((icon_size, icon_size), Image.LANCZOS), 68)
    x, y = 420, 470
    shadow(canvas, (x, y + 20, x + icon_size, y + icon_size + 20), 68, 40, 140)
    canvas.alpha_composite(icon, (x, y))
    text(canvas, (x + icon_size + 70, y + 20), title, fitted(title, 150, 1500), WHITE, spacing=10)
    text(canvas, (x, y + icon_size + 120), line, fitted(line, 72, 2200, "Medium"), SOFT)
    canvas.convert("RGB").save(out / "header-3840x1646.png", optimize=True)


def search_results(language: str, out: Path) -> None:
    _, _, title, lines = TEXT[language]
    shot = SCREENSHOTS / ("home.png" if language == "en" else f"{language}/home.png")
    canvas = Image.open(HERE / "source/search-bg.png").convert("RGBA")
    device = phone(Image.open(shot), 1080)
    dx = canvas.width - device.width - 170
    dy = (canvas.height - device.height) // 2 + 30
    shadow(canvas, (dx + 10, dy + 40, dx + device.width - 10, dy + device.height + 20), 90, 50, 170)
    canvas.alpha_composite(device, (dx, dy))
    x = 140
    icon = rounded(Image.open(ICON).resize((150, 150), Image.LANCZOS), 34)
    shadow(canvas, (x, 330, x + 150, 490), 34, 24, 120)
    canvas.alpha_composite(icon, (x, 320))
    text(canvas, (x, 530), title, fitted(title, 108, 1020), WHITE, spacing=8)
    text(canvas, (x, 820), lines, fitted(lines, 52, 1020, "Medium"), SOFT, spacing=14)
    canvas.convert("RGB").save(out / "search-results-1920x1280.png", optimize=True)


if __name__ == "__main__":
    for language in TEXT:
        out = HERE if language == "en" else HERE / language
        out.mkdir(exist_ok=True)
        header(language, out)
        search_results(language, out)
        print(out)
