import uuid
from pathlib import Path
from datetime import datetime
from helpers.validators import check_response_has_id

test_image_path = Path(__file__).parent / "testImage.jpg"

def get_asset_data(prefix="test"):
    return {
        "deviceAssetId": f"{prefix}-{uuid.uuid4()}",
        "deviceId": "test-device-001",
        "fileCreatedAt": datetime.now().isoformat(),
        "fileModifiedAt": datetime.now().isoformat()
    }

class TestAssetCRUD:
    def test_upload_asset(self, api):
        with open(test_image_path, "rb") as image_file:
            files = {"assetData": ("testImage.jpg", image_file, "image/jpeg")}
            data = get_asset_data("test-upload")
            response = api.post("/assets", files=files, data=data)

        assert response.status_code in [200, 201]
        check_response_has_id(response.json())

    def test_get_asset_info(self, api):
        with open(test_image_path, "rb") as image_file:
            files = {"assetData": ("testImage.jpg", image_file, "image/jpeg")}
            data = get_asset_data("test-get")
            upload_response = api.post("/assets", files=files, data=data)

        assert upload_response.status_code in [200, 201]
        asset_id = check_response_has_id(upload_response.json())

        response = api.get(f"/assets/{asset_id}")
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == asset_id
        assert "checksum" in data
        assert "originalFileName" in data
        assert data["type"] == "IMAGE"

    def test_update_asset(self, api):
        with open(test_image_path, "rb") as image_file:
            files = {"assetData": ("testImage.jpg", image_file, "image/jpeg")}
            data = get_asset_data("test-update")
            upload_response = api.post("/assets", files=files, data=data)

        assert upload_response.status_code in [200, 201]
        asset_id = check_response_has_id(upload_response.json())

        payload = {
            "description": "updates description",
            "isFavorite": True,
            "rating": 5
        }
        response = api.put(f"/assets/{asset_id}", json=payload)
        get_response = api.get(f"/assets/{asset_id}")

        
        assert response.status_code == 200
        assert get_response.json()["exifInfo"]["description"] == payload["description"]
        assert get_response.json()["exifInfo"]["rating"] == payload["rating"]
        assert response.json()["isFavorite"] == payload["isFavorite"]

    def test_delete_asset(self, api):
        with open(test_image_path, "rb") as image_file:
            files = {"assetData": ("testImage.jpg", image_file, "image/jpeg")}
            data = get_asset_data("test-delete")
            upload_response = api.post("/assets", files=files, data=data)

        assert upload_response.status_code in [200, 201]
        asset_id = check_response_has_id(upload_response.json())

        payload = {"ids": [asset_id]}
        response = api.delete("/assets", json=payload)
        assert response.status_code == 204


class TestAssetDownload:
    
    def test_download_asset_thumbnail(self, api):
        with open(test_image_path, "rb") as image_file:
            files = {"assetData": ("testImage.jpg", image_file, "image/jpeg")}
            data = get_asset_data("test-thumb")
            upload_response = api.post("/assets", files=files, data=data)
        
        assert upload_response.status_code in [200, 201]
        asset_id = check_response_has_id(upload_response.json())
        
        response = api.get(f"/assets/{asset_id}/thumbnail")
        
        assert response.status_code == 200
        assert response.headers["Content-Type"] in ["image/jpeg", "image/webp", "image/png"]
        assert len(response.content) > 0

    def test_download_original_asset(self, api):
        with open(test_image_path, "rb") as image_file:
            original_content = image_file.read()
        
        with open(test_image_path, "rb") as image_file:
            files = {"assetData": ("testImage.jpg", image_file, "image/jpeg")}
            data = get_asset_data("test-download")
            upload_response = api.post("/assets", files=files, data=data)
        
        assert upload_response.status_code in [200, 201]
        asset_id = check_response_has_id(upload_response.json())
        
        response = api.get(f"/assets/{asset_id}/original")
        
        assert response.status_code == 200
        assert response.headers["Content-Type"] == "image/jpeg"
        assert len(response.content) > 0
        assert response.content == original_content


class TestAssetLifecycle:
    
    def test_full_asset_lifecycle(self, api):
        with open(test_image_path, "rb") as image_file:
            files = {"assetData": ("testImage.jpg", image_file, "image/jpeg")}
            data = get_asset_data("test-lifecycle")
            upload_response = api.post("/assets", files=files, data=data)
        
        assert upload_response.status_code in [200, 201]
        asset_id = check_response_has_id(upload_response.json())
        
        get_response = api.get(f"/assets/{asset_id}")
        assert get_response.status_code == 200
        assert get_response.json()["id"] == asset_id
        
        update_payload = {
            "description": "lifecycle test asset",
            "isFavorite": True,
        }
        update_response = api.put(f"/assets/{asset_id}", json=update_payload)
        assert update_response.status_code == 200
        
        verify_response = api.get(f"/assets/{asset_id}")
        assert verify_response.status_code == 200
        assert verify_response.json()["exifInfo"]["description"] == "lifecycle test asset"
        assert verify_response.json()["isFavorite"] == True
        
        thumb_response = api.get(f"/assets/{asset_id}/thumbnail")
        assert thumb_response.status_code == 200
        assert len(thumb_response.content) > 0
        
        original_response = api.get(f"/assets/{asset_id}/original")
        assert original_response.status_code == 200
        assert len(original_response.content) > 0
        
        delete_payload = {"ids": [asset_id]}
        delete_response = api.delete("/assets", json=delete_payload)
        assert delete_response.status_code == 204


class TestAssetMetadata:

    def test_get_asset_metadata(self, api):
        with open(test_image_path, "rb") as image_file:
            files = {"assetData": ("testImage.jpg", image_file, "image/jpeg")}
            data = get_asset_data("test-metadata")
            upload_response = api.post("/assets", files=files, data=data)

        assert upload_response.status_code in [200, 201]
        asset_id = check_response_has_id(upload_response.json())
        
        response = api.get(f"/assets/{asset_id}/metadata")
        assert response.status_code == 200
        assert isinstance(response.json(), list)

