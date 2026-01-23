import os
import pytest
import schemathesis
from schemathesis.checks import not_a_server_error

OPENAPI_FILE = "openapi.json"
API_KEY_ENV = "IMMICH_API_KEY"
API_KEY_HEADER = "x-api-key"

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
def headers(api_key):
    return {
        API_KEY_HEADER: api_key
    }

def schema(path_regex):
    return schemathesis.openapi.from_path(OPENAPI_FILE).include(path_regex=path_regex)

def custom_checks(ctx, response, case):
    allowed_4xx = {400, 401, 403, 422}
    if response.status_code in allowed_4xx:
        return True
    return not_a_server_error(ctx, response, case)





