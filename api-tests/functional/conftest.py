import pytest
from pathlib import Path
from helpers.api_client import APIClient

API_KEY_ENV = "IMMICH_API_KEY"

@pytest.fixture(scope="session")
def api_key():
    token_file = Path(__file__).parent / "api_token.txt"
    if not token_file.exists():
        raise RuntimeError(f"File {token_file} not found. Run init-admin-user.py first")
    
    api_key = token_file.read_text().strip()

    if not api_key:
        raise RuntimeError(f"File {token_file} is empty")
    return api_key

@pytest.fixture(scope="session")
def base_url():
    return "http://host.docker.internal:2283/api"

@pytest.fixture(scope="session")
def api(base_url, api_key):
    return APIClient(base_url, api_key)

