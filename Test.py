# ...existing code...
"""
py -m pip install selenium pandas beautifulsoup4 lxml webdriver-manager
"""
import time
from selenium import webdriver
from selenium.webdriver.edge.options import Options  # Changed import
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from datetime import datetime
import pandas as pd  # added to save CSV

OUTPUT_CSV = "warranty_results.csv"  # new output filename

def setup_driver():
    edge_options = Options()
    edge_options.add_argument("--headless")
    edge_options.add_argument("--disable-gpu")
    edge_options.add_argument("--no-sandbox")
    driver = webdriver.Edge(options=edge_options)  # Changed to Edge
    return driver

def parse_date_to_au_format(date_str):
    try:
        date_obj = datetime.strptime(date_str, "%B %d, %Y")
        return date_obj.strftime("%d/%m/%Y")
    except ValueError:
        return date_str

def check_warranty_date(serial_number, driver):
    try:
        driver.get("https://support.hp.com/au-en/check-warranty")
        wait = WebDriverWait(driver, 10)
        print(f"Entering serial number: {serial_number}")
        serial_input = wait.until(EC.presence_of_element_located((By.ID, "inputtextpfinder")))
        serial_input.clear()
        serial_input.send_keys(serial_number)
        print(f"Clicking submit button")
        submit_button = driver.find_element(By.ID, "FindMyProduct")
        # Try to close notification overlays if present
        try:
            overlay = driver.find_element(By.CLASS_NAME, "notifications-main")
            driver.execute_script("arguments[0].style.display = 'none';", overlay)
        except:
            pass
        # Try normal click, fallback to JS click if intercepted
        try:
            submit_button.click()
        except Exception as click_error:
            print("Standard click failed, trying JavaScript click due to overlay.")
            driver.execute_script("arguments[0].click();", submit_button)
        wait.until(EC.presence_of_element_located((By.ID, "warrantyStatus")))
        try:
            print(f"Looking for end date")
            warranty_end_element = driver.find_element(
                By.XPATH, 
                "//*[contains(text(), 'End date') or contains(text(), 'end date') or contains(text(), 'Expiry') or contains(text(), 'expiration')]/following-sibling::*"
            )
            warranty_end = warranty_end_element.text.strip()
            if not warranty_end:
                warranty_end = "Not found (empty)"
            else:
                warranty_end = parse_date_to_au_format(warranty_end)
        except:
            print(f"End date not found, inspecting page")
            try:
                no_warranty = driver.find_element(By.XPATH, "//*[contains(text(), 'No warranty')]")
                warranty_end = "No warranty found"
            except:
                warranty_end = "Not found"
        return {
            "serial_number": serial_number,
            "warranty_expiry": warranty_end
        }
    except Exception as e:
        print(f"Error processing {serial_number}: {str(e)}")
        return {
            "serial_number": serial_number,
            "warranty_expiry": "Not Found"
        }

def process_serial_numbers(serial_numbers):
    driver = setup_driver()
    results = []
    try:
        for serial in serial_numbers:
            if serial.strip():
                print(f"Checking serial number: {serial}")
                result = check_warranty_date(serial.strip(), driver)
                results.append(result)
                time.sleep(2)
        print("\nWarranty Results:")
        for res in results:
            print(f"Serial: {res['serial_number']} | Expiry: {res['warranty_expiry']}")
        # Save results to CSV (enhancement; doesn't change existing logic)
        try:
            df = pd.DataFrame(results)
            # normalize column names for clarity
            if 'serial_number' in df.columns:
                df = df.rename(columns={'serial_number': 'serial'})
            if 'warranty_expiry' not in df.columns:
                df['warranty_expiry'] = ""
            df.to_csv(OUTPUT_CSV, index=False)
            print(f"Saved results to {OUTPUT_CSV}")
        except Exception as e:
            print(f"Failed to save CSV: {e}")
    finally:
        driver.quit()

if __name__ == "__main__":
    serial_numbers = [
        "5CG1320LMC",  # Example serial numbers
        "5CG1320LMC"
    ]
    process_serial_numbers(serial_numbers)
# ...existing code...