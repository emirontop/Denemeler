import { useState, useEffect } from 'react';

export default function Home() {
  const [messages, setMessages] = useState([]);
  const [user, setUser] = useState('Emir');
  const [text, setText] = useState('');

  useEffect(() => {
    fetch('/api/chat')
      .then(res => res.json())
      .then(data => setMessages(data));
  }, []);

  const sendMessage = async () => {
    if (!text.trim()) return alert('Mesaj boş olamaz');
    await fetch('/api/chat', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ user, text }),
    });
    setText('');
    const res = await fetch('/api/chat');
    const data = await res.json();
    setMessages(data);
  };

  return (
    <div style={{ padding: 20 }}>
      <h1>Basit Chat</h1>
      <div style={{ maxHeight: 300, overflowY: 'auto', border: '1px solid #ccc', padding: 10 }}>
        {messages.length === 0 && <p>Mesaj yok</p>}
        {messages.map((m, i) => (
          <div key={i}>
            <b>{m.user}</b> [{new Date(m.time).toLocaleTimeString()}]: {m.text}
          </div>
        ))}
      </div>
      <input
        value={user}
        onChange={e => setUser(e.target.value)}
        placeholder="Kullanıcı adı"
        style={{ marginTop: 10 }}
      />
      <br />
      <textarea
        value={text}
        onChange={e => setText(e.target.value)}
        rows={3}
        style={{ width: '100%', marginTop: 5 }}
        placeholder="Mesajınız..."
      />
      <br />
      <button onClick={sendMessage} style={{ marginTop: 5 }}>
        Gönder
      </button>
    </div>
  );
}
