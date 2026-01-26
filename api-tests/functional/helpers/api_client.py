import requests

API_KEY_HEADER = "x-api-key"

class APIClient:
    def __init__(self, base_url, api_key):
        self.base_url = base_url
        self.session = requests.Session()
        self.session.headers.update({API_KEY_HEADER: api_key})

    def post(self, endpoint, **kwargs):
        return self.session.post(f"{self.base_url}{endpoint}", **kwargs)
    
    def get(self, endpoint, **kwargs):
        return self.session.get(f"{self.base_url}{endpoint}", **kwargs)
    
    def put(self, endpoint, **kwargs):
        return self.session.put(f"{self.base_url}{endpoint}", **kwargs)
    
    def delete(self, endpoint, **kwargs):
        return self.session.delete(f"{self.base_url}{endpoint}", **kwargs)
    
    def patch(self, endpoint, **kwargs):
        return self.session.patch(f"{self.base_url}{endpoint}", **kwargs)