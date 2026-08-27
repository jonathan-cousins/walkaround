from playwright.sync_api import sync_playwright
import time

with sync_playwright() as p:
    browser = p.chromium.launch()
    page = browser.new_page()
    page.goto('http://localhost:8000')

    html = page.content()

    if 'aria-label="Go back home"' in html:
        print("Success: aria-label='Go back home' found in HTML")
    else:
        print("Error: aria-label='Go back home' missing in HTML")

    page.evaluate("openInspectionHub('sample-1')")
    time.sleep(1)

    html = page.content()

    if 'aria-label="Take photo of' in html:
        print("Success: aria-label='Take photo of' found dynamically")
    else:
        print("Error: aria-label='Take photo of' missing dynamically")

    browser.close()
