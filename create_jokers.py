from PIL import Image, ImageDraw, ImageFont
import os, math, random

OUT = "assets/jokers"
os.makedirs(OUT, exist_ok=True)

SIZE = 512

def save(img, name):
    img.save(os.path.join(OUT, name), "PNG")

def font(size):
    try:
        return ImageFont.truetype("arial.ttf", size)
    except:
        return ImageFont.load_default()

def base(bg1, bg2, border):
    img = Image.new("RGBA", (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)

    d.ellipse((42, 55, 478, 490), fill=(0, 0, 0, 60))
    d.ellipse((34, 34, 478, 478), fill=bg2)
    d.ellipse((56, 52, 454, 448), fill=bg1)
    d.ellipse((88, 82, 185, 175), fill=(255, 255, 255, 130))
    d.ellipse((42, 42, 470, 470), outline=(255, 255, 255, 240), width=18)
    d.ellipse((60, 60, 452, 452), outline=border, width=8)
    return img, d

def fish():
    img, d = base((30, 210, 235, 255), (0, 125, 210, 255), (0, 165, 205, 255))

    for y in [330, 360, 390]:
        pts = []
        for x in range(120, 395, 14):
            pts.append((x, y + int(12 * math.sin((x - 120) / 28))))
        d.line(pts, fill=(255, 255, 255, 150), width=12)

    d.ellipse((155, 180, 340, 285), fill=(30, 130, 210, 255), outline=(0, 70, 145, 255), width=8)
    d.polygon([(340, 230), (420, 175), (400, 235), (420, 295)], fill=(15, 100, 190, 255), outline=(0, 70, 145, 255))
    d.polygon([(210, 190), (260, 135), (275, 205)], fill=(50, 160, 230, 255), outline=(0, 80, 150, 255))
    d.polygon([(225, 278), (280, 335), (285, 260)], fill=(50, 160, 230, 255), outline=(0, 80, 150, 255))
    d.ellipse((185, 205, 212, 232), fill=(255, 255, 255, 255))
    d.ellipse((194, 213, 207, 226), fill=(0, 30, 60, 255))

    save(img, "fish.png")

def wheel():
    img, d = base((255, 62, 140, 255), (210, 0, 90, 255), (255, 120, 180, 255))
    cx, cy = 256, 256

    for r, c in [
        (130, (255, 255, 255, 255)),
        (108, (255, 30, 120, 255)),
        (80, (255, 255, 255, 255)),
        (55, (255, 70, 145, 255)),
        (25, (255, 255, 255, 255)),
    ]:
        d.ellipse((cx - r, cy - r, cx + r, cy + r), fill=c)

    d.line((245, 265, 360, 145), fill=(0, 95, 190, 255), width=18)
    d.polygon([(360, 145), (430, 120), (397, 186)], fill=(0, 160, 255, 255), outline=(255, 255, 255, 255))
    d.polygon([(342, 165), (370, 190), (335, 210)], fill=(255, 210, 40, 255), outline=(255, 255, 255, 255))

    save(img, "wheel.png")

def lollipop():
    img, d = base((255, 120, 205, 255), (255, 70, 175, 255), (255, 170, 230, 255))

    d.line((300, 300, 380, 410), fill=(245, 235, 205, 255), width=24)
    d.line((300, 300, 380, 410), fill=(170, 120, 60, 120), width=6)
    d.ellipse((115, 105, 335, 325), fill=(255, 255, 255, 255), outline=(255, 165, 235, 255), width=10)

    colors = [
        (255, 40, 150, 255),
        (255, 220, 35, 255),
        (40, 190, 255, 255),
        (155, 50, 255, 255),
    ]

    for i in range(16):
        r = 10 + i * 6
        start = i * 26
        d.arc((225 - r, 215 - r, 225 + r, 215 + r), start, start + 250, fill=colors[i % 4], width=14)

    save(img, "lollipop.png")

def hand():
    img, d = base((255, 110, 110, 255), (230, 50, 70, 255), (255, 160, 160, 255))
    red = (240, 45, 55, 255)
    dark = (170, 30, 40, 255)

    d.rounded_rectangle((175, 220, 335, 355), radius=55, fill=red, outline=dark, width=8)

    fingers = [
        (155, 150, 205, 270),
        (205, 115, 250, 265),
        (252, 128, 296, 270),
        (300, 160, 345, 285),
    ]

    for box in fingers:
        d.rounded_rectangle(box, radius=24, fill=red, outline=dark, width=6)
        d.ellipse((box[0] + 8, box[1] + 8, box[0] + 28, box[1] + 30), fill=(255, 255, 255, 70))

    d.rounded_rectangle((115, 230, 205, 285), radius=30, fill=red, outline=dark, width=7)

    save(img, "hand.png")

def color_bomb():
    img, d = base((150, 45, 190, 255), (85, 20, 140, 255), (190, 100, 230, 255))
    cx, cy = 256, 256

    d.ellipse((122, 122, 390, 390), fill=(42, 35, 50, 255), outline=(255, 255, 255, 235), width=10)

    random.seed(7)
    candy_colors = [
        (255, 40, 80, 255),
        (255, 210, 45, 255),
        (40, 200, 255, 255),
        (70, 225, 95, 255),
        (255, 120, 30, 255),
        (180, 65, 255, 255),
        (255, 255, 255, 255),
    ]

    for _ in range(54):
        ang = random.random() * math.tau
        rad = random.uniform(25, 120)
        x = cx + math.cos(ang) * rad
        y = cy + math.sin(ang) * rad
        r = random.randint(10, 18)
        col = random.choice(candy_colors)
        d.ellipse((x - r, y - r, x + r, y + r), fill=col, outline=(255, 255, 255, 170), width=2)

    save(img, "color_bomb.png")

def party():
    img, d = base((255, 220, 70, 255), (255, 180, 40, 255), (255, 245, 140, 255))

    d.polygon([(185, 350), (250, 150), (365, 310)], fill=(255, 95, 155, 255), outline=(255, 255, 255, 255))
    d.polygon([(250, 150), (270, 230), (210, 215)], fill=(70, 200, 255, 255))
    d.polygon([(270, 230), (305, 285), (225, 275)], fill=(255, 230, 55, 255))
    d.polygon([(305, 285), (365, 310), (185, 350)], fill=(155, 80, 255, 255))

    conf = [
        ((150, 140), (255, 60, 80)),
        ((335, 135), (0, 180, 240)),
        ((380, 190), (30, 210, 95)),
        ((130, 230), (255, 90, 210)),
        ((360, 360), (255, 255, 255)),
        ((115, 330), (255, 210, 40)),
    ]

    for (x, y), c in conf:
        d.rounded_rectangle((x - 10, y - 18, x + 10, y + 18), radius=5, fill=(*c, 255))

    for c, off in [
        ((255, 40, 120, 255), 0),
        ((40, 180, 255, 255), 30),
        ((70, 220, 90, 255), 60),
    ]:
        pts = []
        for t in range(0, 110, 8):
            x = 115 + t + off
            y = 120 + int(22 * math.sin(t / 15 + off))
            pts.append((x, y))
        d.line(pts, fill=c, width=8)

    f = font(55)
    d.text((350, 95), "✦", font=f, fill=(255, 255, 255, 230))
    d.text((105, 100), "✦", font=f, fill=(255, 255, 255, 200))

    save(img, "party.png")

fish()
wheel()
lollipop()
hand()
color_bomb()
party()

print("Joker PNG dosyaları oluşturuldu: assets/jokers/")