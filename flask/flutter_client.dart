import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz Email Küldő',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Roboto',
      ),
      home: QuizEmailScreen(),
    );
  }
}

class QuizEmailScreen extends StatefulWidget {
  @override
  _QuizEmailScreenState createState() => _QuizEmailScreenState();
}

class _QuizEmailScreenState extends State<QuizEmailScreen> {
  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pointsController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  
  // WebSocket
  IO.Socket? socket;
  
  // UI State
  bool _isConnected = false;
  bool _isSending = false;
  String _statusMessage = 'Kapcsolódás a szerverhez...';
  Color _statusColor = Colors.orange;
  
  @override
  void initState() {
    super.initState();
    _connectToServer();
  }
  
  void _connectToServer() {
    try {
      // WebSocket kapcsolat létrehozása
      socket = IO.io('http://localhost:5000', <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      });
      
      // Kapcsolódás eseménykezelők
      socket!.onConnect((_) {
        setState(() {
          _isConnected = true;
          _statusMessage = 'Kapcsolódva a szerverhez ✅';
          _statusColor = Colors.green;
        });
        print('Kapcsolódva a szerverhez');
      });
      
      socket!.onDisconnect((_) {
        setState(() {
          _isConnected = false;
          _statusMessage = 'Kapcsolat megszakadt ❌';
          _statusColor = Colors.red;
        });
        print('Kapcsolat megszakadt');
      });
      
      socket!.onConnectError((error) {
        setState(() {
          _isConnected = false;
          _statusMessage = 'Kapcsolódási hiba: $error';
          _statusColor = Colors.red;
        });
        print('Kapcsolódási hiba: $error');
      });
      
      // Email eredmény kezelése
      socket!.on('email_result', (data) {
        setState(() {
          _isSending = false;
        });
        
        bool success = data['success'] ?? false;
        String message = data['message'] ?? 'Ismeretlen hiba';
        
        _showResultDialog(success, message);
      });
      
      // Szerver válasz kezelése
      socket!.on('response', (data) {
        print('Szerver válasz: $data');
      });
      
      // Kapcsolódás
      socket!.connect();
      
    } catch (e) {
      setState(() {
        _statusMessage = 'Hiba a kapcsolat létrehozásakor: $e';
        _statusColor = Colors.red;
      });
    }
  }
  
  void _sendQuizResult() {
    if (!_isConnected) {
      _showErrorDialog('Nincs kapcsolat a szerverrel!');
      return;
    }
    
    // Input validáció
    String email = _emailController.text.trim();
    String points = _pointsController.text.trim();
    String name = _nameController.text.trim();
    
    if (email.isEmpty) {
      _showErrorDialog('Add meg az email címet!');
      return;
    }
    
    if (points.isEmpty) {
      _showErrorDialog('Add meg a pontszámot!');
      return;
    }
    
    // Email formátum ellenőrzése
    if (!email.contains('@') || !email.contains('.')) {
      _showErrorDialog('Hibás email formátum!');
      return;
    }
    
    // Pontszám ellenőrzése
    int? pointsInt = int.tryParse(points);
    if (pointsInt == null || pointsInt < 0) {
      _showErrorDialog('A pontszám egy pozitív szám kell legyen!');
      return;
    }
    
    setState(() {
      _isSending = true;
    });
    
    // Üzenet összeállítása és küldése
    String message = name.isEmpty ? '$email;$points' : '$email;$points;$name';
    
    socket!.emit('send_quiz_result', {'message': message});
    
    print('Üzenet elküldve: $message');
  }
  
  void _showResultDialog(bool success, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                success ? Icons.check_circle : Icons.error,
                color: success ? Colors.green : Colors.red,
              ),
              SizedBox(width: 8),
              Text(success ? 'Sikeres!' : 'Hiba!'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (success) {
                  // Mezők törlése sikeres küldés után
                  _emailController.clear();
                  _pointsController.clear();
                  _nameController.clear();
                }
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
  
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Figyelem!'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
  
  @override
  void dispose() {
    socket?.disconnect();
    _emailController.dispose();
    _pointsController.dispose();
    _nameController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Email Küldő'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Kapcsolat státusz
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _statusColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    _isConnected ? Icons.wifi : Icons.wifi_off,
                    color: _statusColor,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _statusMessage,
                      style: TextStyle(
                        color: _statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 30),
            
            // Email cím mező
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Szülő email címe *',
                hintText: 'nagy.lajos@gmail.com',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            
            SizedBox(height: 20),
            
            // Pontszám mező
            TextField(
              controller: _pointsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Elért pontszám *',
                hintText: '12',
                prefixIcon: Icon(Icons.stars),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            
            SizedBox(height: 20),
            
            // Név mező (opcionális)
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Gyermek neve (opcionális)',
                hintText: 'Lajos',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),
            
            SizedBox(height: 30),
            
            // Küldés gomb
            ElevatedButton(
              onPressed: _isConnected && !_isSending ? _sendQuizResult : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 3,
              ),
              child: _isSending
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text('Email küldése...'),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send),
                        SizedBox(width: 8),
                        Text(
                          'Email küldése',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
            ),
            
            SizedBox(height: 20),
            
            // Újrakapcsolódás gomb
            if (!_isConnected)
              OutlinedButton(
                onPressed: _connectToServer,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Újrakapcsolódás'),
                  ],
                ),
              ),
            
            SizedBox(height: 30),
            
            // Példa szöveg
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      SizedBox(width: 8),
                      Text(
                        'Használat',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1. Add meg a szülő email címét\n'
                    '2. Írd be az elért pontszámot\n'
                    '3. Opcionálisan add meg a gyermek nevét\n'
                    '4. Nyomd meg az "Email küldése" gombot',
                    style: TextStyle(color: Colors.blue.shade800),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}