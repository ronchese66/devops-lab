def check_response_has_id(data):
    assert "id" in data, f"'id' is missing in response: {data}"
    assert data["id"], f"field 'id' is empty"
    return data["id"]

def check_list_response(data, min_length=0):
    assert isinstance(data, list), f"Expected list, got {type(data)}: {data}"
    assert len(data) >= min_length, f"Expected at least {min_length}, got {len(data)}"