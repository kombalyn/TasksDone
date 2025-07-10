import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final InAppPurchase _iap = InAppPurchase.instance;
  bool _available = false;
  List<ProductDetails> _products = [];
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  bool _loading = true;
  bool _purchasePending = false;
  String _selectedPlan = 'monthly_plan';
  String _errorMessage = '';

  // Termék ID-k - ezeket a Google Play Console/App Store Connect-ben kell létrehozni
  final Set<String> _productIds = {
    'monthly_plan', // Havi előfizetés
    'yearly_plan', // Éves előfizetés
  };

  @override
  void initState() {
    super.initState();
    _initializeIAP();
  }

  Future<void> _initializeIAP() async {
    // Ellenőrizzük, hogy elérhető-e az in-app purchase
    _available = await _iap.isAvailable();

    if (_available) {
      // Feliratkozás a vásárlási eseményekre
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

      // Termékek betöltése
      await _loadProducts();

      // Korábbi vásárlások visszaállítása
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

      // Vásárlás befejezése (fontos!)
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

    // Receipt validáció (opcionális, de javasolt production környezetben)
    await _verifyPurchase(purchaseDetails);

    // Sikeres vásárlás üzenet
    _showSuccessDialog(purchaseDetails.productID);
  }

  Future<void> _verifyPurchase(PurchaseDetails purchaseDetails) async {
    // Szerver oldali validáció - helyettesítsd a saját szerver URL-eddel
    const String serverUrl = 'https://your-server.com/verify-purchase';

    try {
      final Map<String, dynamic> purchaseData = {
        'productId': purchaseDetails.productID,
        'purchaseToken':
            purchaseDetails.verificationData.serverVerificationData,
        'platform': Platform.isAndroid ? 'android' : 'ios',
        'packageName':
            'com.yourcompany.yourapp', // Helyettesítsd a saját package neveddel
      };

      final response = await http.post(
        Uri.parse(serverUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(purchaseData),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('Szerver validáció eredménye: $result');

        // Itt aktiválhatod a premium funkciókat
        _activatePremiumFeatures(purchaseDetails.productID);
      } else {
        print('Szerver validáció sikertelen: ${response.statusCode}');
      }
    } catch (e) {
      print('Validációs hiba: $e');
      // Még ha a validáció sikertelen is, a vásárlás sikeres volt
      _activatePremiumFeatures(purchaseDetails.productID);
    }
  }

  void _activatePremiumFeatures(String productId) {
    // Itt aktiválhatod a premium funkciókat
    print('Premium funkciók aktiválva: $productId');

    // Például: SharedPreferences-ben elmenteni, hogy aktív az előfizetés
    // Vagy navigálni a főoldalra
    // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomeScreen()));
  }

  Future<void> _buyProduct(String productId) async {
    if (_purchasePending) return;

    try {
      final productDetails = _products.firstWhere(
        (product) => product.id == productId,
      );

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );

      setState(() {
        _purchasePending = true;
        _errorMessage = '';
      });

      // Előfizetés vásárlása
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      setState(() {
        _purchasePending = false;
        _errorMessage = 'Vásárlási hiba: $e';
      });
    }
  }

  void _showSuccessDialog(String productId) {
    final planName = productId == 'monthly_plan' ? 'Havi' : 'Éves';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sikeres vásárlás!'),
        content: Text('$planName előfizetés sikeresen aktiválva!'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Itt navigálhatsz a főoldalra
            },
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
    try {
      final product = _products.firstWhere((p) => p.id == productId);
      return product.price;
    } catch (e) {
      return productId == 'monthly_plan' ? '2990 Ft' : '24990 Ft';
    }
  }

  String _getProductTitle(String productId) {
    try {
      final product = _products.firstWhere((p) => p.id == productId);
      return product.title;
    } catch (e) {
      return productId == 'monthly_plan'
          ? 'Havi előfizetés'
          : 'Éves előfizetés';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 550;

    return Scaffold(
      backgroundColor: Colors.blue.shade900,
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
                      // Logo és cím
                      Container(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            Icon(
                              Icons.star,
                              size: isSmallScreen ? 60 : 80,
                              color: Colors.yellow,
                            ),
                            SizedBox(height: isSmallScreen ? 12 : 16),
                            Text(
                              'PREMIUM',
                              style: GoogleFonts.montserrat(
                                textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: isSmallScreen ? 36 : 48,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              'ELŐFIZETÉS',
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  color: Colors.white70,
                                  fontSize: isSmallScreen ? 18 : 24,
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
                                'monthly_plan',
                                'Havi csomag',
                                _getProductPrice('monthly_plan'),
                                'hónap',
                                false,
                                isSmallScreen,
                              ),

                              const SizedBox(height: 16),

                              // Éves csomag
                              _buildPlanCard(
                                'yearly_plan',
                                'Éves csomag',
                                _getProductPrice('yearly_plan'),
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

                              // Vásárlás gomb
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: (_available && !_purchasePending)
                                      ? () => _buyProduct(_selectedPlan)
                                      : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue.shade900,
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
                                              'Vásárlás folyamatban...',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        )
                                      : Text(
                                          'Előfizetés vásárlása',
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

                              // Vásárlások visszaállítása gomb
                              SizedBox(
                                width: double.infinity,
                                child: TextButton(
                                  onPressed: _available
                                      ? _restorePurchases
                                      : null,
                                  child: Text(
                                    'Vásárlások visszaállítása',
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
                          // Navigálj az ÁSZF oldalra
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
            color: isSelected ? Colors.blue.shade900 : Colors.grey.shade300,
            width: isSelected ? 3 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.blue.shade50 : Colors.white,
        ),
        child: Row(
          children: [
            Radio<String>(
              value: planId,
              groupValue: _selectedPlan,
              onChanged: (value) => setState(() => _selectedPlan = value!),
              activeColor: Colors.blue.shade900,
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
    if (_available) {
      _subscription.cancel();
    }
    super.dispose();
  }
}
