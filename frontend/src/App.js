import React, { useState, useEffect } from 'react';
import './App.css';

function App() {
  const [apiMessage, setApiMessage] = useState('');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const fetchApiMessage = async () => {
    setLoading(true);
    setError('');
    try {
      // In production, this would be the backend service URL
      const response = await fetch('/api');
      const data = await response.json();
      setApiMessage(data.message);
    } catch (err) {
      setError('Failed to fetch API message. Backend might not be running.');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchApiMessage();
  }, []);

  return (
    <div className="App">
      <header className="App-header">
        <h1>🧩 Cloud-Native Multi-Service App</h1>
        <p>Frontend + Backend + Database with Docker & Kubernetes</p>
        
        <div className="api-section">
          <h2>Backend API Status</h2>
          {loading && <p>Loading...</p>}
          {error && <p className="error">{error}</p>}
          {apiMessage && (
            <div className="api-response">
              <p><strong>API Response:</strong></p>
              <p>{apiMessage}</p>
            </div>
          )}
          <button onClick={fetchApiMessage} disabled={loading}>
            {loading ? 'Loading...' : 'Refresh API'}
          </button>
        </div>

        <div className="tech-stack">
          <h3>🛠️ Tech Stack</h3>
          <div className="tech-grid">
            <div className="tech-item">React Frontend</div>
            <div className="tech-item">Flask Backend</div>
            <div className="tech-item">PostgreSQL DB</div>
            <div className="tech-item">Docker</div>
            <div className="tech-item">Kubernetes</div>
            <div className="tech-item">GitHub Actions</div>
          </div>
        </div>
      </header>
    </div>
  );
}

export default App; 