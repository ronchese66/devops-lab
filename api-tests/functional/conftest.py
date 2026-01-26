import os
import pytest
from helpers.api_client import APIClient

API_KEY_ENV = "IMMICH_API_KEY"

@pytest.fixture(scope="session")
def api_key():
    api_key = os.getenv(API_KEY_ENV)
    if not api_key:
        raise RuntimeError(f"ENV {API_KEY_ENV} not set or invalid")
    return api_key

@pytest.fixture(scope="session")
def base_url():
    return "http://localhost:2283/api"

@pytest.fixture(scope="session")
def api(base_url, api_key):
    return APIClient(base_url, api_key)

