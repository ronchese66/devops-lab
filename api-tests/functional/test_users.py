from helpers.validators import check_response_has_id, check_list_response
from pathlib import Path

test_image_path = Path(__file__).parent / "testImage.jpg"

class TestUserInfo:

    def test_get_all_users(self, api):
        response = api.get("/users")

        assert response.status_code == 200
        check_list_response(response.json())

        user = response.json()[0]
        assert "id" in user
        assert "email" in user
        assert "name" in user 
        assert "avatarColor" in user

    def test_get_current_user(self, api):
        response = api.get("/users/me")

        assert response.status_code == 200
        data = response.json()
        assert "id" in data
        assert "email" in data
        assert "name" in data
        assert "isAdmin" in data
        assert "createdAt" in data
        assert "avatarColor" in data

    def test_get_user_by_id(self, api):
        me_response = api.get("/users/me")
        user_id = me_response.json()["id"]
        response = api.get(f"/users/{user_id}")

        assert response.status_code == 200
        data = response.json()
        assert data["id"] == user_id
        assert "email" in data
        assert "name" in data

    
class TestUserUpdate:

    def test_update_current_user(self, api):
        original_response = api.get("/users/me")
        original_name = original_response.json()["name"]

        update_payload = {
            "name": "updated test name"
        }
        response = api.put("/users/me", json=update_payload)

        assert response.status_code == 200
        assert response.json()["name"] == update_payload["name"]

        restore_payload = {
            "name": original_name
        }
        api.put("/users/me", json=restore_payload)
        
    def test_update_user_avatar_color(self, api):
        original_response = api.get("/users/me")
        original_color = original_response.json()["avatarColor"]

        new_color = "red" if original_color != "red" else "blue"

        update_payload = {
            "avatarColor": new_color
        }
        response = api.put("/users/me", json=update_payload)

        assert response.status_code == 200
        assert response.json()["avatarColor"] == new_color
        
        restore_payload = {
            "avatarColor": original_color
        }
        api.put("/users/me", json=restore_payload)


class TestUserOnboarding:
    
    def test_get_user_onboarding(self, api):
        response = api.get("/users/me/onboarding")
        
        assert response.status_code == 200
        data = response.json()
        assert "isOnboarded" in data
        assert isinstance(data["isOnboarded"], bool)
    
    def test_update_user_onboarding(self, api):
        original_response = api.get("/users/me/onboarding")
        original_status = original_response.json()["isOnboarded"]
        
        update_payload = {
            "isOnboarded": not original_status
        }
        response = api.put("/users/me/onboarding", json=update_payload)
        
        assert response.status_code == 200
        assert response.json()["isOnboarded"] == (not original_status)
        
        restore_payload = {"isOnboarded": original_status}
        api.put("/users/me/onboarding", json=restore_payload)
    
    def test_delete_user_onboarding(self, api):
        original_response = api.get("/users/me/onboarding")
        original_status = original_response.json()["isOnboarded"]
        
        response = api.delete("/users/me/onboarding")
        
        assert response.status_code == 204
        
        restore_payload = {"isOnboarded": original_status}
        api.put("/users/me/onboarding", json=restore_payload)


class TestUserPreferences:
    
    def test_get_user_preferences(self, api):
        response = api.get("/users/me/preferences")
        
        assert response.status_code == 200
        data = response.json()
        assert "albums" in data
        assert "download" in data
        assert "memories" in data
        assert "people" in data
        assert "tags" in data
    
    def test_update_user_preferences(self, api):
        update_payload = {
            "download": {
                "archiveSize": 40000000
            }
        }
        response = api.put("/users/me/preferences", json=update_payload)
        
        assert response.status_code == 200
        assert "download" in response.json()


class TestUserProfileImage:
    
    def test_create_profile_image(self, api):
        with open(test_image_path, "rb") as image_file:
            files = {"file": ("profile.jpg", image_file, "image/jpeg")}
            response = api.post("/users/profile-image", files=files)
        
        assert response.status_code in [200, 201]
        data = response.json()
        assert "userId" in data
        assert "profileImagePath" in data
        assert "profileChangedAt" in data
    
    def test_get_profile_image(self, api):
        me_response = api.get("/users/me")
        user_id = me_response.json()["id"]
        
        with open(test_image_path, "rb") as image_file:
            files = {"file": ("profile.jpg", image_file, "image/jpeg")}
            api.post("/users/profile-image", files=files)
        
        response = api.get(f"/users/{user_id}/profile-image")
        
        assert response.status_code == 200
        assert len(response.content) > 0
    
    def test_delete_profile_image(self, api):
        with open(test_image_path, "rb") as image_file:
            files = {"file": ("profile.jpg", image_file, "image/jpeg")}
            api.post("/users/profile-image", files=files)
        
        response = api.delete("/users/profile-image")
        
        assert response.status_code == 204
