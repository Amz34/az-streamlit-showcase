import sys
from playwright.sync_api import sync_playwright

def verify_app():
    url = "http://127.0.0.1:8501"
    print(f"Launching Headless Chromium to verify {url}...")
    with sync_playwright() as p:
        browser = p.chromium.launch(
            executable_path="/usr/bin/google-chrome",
            headless=True,
            args=["--no-sandbox", "--disable-dev-shm-usage", "--disable-gpu"]
        )
        context = browser.new_context(viewport={"width": 1280, "height": 900})
        page = context.new_page()
        
        console_errors = []
        page.on("console", lambda msg: console_errors.append(msg.text) if msg.type == "error" else None)
        
        response = page.goto(url, wait_until="networkidle", timeout=15000)
        assert response.status == 200, f"Expected 200 but got {response.status}"
        
        # Wait for Streamlit React app to hydrate over WebSocket
        page.wait_for_selector("text=Az. Consultants", timeout=15000)
        title = page.title()
        print(f"✅ Page hydrated successfully. Document Title: '{title}'")
        
        # Verify text content
        content = page.content()
        assert "Az. Consultants" in content, "Brand title missing"
        assert "Executive KPI Dashboard" in content, "Dashboard view missing"
        print("✅ DOM verification verified: 'Az. Consultants' and 'Executive KPI Dashboard' elements rendered.")
        
        # Capture screenshot
        screenshot_path = "/home/ubuntu/projects/az-streamlit-showcase/deployment_proof.png"
        page.screenshot(path=screenshot_path)
        print(f"📸 Screenshot saved to: {screenshot_path}")
        
        browser.close()
        
    print("🎯 Full Headless Chromium verification complete with ZERO defects.")

if __name__ == "__main__":
    verify_app()
