import requests
import os
from pathlib import Path

BASE_URL = "http://localhost:2283/api"
ADMIN_TEST_EMAIL = "test@gmail.com"
ADMIN_PASSWORD = "test1234"
API_KEY_NAME = "test-api-key"

def create_admin_user():
    payload = {
        "email": ADMIN_TEST_EMAIL,
        "password": ADMIN_PASSWORD,
        "name": "test admin"
    }

    response = requests.post(f"{BASE_URL}/auth/admin-sign-up", json=payload)
    assert response.status_code == 201, f"Failed to create admin: {response.status_code} - {response.text}"
    print(f"Admin user successfully created: {ADMIN_TEST_EMAIL}")
    return response.json()

def login_admin():
    payload = {
        "email": ADMIN_TEST_EMAIL,
        "password": ADMIN_PASSWORD
    }

    response = requests.post(f"{BASE_URL}/auth/login", json=payload)
    assert response.status_code in [200, 201], f"Failed to login: {response.status_code} - {response.text}"
    
    access_token = response.json()["accessToken"]
    assert access_token, "Access token is empty"
    print("Login successful")
    return access_token

def create_api_ley(access_token):
    headers = {"Authorization": f"Bearer {access_token}"}
    payload = {
        "name": API_KEY_NAME,
        "permissions": ["all"]
    }

    response = requests.post(f"{BASE_URL}/api-keys", headers=headers, json=payload)
    assert response.status_code == 201, f"Failed to create API key: {response.status_code} - {response.text}"

    api_key = response.json()["secret"]
    assert api_key, "API key secret is empty"
    print(f"API key created: {API_KEY_NAME}")
    return api_key

def save_api_key(api_key):
    script_dir = Path(__file__).parent
    token_file = script_dir / "api_token.txt"

    with open(token_file, "w") as file:
        file.write(api_key)

    assert token_file.exists(), "Failed to create api_token.txt"

    

def test_main():
    admin_data = create_admin_user()
        
    access_token = login_admin()

    api_key = create_api_ley(access_token)

    save_api_key(api_key)

