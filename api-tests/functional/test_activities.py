import uuid
from pathlib import Path
from datetime import datetime
from helpers.validators import check_response_has_id, check_list_response

test_image_path = Path(__file__).parent / "testImage.jpg"

def get_asset_data(prefix="test"):
    return {
        "deviceAssetId": f"{prefix}-{uuid.uuid4()}",
        "deviceId": "test-device-001",
        "fileCreatedAt": datetime.now().isoformat(),
        "fileModifiedAt": datetime.now().isoformat()
    }


class TestActivitiesCRUD:

    # You must create album and add assets for /activities tests
    def test_create_activity_like(self, api):
        album_response = api.post("/albums", json={"albumName": "test activities album"})
        assert album_response.status_code == 201
        album_id = check_response_has_id(album_response.json())

        activity_payload = {
            "albumId": album_id,
            "type": "like"
        }
        
        response = api.post("/activities", json=activity_payload)
        assert response.status_code == 201
        activity_id = check_response_has_id(response.json())
        assert response.json()["type"] == activity_payload["type"]

    def test_create_activity_comment(self, api):
        album_response = api.post("/albums", json={"albumName": "activity comment"})
        assert album_response.status_code == 201
        album_id = check_response_has_id(album_response.json())
        
        activity_payload = {
            "albumId": album_id,
            "type": "comment",
            "comment": "no comments"
        }

        response = api.post("/activities", json=activity_payload)
        assert response.status_code == 201
        activity_id = check_response_has_id(response.json())
        assert response.json()["type"] == activity_payload["type"]
        assert response.json()["comment"] == activity_payload["comment"]

    def test_create_activity_on_asset(self, api):
        album_response = api.post("/albums", json={"albumName": "asset activity album"})
        assert album_response.status_code == 201
        album_id = check_response_has_id(album_response.json())

        with open(test_image_path, "rb") as image_file:
            files = {"assetData": ("testImage.jpg", image_file, "image/jpeg")}
            data = get_asset_data("test-asset-activity")
            upload_response = api.post("/assets", files=files, data=data)

        assert upload_response.status_code in [200, 201]
        asset_id = check_response_has_id(upload_response.json())

        add_payload = {"ids": [asset_id]}
        api.put(f"/albums/{album_id}/assets", json=add_payload)

        activity_payload = {
            "albumId": album_id,
            "assetId": asset_id,
            "type": "like"
        }
        response = api.post("/activities", json=activity_payload)
        assert response.status_code == 201
        activity_id = check_response_has_id(response.json())
        assert response.json()["assetId"] == asset_id

    def test_get_activities(self, api):
        album_response = api.post("/albums", json={"albumName": "test get"})
        assert album_response.status_code == 201
        album_id = check_response_has_id(album_response.json())

        activity_payload = {
            "albumId": album_id,
            "type": "like"
        }

        api.post("/activities", json=activity_payload)
        response = api.get("/activities", params={"albumId": album_id})

        assert response.status_code == 200
        check_list_response(response.json())
        assert len(response.json()) >= 1

    def test_delete_activity(self, api):
        album_response = api.post("/albums", json={"albumName": "test delete activity"})
        assert album_response.status_code == 201
        album_id = check_response_has_id(album_response.json())
        
        activity_payload = {
            "albumId": album_id,
            "type": "like"
        }
        create_response = api.post("/activities", json=activity_payload)
        activity_id = check_response_has_id(create_response.json())
        
        response = api.delete(f"/activities/{activity_id}")
        assert response.status_code == 204


class TestActivityStatistics:

    def test_get_activity_statistics(self, api):
        album_response = api.post("/albums", json={"albumName": "test stat"})
        assert album_response.status_code == 201
        album_id = check_response_has_id(album_response.json())

        like_payload = {
            "albumId": album_id,
            "type": "like"
        }
        api.post("/activities", json=like_payload)

        comment_payload = {
            "albumId": album_id,
            "type": "comment",
            "comment": "no comments"
        }
        api.post("/activities", json=comment_payload)

        response = api.get("/activities/statistics", params={"albumId": album_id})

        assert response.status_code == 200
        data = response.json()
        assert "likes" in data
        assert "comments" in data
        assert isinstance(data["likes"], int)
        assert isinstance(data["comments"], int)
        assert data["likes"] >= 1
        assert data["comments"] >= 1


class TestActivityLifecycle:

     def test_full_activity_lifecycle(self, api):
        album_response = api.post("/albums", json={"albumName": "lifecycle activity test"})
        assert album_response.status_code == 201
        album_id = check_response_has_id(album_response.json())
        
        like_payload = {
            "albumId": album_id,
            "type": "like"
        }
        like_response = api.post("/activities", json=like_payload)
        assert like_response.status_code == 201
        like_id = check_response_has_id(like_response.json())
        
        comment_payload = {
            "albumId": album_id,
            "type": "comment",
            "comment": "nice albums"
        }
        comment_response = api.post("/activities", json=comment_payload)
        assert comment_response.status_code == 201
        comment_id = check_response_has_id(comment_response.json())
        
        get_response = api.get("/activities", params={"albumId": album_id})
        assert get_response.status_code == 200
        check_list_response(get_response.json())
        assert len(get_response.json()) == 2
        
        stats_response = api.get("/activities/statistics", params={"albumId": album_id})
        assert stats_response.status_code == 200
        assert stats_response.json()["likes"] == 1
        assert stats_response.json()["comments"] == 1
        
        delete_like = api.delete(f"/activities/{like_id}")
        assert delete_like.status_code == 204
        
        delete_comment = api.delete(f"/activities/{comment_id}")
        assert delete_comment.status_code == 204
        
        final_get = api.get("/activities", params={"albumId": album_id})
        assert final_get.status_code == 200
        assert len(final_get.json()) == 0


