import unittest
from app import app

class TestApp(unittest.TestCase):
    def setUp(self):
        self.app = app.test_client()
        self.app.testing = True

    def test_health_endpoint(self):
        """Test the health check endpoint"""
        response = self.app.get('/api/health')
        self.assertEqual(response.status_code, 200)
        data = response.get_json()
        self.assertIn('status', data)
        self.assertEqual(data['status'], 'healthy')

    def test_root_endpoint(self):
        """Test the root API endpoint"""
        response = self.app.get('/api')
        self.assertEqual(response.status_code, 200)
        data = response.get_json()
        self.assertIn('message', data)

    def test_messages_endpoint(self):
        """Test the messages endpoint"""
        response = self.app.get('/api/messages')
        self.assertEqual(response.status_code, 200)
        data = response.get_json()
        self.assertIn('messages', data)

if __name__ == '__main__':
    unittest.main() 