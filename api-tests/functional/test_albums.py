from helpers.validators import check_list_response, check_response_has_id


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
        create_response = api.post("/albums", json=payload)
        album_id = check_response_has_id(create_response.json())
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
