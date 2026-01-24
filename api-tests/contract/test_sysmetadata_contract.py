import pytest
from conftest import schema, custom_checks

users_schema = schema(r"^/system-metadata")

@pytest.mark.contract
@users_schema.parametrize()
def test_contract(case, base_url, headers):
    case.call_and_validate(
        base_url=base_url,
        headers=headers,
        checks=[custom_checks]
    )