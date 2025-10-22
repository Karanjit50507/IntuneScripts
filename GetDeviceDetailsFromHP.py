import time
import re
from datetime import datetime
from selenium import webdriver
from selenium.webdriver.edge.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
import pandas as pd

OUTPUT_CSV = "product_details_results.csv"

def setup_driver(headless=True):
    options = Options()
    if headless:
        options.add_argument("--headless")
        options.add_argument("--disable-gpu")
        options.add_argument("--no-sandbox")
    driver = webdriver.Edge(options=options)
    return driver

def detect_ram_generation(text):
    text = (text or "").upper()
    match = re.search(r"\bDDR[345]\b", text)
    if match:
        return match.group(0)
    # check for generation words like "LPDDR4X", "LPDDR5"
    match2 = re.search(r"(LPDDR[45][A-Z]*)", text)
    if match2:
        return match2.group(1)
    return ""

def find_spec(driver, keys):
    # Try multiple strategies to find a spec value for any keyword in keys
    for key in keys:
        # 1) table row with label in first cell
        try:
            xpath = f"//table//tr[td[contains(normalize-space(string(.)), '{key}')]]/td[position()>1]"
            el = driver.find_element(By.XPATH, xpath)
            val = el.text.strip()
            if val:
                return val
        except:
            pass
        # 2) label text followed by sibling (common in HP pages)
        try:
            xpath = f"//*[contains(normalize-space(string(.)), '{key}')]/following-sibling::*[1]"
            el = driver.find_element(By.XPATH, xpath)
            val = el.text.strip()
            if val:
                return val
        except:
            pass
        # 3) any element that contains the key and the value separated by ':' in same element
        try:
            xpath = f"//*[contains(translate(., 'ABCDEFGHIJKLMNOPQRSTUVWXYZ', 'abcdefghijklmnopqrstuvwxyz'), '{key.lower()}') and contains(., ':')]"
            el = driver.find_element(By.XPATH, xpath)
            parts = el.text.split(":", 1)
            if len(parts) > 1:
                val = parts[1].strip()
                if val:
                    return val
        except:
            pass
    return ""

def get_product_details(serial_number, driver, timeout=12):
    try:
        driver.get("https://support.hp.com/au-en/check-warranty")
        wait = WebDriverWait(driver, timeout)
        serial_input = wait.until(EC.presence_of_element_located((By.ID, "inputtextpfinder")))
        serial_input.clear()
        serial_input.send_keys(serial_number)
        # try to dismiss overlays
        try:
            overlay = driver.find_element(By.CLASS_NAME, "notifications-main")
            driver.execute_script("arguments[0].style.display = 'none';", overlay)
        except:
            pass
        submit = driver.find_element(By.ID, "FindMyProduct")
        try:
            submit.click()
        except:
            driver.execute_script("arguments[0].click();", submit)
        # wait for warranty or product area to load
        wait.until(EC.presence_of_element_located((By.TAG_NAME, "body")))
        time.sleep(2)  # small wait to let dynamic content populate

        # Try to get product name (common ids/classes vary)
        product_name = ""
        try:
            # common product name selectors
            candidates = [
                "//h1[contains(@class,'product-name')]",
                "//*[@id='productHeader']//h1",
                "//h1"
            ]
            for xp in candidates:
                try:
                    el = driver.find_element(By.XPATH, xp)
                    text = el.text.strip()
                    if text:
                        product_name = text
                        break
                except:
                    continue
        except:
            product_name = ""

        # Try multiple keys for processor and memory
        processor = find_spec(driver, ["Processor", "CPU", "Processor type"])
        memory = find_spec(driver, ["Memory", "RAM", "Installed memory", "System memory"])

        ram_generation = detect_ram_generation(memory or processor)

        # As fallback, try to grab a specs block and search inside
        raw_specs = ""
        try:
            spec_el = driver.find_element(By.XPATH, "//*[contains(@class,'specs') or contains(@id,'specs') or contains(@class,'product-specs')]")
            raw_specs = spec_el.text.strip()
            if not processor:
                # search raw specs for processor lines
                m = re.search(r"(Processor[:\s]*.+)", raw_specs, re.IGNORECASE)
                if m:
                    processor = m.group(1).split(":",1)[-1].strip()
            if not memory:
                m2 = re.search(r"(Memory|RAM|Installed memory)[:\s]*([^\n\r]+)", raw_specs, re.IGNORECASE)
                if m2:
                    memory = m2.group(2).strip()
            if not ram_generation:
                ram_generation = detect_ram_generation(raw_specs)
        except:
            pass

        # final normalization
        processor = processor or "Not found"
        memory = memory or "Not found"
        product_name = product_name or "Not found"
        ram_generation = ram_generation or "Not detected"

        return {
            "serial": serial_number,
            "product_name": product_name,
            "processor": processor,
            "memory": memory,
            "ram_generation": ram_generation,
            "raw_specs_excerpt": (raw_specs[:500] + "...") if raw_specs else ""
        }
    except Exception as e:
        return {
            "serial": serial_number,
            "product_name": "Error",
            "processor": "Error",
            "memory": "Error",
            "ram_generation": "Error",
            "raw_specs_excerpt": str(e)
        }

def process_serials(serials):
    driver = setup_driver()
    results = []
    try:
        for s in serials:
            s = s.strip()
            if not s:
                continue
            print(f"Processing: {s}")
            res = get_product_details(s, driver)
            results.append(res)
            time.sleep(2)
        # save CSV
        try:
            df = pd.DataFrame(results)
            df.to_csv(OUTPUT_CSV, index=False)
            print(f"Saved {len(results)} rows to {OUTPUT_CSV}")
        except Exception as e:
            print(f"CSV save failed: {e}")
        # print summary
        for r in results:
            print(f"{r['serial']} | {r['product_name']} | {r['processor']} | {r['memory']} | {r['ram_generation']}")
    finally:
        driver.quit()

if __name__ == "__main__":
    test_serials = [
        "5CG1320LMC",
        "5CG1320LMC"
    ]
    process_serials(test_serials)