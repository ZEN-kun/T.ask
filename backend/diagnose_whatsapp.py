import sys
from pathlib import Path
import httpx
from dotenv import dotenv_values

if sys.platform == "win32":
    sys.stdout.reconfigure(encoding="utf-8")

env_path = Path(__file__).parent / ".env"
env = dotenv_values(str(env_path))
token = env.get("WHATSAPP_ACCESS_TOKEN", "").strip()
phone_id = env.get("WHATSAPP_PHONE_NUMBER_ID", "").strip()
verify_token = env.get("WHATSAPP_VERIFY_TOKEN", "").strip()

print("=" * 65)
print("🔍 T.ask WhatsApp Cloud API Diagnostics")
print("=" * 65)

print(f"1. Phone Number ID: {phone_id}")
print(f"2. Token Configured: {token[:15]}...{token[-10:] if token else ''}")

# Step 1: Query phone number details from Meta
print("\n[Step 1] Querying Meta Phone Account...")
try:
    r = httpx.get(
        f"https://graph.facebook.com/v20.0/{phone_id}",
        headers={"Authorization": f"Bearer {token}"},
        timeout=10.0,
    )
    if r.status_code == 200:
        data = r.json()
        print(f"  ✅ Account Active: '{data.get('verified_name')}'")
        print(f"  📱 Meta Test Number: {data.get('display_phone_number')}")
        print(f"  🌐 Meta Registered Webhook: {data.get('webhook_configuration', {}).get('application')}")
    else:
        print(f"  ❌ Meta Error ({r.status_code}): {r.text}")
except Exception as e:
    print(f"  ❌ Network Exception: {e}")

# Step 2: Test sending pre-approved Template to target phone
test_phone = "917981929830"
print(f"\n[Step 2] Sending Official Meta Template ('hello_world') to +{test_phone}...")
try:
    r_tmpl = httpx.post(
        f"https://graph.facebook.com/v20.0/{phone_id}/messages",
        headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"},
        json={
            "messaging_product": "whatsapp",
            "to": test_phone,
            "type": "template",
            "template": {"name": "hello_world", "language": {"code": "en_US"}},
        },
        timeout=10.0,
    )
    print(f"  HTTP Status: {r_tmpl.status_code}")
    print(f"  Response: {r_tmpl.text}")
except Exception as e:
    print(f"  ❌ Template Exception: {e}")

# Step 3: Test sending T.ask Custom Task Message
print(f"\n[Step 3] Sending Custom T.ask Task Notification to +{test_phone}...")
try:
    r_msg = httpx.post(
        f"https://graph.facebook.com/v20.0/{phone_id}/messages",
        headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"},
        json={
            "messaging_product": "whatsapp",
            "to": test_phone,
            "type": "text",
            "text": {
                "body": "*T.ask*\n_What are your task?_\n\n📋 *New Task Assigned*\n*Task:* Live Test Item\n*Task ID:* 999\n\nTo mark completed, reply:\n`DONE 999`"
            },
        },
        timeout=10.0,
    )
    print(f"  HTTP Status: {r_msg.status_code}")
    print(f"  Response: {r_msg.text}")
except Exception as e:
    print(f"  ❌ Message Exception: {e}")

print("\n" + "=" * 65)
