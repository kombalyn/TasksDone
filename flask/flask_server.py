from flask import Flask, request, jsonify
from flask_socketio import SocketIO, emit
import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
import os
from datetime import datetime

app = Flask(__name__)
app.config['SECRET_KEY'] = 'your-secret-key-here'
socketio = SocketIO(app, cors_allowed_origins="*")

# Email konfigurációs beállítások
SMTP_SERVER = "smtp.gmail.com"  # Gmail SMTP
SMTP_PORT = 587
SENDER_EMAIL = "lumeei@lumeei.com"
SENDER_PASSWORD = "your-app-password-here"  # App password szükséges Gmail-hez

def send_quiz_email(recipient_email, points, child_name="gyermeked"):
    """Kvíz eredményről szóló email küldése"""
    try:
        # Email tartalom létrehozása
        subject = f"🎉 Szuper kvíz eredmény - {points} pont!"
        
        body = f"""
        Kedves Szülő!
        
        Örömmel értesítjük, hogy {child_name} kiváló eredményt ért el a kvízben!
        
        📊 Elért pontszám: {points} pont
        🗓️ Dátum: {datetime.now().strftime('%Y-%m-%d %H:%M')}
        
        Gratulálunk a remek teljesítményhez! {child_name} nagy szorgalmat tanúsított.
        
        Üdvözlettel,
        A Kvíz Csapat
        
        ---
        Ez egy automatikusan generált email.
        """
        
        # Email objektum létrehozása
        msg = MIMEMultipart()
        msg['From'] = SENDER_EMAIL
        msg['To'] = recipient_email
        msg['Subject'] = subject
        
        # Szöveges tartalom hozzáadása
        msg.attach(MIMEText(body, 'plain', 'utf-8'))
        
        # SMTP szerver kapcsolat
        server = smtplib.SMTP(SMTP_SERVER, SMTP_PORT)
        server.starttls()  # TLS engedélyezése
        server.login(SENDER_EMAIL, SENDER_PASSWORD)
        
        # Email küldése
        text = msg.as_string()
        server.sendmail(SENDER_EMAIL, recipient_email, text)
        server.quit()
        
        return True, "Email sikeresen elküldve!"
        
    except Exception as e:
        return False, f"Email küldési hiba: {str(e)}"

@app.route('/')
def home():
    return """
    <h1>Quiz Email Server</h1>
    <p>A szerver fut és készen áll az email küldésre!</p>
    <p>WebSocket endpoint: /</p>
    <p>Üzenet formátum: "email@example.com;pontszám;név(opcionális)"</p>
    """

@app.route('/send-email', methods=['POST'])
def send_email_api():
    """REST API endpoint email küldéshez"""
    try:
        data = request.json
        message = data.get('message', '')
        
        # Üzenet feldolgozása
        success, result = process_message(message)
        
        if success:
            return jsonify({
                'status': 'success',
                'message': result
            }), 200
        else:
            return jsonify({
                'status': 'error',
                'message': result
            }), 400
            
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': f'Szerver hiba: {str(e)}'
        }), 500

def process_message(message):
    """Bejövő üzenet feldolgozása"""
    try:
        # Üzenet formátum: "email;pontszám;név(opcionális)"
        parts = message.split(';')
        
        if len(parts) < 2:
            return False, "Hibás üzenet formátum! Használd: 'email;pontszám;név'"
        
        recipient_email = parts[0].strip()
        points = parts[1].strip()
        child_name = parts[2].strip() if len(parts) > 2 else "gyermeked"
        
        # Email cím validáció (egyszerű)
        if '@' not in recipient_email or '.' not in recipient_email:
            return False, "Hibás email cím!"
        
        # Pontszám validáció
        try:
            points_int = int(points)
            if points_int < 0:
                return False, "A pontszám nem lehet negatív!"
        except ValueError:
            return False, "A pontszám számnak kell lennie!"
        
        # Email küldése
        success, message = send_quiz_email(recipient_email, points_int, child_name)
        
        return success, message
        
    except Exception as e:
        return False, f"Üzenet feldolgozási hiba: {str(e)}"

@socketio.on('connect')
def handle_connect():
    print('Kliens csatlakozott')
    emit('response', {'message': 'Sikeres csatlakozás a szerverhez!'})

@socketio.on('disconnect')
def handle_disconnect():
    print('Kliens lecsatlakozott')

@socketio.on('send_quiz_result')
def handle_quiz_result(data):
    """WebSocket üzenet kezelése"""
    try:
        message = data.get('message', '')
        print(f"Kapott üzenet: {message}")
        
        # Üzenet feldolgozása
        success, result = process_message(message)
        
        # Válasz küldése a kliensnek
        emit('email_result', {
            'success': success,
            'message': result,
            'timestamp': datetime.now().isoformat()
        })
        
    except Exception as e:
        emit('email_result', {
            'success': False,
            'message': f'Szerver hiba: {str(e)}',
            'timestamp': datetime.now().isoformat()
        })

if __name__ == '__main__':
    # Fontos: A jelszót környezeti változóból olvasd be éles használatban!
    # SENDER_PASSWORD = os.getenv('EMAIL_PASSWORD')
    
    print("Flask Email Server indítása...")
    print(f"Feladó email: {SENDER_EMAIL}")
    print("WebSocket elérhető a / endpoint-on")
    
    # Fejlesztési mód
    socketio.run(app, debug=True, host='0.0.0.0', port=5000)