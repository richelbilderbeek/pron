"""Check that the game runs in a browser and that both players can steer."""
import io
import sys
import time

from PIL import Image
from playwright.sync_api import sync_playwright

URL = "http://localhost:8000/pron.html"
WIDTH = 960
HEIGHT = 600
RED = (255, 128, 128)
BLUE = (128, 128, 255)


def pixels_of(img, color):
    """Get the (x, y) of all pixels that have (about) the color."""
    data = img.load()
    return [
        (x, y)
        for y in range(HEIGHT)
        for x in range(WIDTH)
        if all(abs(a - b) < 16 for a, b in zip(data[x, y], color))
    ]


with sync_playwright() as p:
    browser = p.chromium.launch()
    # The same size as the iframe on the website
    page = browser.new_page(viewport={"width": WIDTH, "height": HEIGHT})
    errors = []
    page.on("pageerror", lambda e: errors.append(str(e)))
    page.goto(URL)
    page.wait_for_function("window.Processing && Processing.instances.length > 0")
    page.mouse.click(WIDTH // 2, 50)
    # Red starts going right, 'a' turns it left: it goes up.
    # Blue starts going left, arrow left turns it left: it goes down.
    page.keyboard.press("a")
    page.keyboard.press("ArrowLeft")
    time.sleep(1)
    png = page.screenshot()
    browser.close()

if errors:
    sys.exit(f"Page errors: {errors}")

img = Image.open(io.BytesIO(png)).convert("RGB")
red = pixels_of(img, RED)
blue = pixels_of(img, BLUE)
if not red or not blue:
    sys.exit("The game is not running: cannot find both players")
# Ignore the scores at the top
if min(y for x, y in red if y > 40) > HEIGHT // 2 - 30:
    sys.exit("Pressing 'a' did not make the red player turn up")
if max(y for x, y in blue) < HEIGHT // 2 + 30:
    sys.exit("Pressing arrow left did not make the blue player turn down")
print("OK")
