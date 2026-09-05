from playwright.sync_api import sync_playwright
import time

def verify():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(record_video_dir=".")
        page = context.new_page()

        print("Navigating to http://localhost:8000")
        page.goto("http://localhost:8000")
        time.sleep(2)

        # Take a screenshot
        page.screenshot(path="screenshot.png")
        print("Screenshot saved to screenshot.png")

        # Verify ARIA labels exist
        print("Checking for aria-labels...")
        home_btn = page.locator('button[aria-label="Navigate Home"]')
        print(f"Navigate Home button found: {home_btn.count() > 0}")

        context.close()
        browser.close()

if __name__ == "__main__":
    verify()
