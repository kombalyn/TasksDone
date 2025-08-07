import 'dart:async';
import 'dart:io';
import 'package:apptvshow/Navbar/navbar.dart';
import 'package:apptvshow/aSZF.dart';
import 'package:apptvshow/color/colorapp.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
// import 'package:in_app_purchase/in_app_purchase.dart'; // KIKAPCSOLVA TESZTELÉSHEZ
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'forms/datacheck.dart';

class SubscriptionOptions extends StatefulWidget {
  const SubscriptionOptions({super.key});

  @override
  State<SubscriptionOptions> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionOptions> {
  // TESZT VERZIÓ - In-App Purchase kikapcsolva
  // final InAppPurchase _iap = InAppPurchase.instance;
  bool _available = true; // Mindig elérhető tesztben
  // List<ProductDetails> _products = [];
  // late StreamSubscription<List<PurchaseDetails>> _subscription;
  bool _loading = false; // Gyors betöltés teszthez
  bool _purchasePending = false;
  String _selectedPlan = 'lumeei_5900ft_1mm';
  String _errorMessage = '';

  // Mock termék adatok teszteléshez
  final Map<String, Map<String, String>> _mockProducts = {
    'lumeei_5900ft_1mm': {
      'price': '5900 Ft',
      'title': 'Havi előfizetés',
    },
    'lumeeitest_99ft_1mm': {
      'price': '99 Ft', 
      'title': 'Éves előfizetés',
    },
  };

  final Set<String> _productIds = {
    'lumeei_5900ft_1mm', 
    'lumeeitest_99ft_1mm',
  };

  @override
  void initState() {
    super.initState();
    // TESZT VERZIÓ - IAP inicializálás kihagyva
    // _initializeIAP();
    _initializeTestMode();
  }

  // TESZT MÓDUSZ inicializálása - gyors és egyszerű
  Future<void> _initializeTestMode() async {
    setState(() {
      _loading = false;
      _available = true;
      _errorMessage = '';
    });
  }

  /* EREDETI IAP FUNKCIÓK KIKOMMENTEZVE TESZTELÉSHEZ
  Future<void> _initializeIAP() async {
    _available = await _iap.isAvailable();

    if (_available) {
      _subscription = _iap.purchaseStream.listen(
        _onPurchaseUpdate,
        onDone: () {
          _subscription.cancel();
        },
        onError: (Object error) {
          print('Purchase stream error: $error');
          setState(() {
            _errorMessage = 'Vásárlási hiba: $error';
          });
        },
      );

      await _loadProducts();
      await _restorePurchases();
    } else {
      setState(() {
        _errorMessage = 'In-app purchase nem elérhető ezen az eszközön';
      });
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _loadProducts() async {
    try {
      final ProductDetailsResponse response = await _iap.queryProductDetails(
        _productIds,
      );

      if (response.notFoundIDs.isNotEmpty) {
        print('Nem talált termékek: ${response.notFoundIDs}');
        setState(() {
          _errorMessage =
          'Egyes termékek nem találhatók: ${response.notFoundIDs.join(', ')}';
        });
      }

      setState(() {
        _products = response.productDetails;
      });

      print('Betöltött termékek: ${_products.map((p) => p.id).toList()}');
    } catch (e) {
      print('Termékek betöltési hiba: $e');
      setState(() {
        _errorMessage = 'Termékek betöltési hiba: $e';
      });
    }
  }

  Future<void> _restorePurchases() async {
    try {
      await _iap.restorePurchases();
      print('Vásárlások visszaállítva');
    } catch (e) {
      print('Vásárlások visszaállítási hiba: $e');
    }
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      print(
        'Vásárlás státusz: ${purchaseDetails.status}, Termék: ${purchaseDetails.productID}',
      );

      switch (purchaseDetails.status) {
        case PurchaseStatus.pending:
          setState(() {
            _purchasePending = true;
            _errorMessage = '';
          });
          break;

        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _handleSuccessfulPurchase(purchaseDetails);
          break;

        case PurchaseStatus.error:
          setState(() {
            _purchasePending = false;
            _errorMessage =
            'Vásárlási hiba: ${purchaseDetails.error?.message ?? 'Ismeretlen hiba'}';
          });
          break;

        case PurchaseStatus.canceled:
          setState(() {
            _purchasePending = false;
            _errorMessage = 'Vásárlás megszakítva';
          });
          break;
      }

      if (purchaseDetails.pendingCompletePurchase) {
        _iap.completePurchase(purchaseDetails);
      }
    }
  }

  Future<void> _handleSuccessfulPurchase(
      PurchaseDetails purchaseDetails,
      ) async {
    setState(() {
      _purchasePending = false;
      _errorMessage = '';
    });

    print('Sikeres vásárlás: ${purchaseDetails.productID}');

    await _verifyPurchase(purchaseDetails);
    _showSuccessDialog(purchaseDetails.productID);
  }

  Future<void> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    const String serverUrl = 'http://104.155.99.100:5000/verify-purchase';

    try {
      final Map<String, dynamic> purchaseData = {
        'productId': purchaseDetails.productID,
        'purchaseToken':
        purchaseDetails.verificationData.serverVerificationData,
        'platform': Platform.isAndroid ? 'android' : 'ios',
        'packageName':
        'com.yourcompany.yourapp',
      };

      final response = await http.post(
        Uri.parse(serverUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(purchaseData),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('Szerver validáció eredménye: $result');
        _activatePremiumFeatures(purchaseDetails.productID);
      } else {
        print('Szerver validáció sikertelen: ${response.statusCode}');
      }
    } catch (e) {
      print('Validációs hiba: $e');
      _activatePremiumFeatures(purchaseDetails.productID);
    }
  }

  void _activatePremiumFeatures(String productId) {
    print('Premium funkciók aktiválva: $productId');
  }
  */

  // TESZT VERZIÓ - Szimulált vásárlás
  Future<void> _buyProduct(String productId) async {
    if (_purchasePending) return;

    print('TESZT MÓDUSZ: Szimulált vásárlás indítása - $productId');

    setState(() {
      _purchasePending = true;
      _errorMessage = '';
    });

    // Szimulált várakozás (mint egy igazi fizetési folyamat)
    await Future.delayed(const Duration(seconds: 2));

    // Szimulált sikeres vásárlás
    setState(() {
      _purchasePending = false;
    });

    print('TESZT MÓDUSZ: Sikeres vásárlás - $productId');
    
    // Szimulált premium aktiválás
    _activatePremiumFeaturesTest(productId);
    
    // Sikeres vásárlás dialógus
    _showSuccessDialog(productId);
  }

  // TESZT VERZIÓ - Premium funkciók aktiválása
  void _activatePremiumFeaturesTest(String productId) {
    print('TESZT MÓDUSZ: Premium funkciók aktiválva: $productId');
    
    // Itt később meghívhatod a következő oldalt vagy funkciót
    // Például: Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
  }

  // TESZT VERZIÓ - Szimulált visszaállítás
  Future<void> _restorePurchasesTest() async {
    print('TESZT MÓDUSZ: Vásárlások visszaállítása szimulálva');
    
    // Szimulált várakozás
    await Future.delayed(const Duration(seconds: 1));
    
    // Sikeres visszaállítás szimulálása
    _showInfoDialog('Teszt módusz', 'Vásárlások visszaállítása szimulálva.\nTeszt móduszban mindig sikeres.');
  }

  void _showSuccessDialog(String productId) {
    final planName = productId == 'lumeei_5900ft_1mm' ? 'Havi' : 'Éves';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.green.shade50,
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 8),
            const Text('Sikeres vásárlás!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$planName előfizetés sikeresen aktiválva!'),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'TESZT MÓDUSZ\nValódi fizetés nem történt',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Itt navigálhatsz a következő oldalra
              // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NextScreen()));
            },
            child: const Text('Tovább'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hiba'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _getProductPrice(String productId) {
    return _mockProducts[productId]?['price'] ?? 'N/A';
  }

  String _getProductTitle(String productId) {
    return _mockProducts[productId]?['title'] ?? 'Ismeretlen csomag';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 550;

    return Scaffold(
      backgroundColor: ColorApp.bgHome,
      body: SafeArea(
        child: _loading
            ? const Center(
          child: CircularProgressIndicator(color: Colors.white),
        )
            : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // TESZT MÓDUSZ jelzés
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'TESZT MÓDUSZ - Fizetés kikapcsolva',
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                // Logo és cím
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Image.asset(
                        'images/LUMEEI_logó.jpg',
                        height: screenHeight*0.2,
                      ),
                      Text(
                        'LUMEEI',
                        style: GoogleFonts.montserrat(
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 52 : 72,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        "FIZETÉSI TERV",
                        style: GoogleFonts.poppins(
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: isSmallScreen ? 23: 35,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Hiba üzenet
                if (_errorMessage.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.error, color: Colors.red.shade700),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Előfizetési opciók kártya
                Card(
                  margin: EdgeInsets.all(isSmallScreen ? 8 : 16),
                  child: Container(
                    padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Válassz előfizetési csomagot',
                          style: GoogleFonts.openSans(
                            textStyle: TextStyle(
                              color: Colors.black,
                              fontSize: isSmallScreen ? 16 : 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Havi csomag
                        _buildPlanCard(
                          'lumeei_5900ft_1mm',
                          'Havi csomag',
                          _getProductPrice('lumeei_5900ft_1mm'),
                          'hónap',
                          false,
                          isSmallScreen,
                        ),

                        const SizedBox(height: 16),

                        // Éves csomag
                        _buildPlanCard(
                          'lumeeitest_99ft_1mm',
                          'Éves csomag',
                          _getProductPrice('lumeeitest_99ft_1mm'),
                          'év',
                          true,
                          isSmallScreen,
                        ),

                        const SizedBox(height: 20),

                        // Előnyök lista
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Előfizetés előnyei:',
                                style: GoogleFonts.openSans(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              _buildFeatureItem(
                                'Korlátlan hozzáférés minden funkcióhoz',
                              ),
                              _buildFeatureItem('Több eszköz egyidőben'),
                              _buildFeatureItem('Prémium tartalom'),
                              _buildFeatureItem('Reklámmentes élmény'),
                              _buildFeatureItem('Prioritás támogatás'),
                            ],
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Vásárlás gomb - TESZT VERZIÓ
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: (_available && !_purchasePending)
                                ? () => _buyProduct(_selectedPlan)
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade700, // Zöld szín a teszt verzióhoz
                              disabledBackgroundColor: Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: _purchasePending
                                ? const Row(
                              mainAxisAlignment:
                              MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Teszt fizetés folyamatban...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                                : Text(
                              'TESZT: Előfizetés szimulálása',
                              style: GoogleFonts.montserrat(
                                textStyle: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Vásárlások visszaállítása gomb - TESZT VERZIÓ
                        SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: _available
                                ? _restorePurchasesTest
                                : null,
                            child: Text(
                              'TESZT: Vásárlások visszaállítása',
                              style: GoogleFonts.openSans(
                                textStyle: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // ÁSZF link
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const Aszf()));
                  },
                  child: Text(
                    'ÁSZF & Adatvédelmi tájékoztató',
                    style: GoogleFonts.poppins(
                      textStyle: const TextStyle(
                        color: Colors.white,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCard(
      String planId,
      String title,
      String price,
      String period,
      bool isPopular,
      bool isSmallScreen,
      ) {
    final isSelected = _selectedPlan == planId;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlan = planId),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.green.shade700 : Colors.grey.shade300, // Zöld szín a teszthez
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.green.shade50 : Colors.white, // Zöld árnyalat
        ),
        child: Row(
          children: [
            Radio<String>(
              value: planId,
              groupValue: _selectedPlan,
              onChanged: (value) => setState(() => _selectedPlan = value!),
              activeColor: Colors.green.shade700,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.openSans(
                          fontSize: isSmallScreen ? 14 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (isPopular)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'NÉPSZERŰ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: isSmallScreen ? 9 : 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    '$price / $period',
                    style: GoogleFonts.openSans(
                      fontSize: isSmallScreen ? 12 : 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (isPopular)
                    Text(
                      '17% megtakarítás',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: isSmallScreen ? 10 : 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              feature,
              style: GoogleFonts.openSans(
                fontSize: 12,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // TESZT VERZIÓ - IAP stream leiratkozás kihagyva
    // if (_available) {
    //   _subscription.cancel();
    // }
    super.dispose();
  }
}