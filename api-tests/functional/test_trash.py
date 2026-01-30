from helpers.validators import check_response_has_id
from pathlib import Path
from datetime import datetime
import uuid


test_image_path = Path(__file__).parent / "testImage.jpg"


def get_asset_data(prefix="test"):
    return {
        "deviceAssetId": f"{prefix}-{uuid.uuid4()}",
        "deviceId": "test-device-001",
        "fileCreatedAt": datetime.now().isoformat(),
        "fileModifiedAt": datetime.now().isoformat()
    }


class TestTrashOperations:
    
    def test_restore_specific_assets(self, api):
        with open(test_image_path, "rb") as image_file:
            files = {"assetData": ("testImage.jpg", image_file, "image/jpeg")}
            data = get_asset_data("test-trash-restore")
            upload_response = api.post("/assets", files=files, data=data)
        
        assert upload_response.status_code in [200, 201]
        asset_id = check_response_has_id(upload_response.json())
        
        delete_payload = {"ids": [asset_id]}
        delete_response = api.delete("/assets", json=delete_payload)
        assert delete_response.status_code == 204
        
        restore_payload = {"ids": [asset_id]}
        response = api.post("/trash/restore/assets", json=restore_payload)
        
        assert response.status_code == 200
        assert "count" in response.json()
        assert response.json()["count"] == 1
        
        verify_response = api.get(f"/assets/{asset_id}")
        assert verify_response.status_code == 200
    
    def test_restore_all_trash(self, api):
        with open(test_image_path, "rb") as image_file:
            files = {"assetData": ("testImage.jpg", image_file, "image/jpeg")}
            data = get_asset_data("test-restore-all-1")
            upload1 = api.post("/assets", files=files, data=data)
        
        assert upload1.status_code in [200, 201]
        asset_id1 = check_response_has_id(upload1.json())
        
        with open(test_image_path, "rb") as image_file:
            files = {"assetData": ("testImage.jpg", image_file, "image/jpeg")}
            data = get_asset_data("test-restore-all-2")
            upload2 = api.post("/assets", files=files, data=data)
        
        assert upload2.status_code in [200, 201]
        asset_id2 = check_response_has_id(upload2.json())
        
        delete_payload = {"ids": [asset_id1, asset_id2]}
        delete_response = api.delete("/assets", json=delete_payload)
        assert delete_response.status_code == 204
        
        response = api.post("/trash/restore")
        
        assert response.status_code == 200
        assert "count" in response.json()
        assert response.json()["count"] >= 1
    
    def test_empty_trash(self, api):
        with open(test_image_path, "rb") as image_file:
            files = {"assetData": ("testImage.jpg", image_file, "image/jpeg")}
            data = get_asset_data("test-empty-trash")
            upload_response = api.post("/assets", files=files, data=data)
        
        assert upload_response.status_code in [200, 201]
        asset_id = check_response_has_id(upload_response.json())
        
        delete_payload = {"ids": [asset_id]}
        delete_response = api.delete("/assets", json=delete_payload)
        assert delete_response.status_code == 204
        
        response = api.post("/trash/empty")
        
        assert response.status_code == 200
        assert "count" in response.json()
        assert isinstance(response.json()["count"], int)
