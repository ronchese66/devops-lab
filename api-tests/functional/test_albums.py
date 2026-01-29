from helpers.validators import check_list_response, check_response_has_id
from pathlib import Path
from datetime import datetime
import uuid

def create_asset_data(prefix="test"):
    return {
        "deviceAssetId": f"{prefix}-{uuid.uuid4()}",
        "deviceId": "test-device-001",
        "fileCreatedAt":  datetime.now().isoformat(),
        "fileModifiedAt": datetime.now().isoformat()
    }

class TestAlbumCRUD:

    def test_create_album(self, api):
        payload = {"albumName": "Test Album", "description": "test description"}

        response = api.post("/albums", json=payload)

        assert response.status_code == 201
        album_id = check_response_has_id(response.json())
        assert response.json()["albumName"] == payload["albumName"]
        assert response.json()["description"] == payload["description"]

    def test_get_all_albums(self, api):
        response = api.get("/albums")
        assert response.status_code == 200
        check_list_response(response.json())

    def test_get_album_by_id(self, api):
        payload = {"albumName": "album for GET test"}
        response = api.post("/albums", json=payload)
        album_id = check_response_has_id(response.json())
        get_response = api.get(f"/albums/{album_id}")

        assert get_response.status_code == 200
        assert get_response.json()["id"] == album_id
        assert get_response.json()["albumName"] == payload["albumName"]

    def test_update_album(self, api):
        payload = {"albumName": "original name"}
        response = api.post("/albums", json=payload)
        album_id = check_response_has_id(response.json())

        update_payload = {
            "albumName": "new name",
            "description": "add description"
        }

        update_response = api.patch(f"/albums/{album_id}", json=update_payload)

        assert update_response.status_code == 200
        assert update_response.json()["albumName"] == update_payload["albumName"]
        assert update_response.json()["description"] == update_payload["description"]

    def test_delete_album(self, api):
        payload = {"albumName": "album for delete"}
        response = api.post("/albums", json=payload)
        album_id = check_response_has_id(response.json())
        delete_response = api.delete(f"/albums/{album_id}")

        assert delete_response.status_code == 204


class TestAlbumAssets:
    def test_add_asset_to_album(self, api):
        test_image_path = Path(__file__).parent / "testImage.jpg"
        
        with open(test_image_path, "rb") as image_file:
            files = {"assetData": ("testImage.jpg", image_file, "image/jpeg")}
            data = create_asset_data("test-upload")
            upload_response = api.post("/assets", files=files, data=data)

        assert upload_response.status_code in [200, 201]
        asset_id = check_response_has_id(upload_response.json())

        create_response = api.post("/albums", json={"albumName": "album with asset 1"})
        album_id = check_response_has_id(create_response.json())

        payload = {"ids": [asset_id]}
        add_response = api.put(f"/albums/{album_id}/assets", json=payload)
        assert add_response.status_code == 200
        
        response_data = add_response.json()
        check_list_response(response_data)

        verify_response = api.get(f"/albums/{album_id}")
        assert verify_response.status_code == 200
        assert verify_response.json()["assetCount"] >= 1

    def test_remove_asset_from_album(self, api):
        test_image_path = Path(__file__).parent / "testImage.jpg"

        with open(test_image_path, "rb") as image_file:
            files = {"assetData": ("testImage.jpg", image_file, "image/jpeg")}
            data = create_asset_data("test-upload")
            upload_response = api.post("/assets", files=files, data=data)

        assert upload_response.status_code == 200
        asset_id = check_response_has_id(upload_response.json())
        
        create_response = api.post("/albums", json={"albumName": "album for rm asset"})
        album_id = check_response_has_id(create_response.json())

        add_payload = {"ids": [asset_id]}
        api.put(f"/albums/{album_id}/assets", json=add_payload)

        rm_payload = {"ids": [asset_id]}
        rm_response = api.delete(f"/albums/{album_id}/assets", json=rm_payload)
        assert rm_response.status_code == 200
        response_data = rm_response.json()
        check_list_response(response_data)

        verify_response = api.get(f"/albums/{album_id}")
        assert verify_response.status_code == 200
        assert verify_response.json()["assetCount"] == 0

class TestAlbumFullLifecycle:
    def test_full_album_lifecycle(self, api):
        create_payload = {"albumName": "lifecycle test album"}
        create_response = api.post("/albums", json=create_payload)
        assert create_response.status_code == 201
        album_id = check_response_has_id(create_response.json())

        test_image_path = Path(__file__).parent / "testImage.jpg"

        with open(test_image_path, "rb") as image_file:
            files = {"assetData": ("testImage.jpg", image_file, "image/jpeg")}
            data = create_asset_data("test-upload")
            upload_response = api.post("/assets", files=files, data=data)

        assert upload_response.status_code in [200, 201]
        asset_id = check_response_has_id(upload_response.json())

        add_payload = {"ids": [asset_id]}
        add_response = api.put(f"/albums/{album_id}/assets", json=add_payload)
        assert add_response.status_code == 200

        get_response = api.get(f"/albums/{album_id}")
        assert get_response.status_code == 200
        assert get_response.json()["assetCount"] >= 1

        update_payload = {"albumName": "update lifecycle album"}
        update_response = api.patch(f"/albums/{album_id}", json=update_payload)
        assert update_response.status_code == 200
        assert update_response.json()["albumName"] == update_payload["albumName"]

        rm_payload = {"ids": [asset_id]}
        rm_response = api.delete(f"/albums/{album_id}/assets", json=rm_payload)
        assert rm_response.status_code == 200

        delete_response = api.delete(f"/albums/{album_id}")
        assert delete_response.status_code == 204
        