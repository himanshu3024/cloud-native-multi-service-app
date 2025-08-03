from flask import Flask, jsonify, request
from flask_cors import CORS
import os
import psycopg2
from datetime import datetime
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)  # Enable CORS for all routes

# Database configuration
DB_HOST = os.getenv('DB_HOST', 'postgres-service')
DB_NAME = os.getenv('DB_NAME', 'cloudapp')
DB_USER = os.getenv('DB_USER', 'postgres')
DB_PASSWORD = os.getenv('DB_PASSWORD', 'password')
DB_PORT = os.getenv('DB_PORT', '5432')

def get_db_connection():
    """Create database connection"""
    try:
        connection = psycopg2.connect(
            host=DB_HOST,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
            port=DB_PORT
        )
        return connection
    except Exception as e:
        logger.error(f"Database connection failed: {e}")
        return None

def init_database():
    """Initialize database tables"""
    conn = get_db_connection()
    if conn:
        try:
            cursor = conn.cursor()
            cursor.execute('''
                CREATE TABLE IF NOT EXISTS messages (
                    id SERIAL PRIMARY KEY,
                    message TEXT NOT NULL,
                    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
                )
            ''')
            conn.commit()
            cursor.close()
            logger.info("Database initialized successfully")
        except Exception as e:
            logger.error(f"Database initialization failed: {e}")
        finally:
            conn.close()

@app.route('/')
def home():
    """Root endpoint"""
    return jsonify({
        'message': 'Cloud-Native Multi-Service App Backend API',
        'status': 'running',
        'timestamp': datetime.now().isoformat()
    })

@app.route('/api')
def api_root():
    """Main API endpoint"""
    return jsonify({
        'message': 'Hello from Flask API! 🚀',
        'service': 'backend-api',
        'timestamp': datetime.now().isoformat(),
        'database_status': 'connected' if get_db_connection() else 'disconnected'
    })

@app.route('/api/health')
def health_check():
    """Health check endpoint"""
    db_status = 'healthy' if get_db_connection() else 'unhealthy'
    return jsonify({
        'status': 'healthy',
        'service': 'backend-api',
        'database': db_status,
        'timestamp': datetime.now().isoformat()
    })

@app.route('/api/messages', methods=['GET'])
def get_messages():
    """Get all messages from database"""
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = conn.cursor()
        cursor.execute('SELECT id, message, timestamp FROM messages ORDER BY timestamp DESC LIMIT 10')
        messages = cursor.fetchall()
        cursor.close()
        
        return jsonify({
            'messages': [
                {
                    'id': msg[0],
                    'message': msg[1],
                    'timestamp': msg[2].isoformat()
                } for msg in messages
            ]
        })
    except Exception as e:
        logger.error(f"Error fetching messages: {e}")
        return jsonify({'error': 'Failed to fetch messages'}), 500
    finally:
        conn.close()

@app.route('/api/messages', methods=['POST'])
def create_message():
    """Create a new message"""
    data = request.get_json()
    if not data or 'message' not in data:
        return jsonify({'error': 'Message is required'}), 400
    
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = conn.cursor()
        cursor.execute(
            'INSERT INTO messages (message) VALUES (%s) RETURNING id, timestamp',
            (data['message'],)
        )
        result = cursor.fetchone()
        conn.commit()
        cursor.close()
        
        return jsonify({
            'id': result[0],
            'message': data['message'],
            'timestamp': result[1].isoformat()
        }), 201
    except Exception as e:
        logger.error(f"Error creating message: {e}")
        return jsonify({'error': 'Failed to create message'}), 500
    finally:
        conn.close()

@app.route('/api/stats')
def get_stats():
    """Get application statistics"""
    conn = get_db_connection()
    if not conn:
        return jsonify({'error': 'Database connection failed'}), 500
    
    try:
        cursor = conn.cursor()
        cursor.execute('SELECT COUNT(*) FROM messages')
        message_count = cursor.fetchone()[0]
        cursor.close()
        
        return jsonify({
            'total_messages': message_count,
            'service': 'backend-api',
            'timestamp': datetime.now().isoformat()
        })
    except Exception as e:
        logger.error(f"Error fetching stats: {e}")
        return jsonify({'error': 'Failed to fetch statistics'}), 500
    finally:
        conn.close()

if __name__ == '__main__':
    # Initialize database on startup
    init_database()
    
    # Get port from environment or default to 5000
    port = int(os.environ.get('PORT', 5000))
    
    # Run the app
    app.run(host='0.0.0.0', port=port, debug=False) 