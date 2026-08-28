import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:farmer_app/core/providers/language_provider.dart';
import 'package:farmer_app/main.dart';
import 'package:farmer_app/features/auth/presentation/farmer_register_screen.dart';
import 'package:farmer_app/features/auth/presentation/fpo_register_screen.dart';
import 'package:farmer_app/features/auth/presentation/login_screen.dart';
import 'package:farmer_app/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:farmer_app/features/navigation/main_navigation_screen.dart';
import 'package:farmer_app/features/marketplace/presentation/add_product_screen.dart';
import 'package:farmer_app/features/marketplace/presentation/inspection_report_screen.dart';
import 'package:farmer_app/features/marketplace/presentation/warehouse_sale_screen.dart';
import 'package:farmer_app/features/marketplace/presentation/order_action_splash_page.dart';
import 'package:farmer_app/features/marketplace/presentation/order_details_screen.dart';
import 'package:farmer_app/features/marketplace/presentation/orders_tab.dart';
import 'package:farmer_app/features/reports/presentation/sales_report_screen.dart';
import 'package:farmer_app/core/models/user_role.dart';
import 'package:farmer_app/core/models/user_profile.dart';

Finder fieldByLabel(String label) {
  return find.descendant(
    of: find.widgetWithText(CustomTextField, label),
    matching: find.byType(EditableText),
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Welcome screen smoke test and login navigation', (WidgetTester tester) async {
    await tester.pumpWidget(const FarmerApp());
    await tester.pumpAndSettle();

    // Verify key action buttons and English text are present
    expect(find.text('Login as Farmer'), findsOneWidget);
    expect(find.text('Login as FPO'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
    expect(find.text('An Initiative of Government of India'), findsOneWidget);

    // Test navigation to Farmer Login
    await tester.tap(find.text('Login as Farmer'));
    await tester.pumpAndSettle();

    expect(find.text('Farmer User ID'), findsOneWidget);
    expect(find.text('Login using Fingerprint'), findsOneWidget);
    expect(find.text('Login with User ID & PIN'), findsOneWidget);
  });

  testWidgets('Farmer Homepage with Floating Navigation Bar renders all elements accurately in English', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LanguageProvider(),
        child: const MaterialApp(
          home: MainNavigationScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Header elements
    expect(find.text('Hello Farmer! \u{1F44B}'), findsOneWidget);
    expect(find.text('Madhya Pradesh'), findsOneWidget);
    expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);

    // Test Notification screen opening
    await tester.tap(find.byIcon(Icons.notifications_none_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('New Order Received for Wheat'), findsOneWidget);
    expect(find.text('Order #ORD12345 Accepted'), findsOneWidget);
    expect(find.text('₹ 560 Credited to Kisan Wallet'), findsOneWidget);
    expect(find.text('Low Stock Warning: Tomatoes'), findsOneWidget);
    expect(find.text('Weekly Sales & Mandi Report Ready'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    // 2. Hero Banner elements
    expect(find.text('Sell Your Produce'), findsOneWidget);
    expect(find.text('Directly to Buyers'), findsOneWidget);
    expect(find.text('Add Product'), findsOneWidget);

    // 3. Metric Stats Row elements
    expect(find.text('Total Products'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
    expect(find.text('Total Orders'), findsOneWidget);
    expect(find.text('8'), findsOneWidget);
    expect(find.text('Total Sales'), findsOneWidget);
    expect(find.text('₹ 25,680'), findsOneWidget);

    // 4. Today's Overview elements
    expect(find.text("Today's Overview"), findsOneWidget);
    expect(find.text('New Orders'), findsOneWidget);
    expect(find.text('In Processing'), findsOneWidget);
    expect(find.text('Completed'), findsOneWidget);

    // 5. Live Mandi Rates
    expect(find.text('Live Mandi Rates'), findsOneWidget);

    // 7. Floating Navigation Bar items
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('My Products'), findsOneWidget);
    expect(find.text('Orders'), findsOneWidget);
    expect(find.text('Wallet'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    // 8. Test Tab Switching to My Products
    await tester.tap(find.text('My Products'));
    await tester.pumpAndSettle();
    expect(find.text('Wheat (Local Quality)'), findsOneWidget);
    expect(find.text('Tomatoes'), findsOneWidget);
    expect(find.text('Yellow Soyabean'), findsOneWidget);
    expect(find.text('Chana Dal'), findsOneWidget);
    expect(find.text('Add New Product'), findsOneWidget);

    // Test filter pills
    await tester.tap(find.byKey(const ValueKey('filter_pill_Quality Verified')));
    await tester.pumpAndSettle();
    expect(find.text('Wheat (Local Quality)'), findsOneWidget);
    expect(find.text('Yellow Soyabean'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('filter_pill_Under Inspection')));
    await tester.pumpAndSettle();
    expect(find.text('Yellow Soyabean'), findsOneWidget);
    expect(find.text('Wheat (Local Quality)'), findsNothing);

    final soldPill = find.byKey(const ValueKey('filter_pill_Sold to Warehouse'));
    await tester.ensureVisible(soldPill);
    await tester.tap(soldPill);
    await tester.pumpAndSettle();
    expect(find.text('Chana Dal'), findsOneWidget);
    expect(find.text('Yellow Soyabean'), findsNothing);

    final allPill = find.byKey(const ValueKey('filter_pill_All'));
    await tester.ensureVisible(allPill);
    await tester.tap(allPill);
    await tester.pumpAndSettle();
    expect(find.text('Wheat (Local Quality)'), findsOneWidget);
    expect(find.text('Chana Dal'), findsOneWidget);

    await tester.tap(find.text('Orders'));
    await tester.pumpAndSettle();
    expect(find.text('My Orders'), findsOneWidget);
    expect(find.text('Central Warehousing Corp (CWC) Sehore'), findsOneWidget);
    expect(find.text('National Agro Warehousing Corp (NAWC) Hub'), findsOneWidget);
    expect(find.text('Wheat (Grade A) - 50 Qtl'), findsOneWidget);
    expect(find.text('₹ 1,42,500'), findsOneWidget);
    expect(find.text('MP State Warehousing & Logistics Godown #4'), findsOneWidget);
    expect(find.text('Apex State Warehouse Yard #2, Ujjain'), findsOneWidget);

    // Test View Details screen on Warehouse Order
    await tester.tap(find.text('Central Warehousing Corp (CWC) Sehore'));
    await tester.pumpAndSettle();
    expect(find.text('Order Details'), findsOneWidget);
    expect(find.text('Warehouse Information'), findsOneWidget);
    expect(find.text('Central Warehousing Corp (CWC) Sehore'), findsOneWidget);
    expect(find.text('+91 75622 98140'), findsOneWidget);
    expect(find.text('Accredited Godown'), findsOneWidget);
    expect(find.text('Accept Order'), findsOneWidget);
    expect(find.text('Decline Order'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    // Test Orders filter pills
    final newPill = find.byKey(const ValueKey('orders_filter_New'));
    await tester.ensureVisible(newPill);
    await tester.tap(newPill);
    await tester.pumpAndSettle();
    expect(find.text('Central Warehousing Corp (CWC) Sehore'), findsOneWidget);
    expect(find.text('MP State Warehousing & Logistics Godown #4'), findsNothing);

    final inProcPill = find.byKey(const ValueKey('orders_filter_In Processing'));
    await tester.ensureVisible(inProcPill);
    await tester.tap(inProcPill);
    await tester.pumpAndSettle();
    expect(find.text('MP State Warehousing & Logistics Godown #4'), findsOneWidget);
    expect(find.text('Central Warehousing Corp (CWC) Sehore'), findsNothing);

    final allOrdersPill = find.byKey(const ValueKey('orders_filter_All'));
    await tester.ensureVisible(allOrdersPill);
    await tester.tap(allOrdersPill);
    await tester.pumpAndSettle();
    expect(find.text('Central Warehousing Corp (CWC) Sehore'), findsOneWidget);
    expect(find.text('MP State Warehousing & Logistics Godown #4'), findsOneWidget);

    await tester.tap(find.text('Wallet'));
    await tester.pumpAndSettle();
    expect(find.text('My Wallet'), findsOneWidget);
    expect(find.text('Total Balance'), findsOneWidget);
    expect(find.text('₹ 25,680'), findsWidgets);
    expect(find.text('Withdraw'), findsOneWidget);
    expect(find.text('Recent Transactions'), findsOneWidget);
    expect(find.text('Order #ORD12345'), findsOneWidget);
    expect(find.text('+ ₹ 560'), findsOneWidget);
    expect(find.text('Withdrawal'), findsOneWidget);
    expect(find.text('- ₹ 2,000'), findsOneWidget);

    // Test Sales Report navigation from Wallet
    await tester.tap(find.text('View Detailed Sales Report'));
    await tester.pumpAndSettle();
    expect(find.text('Sales Report'), findsOneWidget);
    expect(find.text('Total Sales'), findsOneWidget);
    expect(find.text('Total Orders'), findsOneWidget);
    expect(find.text('Total Produce'), findsOneWidget);
    expect(find.text('Sales Trend'), findsOneWidget);
    expect(find.text('Top Performing Crops'), findsOneWidget);
    expect(find.text('Wheat (Local Quality)'), findsOneWidget);
    expect(find.text('Tomatoes (Fresh Farm)'), findsOneWidget);
    expect(find.text('Download Tax & Mandi Statement (PDF)'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Personal Information'), findsOneWidget);
    expect(find.text('Bank Details'), findsOneWidget);
    expect(find.text('Address & Farm Location'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Help & Support'), findsOneWidget);
    expect(find.text('Log Out'), findsOneWidget);

    // Switch back to Home
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Sell Your Produce'), findsOneWidget);
  });

  testWidgets('AddNewProductScreen uploads produce without price input and requests quality inspection', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    bool productAdded = false;

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LanguageProvider(),
        child: MaterialApp(
          home: AddNewProductScreen(
            onProductAdded: (prod) {
              productAdded = true;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Header
    expect(find.text('Add New Product'), findsOneWidget);

    // 2. Inspection valuation notice
    expect(find.text('No Price Required from Farmer'), findsOneWidget);

    // 3. Photo Upload Card
    expect(find.text('Add Photo'), findsOneWidget);

    // 4. Form Labels (No Price field required!)
    expect(find.text('Product Name'), findsOneWidget);
    expect(find.text('Category'), findsOneWidget);
    expect(find.text('Quantity to Sell'), findsOneWidget);
    expect(find.text('Farm Pickup Location'), findsOneWidget);
    expect(find.text('Description (Optional)'), findsOneWidget);
    expect(find.text('Submit for Quality Inspection'), findsOneWidget);

    // Fill form
    final textFields = find.byType(TextFormField);
    expect(textFields, findsNWidgets(4)); // Name, Quantity, Location, Description

    // Product Name
    await tester.enterText(textFields.at(0), 'Sharbati Wheat');
    await tester.pump();

    // Select category
    final categoryDropdown = find.byType(DropdownButtonFormField<String>).first;
    await tester.ensureVisible(categoryDropdown);
    await tester.tap(categoryDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Grains (अनाज)').last);
    await tester.pumpAndSettle();

    // Quantity
    await tester.enterText(textFields.at(1), '100');
    await tester.pump();

    // Description
    await tester.enterText(textFields.at(3), 'Freshly harvested Sharbati wheat from Sehore field.');
    await tester.pump();

    // Submit for inspection
    await tester.ensureVisible(find.text('Submit for Quality Inspection'));
    await tester.tap(find.text('Submit for Quality Inspection'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(productAdded, isTrue);
  });

  testWidgets('InspectionReportScreen displays quality parameters, grade, and allows simulated inspector grading', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockProduct = {
      'name': 'Sharbati Wheat',
      'quantity': '50 Qtl',
      'price': 'Pending Inspection',
      'assessedPrice': null,
      'totalValue': 'Awaiting Inspection',
      'grade': 'Under Inspection',
      'location': 'Sehore Farm Gate, MP',
      'status': 'Under Inspection',
      'inspectionReport': {
        'status': 'Scheduled',
        'inspector': 'Er. Ankit Sharma (Govt Agri QC)',
        'lab': 'Sehore APMC Quality Testing Lab #4',
        'certNo': 'AGRI-QC-PENDING-99',
        'visitDate': 'Tomorrow, 10:30 AM',
      },
    };

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LanguageProvider(),
        child: MaterialApp(
          home: InspectionReportScreen(product: mockProduct),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Quality Inspection Report'), findsOneWidget);
    expect(find.text('Under Inspection'), findsOneWidget);
    expect(find.text('Inspection Schedule Details'), findsOneWidget);
    expect(find.text('Er. Ankit Sharma (Govt Agri QC)'), findsOneWidget);

    // Simulate inspection completion
    final verifyButton = find.text('Verify Quality & Assign Grade A');
    await tester.ensureVisible(verifyButton);
    await tester.tap(verifyButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    expect(find.text('Quality Verified'), findsOneWidget);
    expect(find.text('Lab Quality Metrics'), findsOneWidget);
    expect(find.text('11.2%'), findsOneWidget);
    expect(find.text('98.8%'), findsOneWidget);
    expect(find.text('Official Quality Grading Certificate'), findsOneWidget);
    expect(find.text('Incoming Warehouse Orders'), findsOneWidget);
    expect(find.textContaining('Review & Accept Warehouse Orders'), findsOneWidget);
  });

  testWidgets('WarehouseSaleScreen enables selling verified produce to authorized warehouses and generating e-NWR receipt', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final verifiedProduct = {
      'name': 'Sharbati Wheat',
      'quantity': '50 Qtl',
      'price': '₹ 2,850 / Qtl',
      'assessedPrice': '₹ 2,850 / Qtl',
      'totalValue': '₹ 1,42,500',
      'grade': 'Grade A',
      'status': 'Quality Verified',
      'inspectionReport': {
        'certNo': 'AGRI-QC-892410',
        'assessedRate': '₹ 2,850 / Qtl',
      },
    };

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LanguageProvider(),
        child: MaterialApp(
          home: WarehouseSaleScreen(product: verifiedProduct),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Warehouse Purchase Orders'), findsOneWidget);
    expect(find.text('Central Warehousing Corp (CWC) Sehore'), findsOneWidget);
    expect(find.text('PO-CWC-2026-9814'), findsOneWidget);
    expect(find.text('Total Estimated Payout'), findsOneWidget);
    expect(find.text('₹ 142,500'), findsOneWidget);

    // Tap confirm warehouse sale
    final confirmBtn = find.text('Accept Warehouse Order & Sell');
    await tester.ensureVisible(confirmBtn);
    await tester.tap(confirmBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1100));
    await tester.pumpAndSettle();

    // Verify e-NWR receipt bottom sheet
    expect(find.text('Produce Sold to Warehouse!'), findsOneWidget);
    expect(find.text('Electronic Warehouse Receipt'), findsOneWidget);
    expect(find.text('WDRA Verified'), findsOneWidget);
    expect(find.text('PO-CWC-2026-9814'), findsWidgets);
    expect(find.text('Done & View Inventory'), findsOneWidget);
  });

  testWidgets('Farmer Registration screen step progression test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: FarmerRegisterScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Step 1: Aadhaar
    expect(find.text('Step 1: Aadhaar e-KYC'), findsOneWidget);
    expect(find.text('Verify Aadhaar'), findsOneWidget);

    // Enter Aadhaar
    await tester.enterText(fieldByLabel('Aadhaar Card Number'), '123456789012');
    await tester.pump();
    await tester.tap(find.text('Verify Aadhaar'));
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    expect(find.text('Rameshwar Kisan Patil'), findsOneWidget);
    expect(find.text('Proceed to Farmer ID'), findsOneWidget);

    // Step 2: Farmer ID
    await tester.tap(find.text('Proceed to Farmer ID'));
    await tester.pumpAndSettle();

    expect(find.text('Step 2: Farmer ID / PM-KISAN'), findsOneWidget);
    await tester.enterText(fieldByLabel('Farmer ID / PM-KISAN Beneficiary ID'), 'FID-2026-MH90');
    await tester.pump();
    await tester.tap(find.text('Verify Farmer ID'));
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    expect(find.text('Proceed to Mobile OTP'), findsOneWidget);

    // Step 3: Mobile OTP
    await tester.tap(find.text('Proceed to Mobile OTP'));
    await tester.pumpAndSettle();

    expect(find.text('Step 3: Mobile Number & OTP'), findsOneWidget);
    await tester.enterText(fieldByLabel('Mobile Number'), '9876543210');
    await tester.pump();
    await tester.tap(find.text('Send Verification OTP'));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    expect(find.text('Verify OTP'), findsOneWidget);
    await tester.enterText(fieldByLabel('Enter 6-Digit OTP'), '123456');
    await tester.pump();
    await tester.tap(find.text('Verify OTP'));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    expect(find.text('Proceed to Credentials'), findsOneWidget);

    // Step 4: Set Credentials
    await tester.tap(find.text('Proceed to Credentials'));
    await tester.pumpAndSettle();

    expect(find.text('Step 4: Create Credentials'), findsOneWidget);
    expect(find.text('Enable Fingerprint Login'), findsOneWidget);

    // Fill credentials
    await tester.enterText(fieldByLabel('Choose User ID / Username'), 'ramesh_patil');
    await tester.enterText(fieldByLabel('Set 4-Digit Security PIN'), '1234');
    await tester.enterText(fieldByLabel('Confirm 4-Digit Security PIN'), '1234');
    await tester.pump();

    final completeBtn = find.text('Complete Farmer Registration');
    await tester.ensureVisible(completeBtn);
    await tester.tap(completeBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Verify registration success dialog
    expect(find.text('Registration Successful!'), findsOneWidget);
  });

  testWidgets('FPO Registration screen step progression test', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      const MaterialApp(
        home: FpoRegisterScreen(),
      ),
    );
    await tester.pumpAndSettle();

    // Step 1: GSTIN
    expect(find.text('Step 1: FPO GSTIN'), findsOneWidget);
    expect(find.text('Verify FPO GSTIN'), findsOneWidget);

    // Enter GSTIN
    await tester.enterText(fieldByLabel('FPO GSTIN'), '27AAAAA0000A1Z5');
    await tester.pump();
    await tester.tap(find.text('Verify FPO GSTIN'));
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();

    expect(find.text('Sahyadri Agro Farmer Producer Company Ltd.'), findsOneWidget);
    expect(find.text('Proceed to Mobile OTP'), findsOneWidget);

    // Step 2: Mobile OTP
    await tester.tap(find.text('Proceed to Mobile OTP'));
    await tester.pumpAndSettle();

    expect(find.text('Step 2: Authorized Mobile & OTP'), findsOneWidget);
    await tester.enterText(fieldByLabel('Mobile Number'), '9876543210');
    await tester.pump();
    await tester.tap(find.text('Send Verification OTP'));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    expect(find.text('Verify OTP'), findsOneWidget);
    await tester.enterText(fieldByLabel('Enter 6-Digit OTP'), '123456');
    await tester.pump();
    await tester.tap(find.text('Verify OTP'));
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpAndSettle();

    expect(find.text('Proceed to Credentials'), findsOneWidget);

    // Step 3: Set Credentials
    await tester.tap(find.text('Proceed to Credentials'));
    await tester.pumpAndSettle();

    expect(find.text('Step 3: Create FPO Credentials'), findsOneWidget);
    await tester.enterText(fieldByLabel('Choose FPO User ID / Username'), 'sahyadri_fpo');
    await tester.enterText(fieldByLabel('Set 4-Digit Security PIN'), '4321');
    await tester.enterText(fieldByLabel('Confirm 4-Digit Security PIN'), '4321');
    await tester.pump();

    final completeBtn = find.text('Complete FPO Registration');
    await tester.ensureVisible(completeBtn);
    await tester.tap(completeBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('FPO Registered!'), findsOneWidget);
  });

  testWidgets('Login screen supports switching roles and credential validation', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(initialRole: UserRole.farmer),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Farmer User ID'), findsOneWidget);
    expect(find.text('Login using Fingerprint'), findsOneWidget);

    // Switch to FPO
    await tester.tap(find.text('FPO'));
    await tester.pumpAndSettle();

    expect(find.text('FPO User ID'), findsOneWidget);
  });

  testWidgets('Switching app language from Profile tab updates the entire app dynamically', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final languageProvider = LanguageProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: languageProvider,
        child: const MaterialApp(
          home: MainNavigationScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Initial English labels
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);

    // 2. Navigate to Profile
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('My Profile'), findsOneWidget);
    expect(find.text('Language'), findsOneWidget);

    // 3. Open Language Picker
    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();

    expect(find.text('Select Language (भाषा चुनें)'), findsOneWidget);
    expect(find.text('Hindi (हिंदी)'), findsOneWidget);

    // 4. Switch to Hindi
    await tester.tap(find.text('Hindi (हिंदी)'));
    await tester.pumpAndSettle();

    // 5. Verify Profile and Nav bar are immediately translated to Hindi
    expect(find.text('मेरा प्रोफाइल'), findsOneWidget);
    expect(find.text('रामेश्वर सिंह'), findsOneWidget);
    expect(find.text('सीहोर, मध्य प्रदेश'), findsOneWidget);
    expect(find.text('कृषि भूमि और फसल बीमा'), findsOneWidget);
    expect(find.text('4.5 एकड़ (काली मिट्टी)'), findsOneWidget);
    expect(find.text('सक्रिय (सीमा ₹3,00,000)'), findsOneWidget);
    expect(find.text('बीमाकृत (रबी 2026)'), findsOneWidget);
    expect(find.text('गेहूं, सोयाबीन, टमाटर'), findsOneWidget);
    expect(find.text('खरीफ और रबी'), findsOneWidget);
    expect(find.text('होम'), findsOneWidget);
    expect(find.text('प्रोफाइल'), findsOneWidget);

    // 6. Switch to Home tab and verify Hindi text & Mandi rates
    await tester.tap(find.text('होम'));
    await tester.pumpAndSettle();

    expect(find.text('नमस्ते किसान! \u{1F44B}'), findsOneWidget);
    expect(find.text('अपनी उपज बेचें'), findsOneWidget);
    expect(find.text('उत्पाद जोड़ें'), findsOneWidget);
    expect(find.text('शरबती गेहूं'), findsOneWidget);
    expect(find.text('पीली सोयाबीन'), findsOneWidget);

    // 7. Switch to My Products tab and verify vegetables, fruits, and grains in Hindi
    await tester.tap(find.text('मेरे उत्पाद'));
    await tester.pumpAndSettle();

    expect(find.text('गेहूं (देसी क्वालिटी)'), findsOneWidget);
    expect(find.text('टमाटर (Tomatoes)'), findsOneWidget);
    expect(find.text('आलू (Potatoes)'), findsOneWidget);
    expect(find.text('चना दाल (Chana Dal)'), findsOneWidget);
  });

  testWidgets('Order acceptance and completion trigger OrderActionSplashPage with Lottie packaging and success states', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final mockOrder = {
      'id': '#ORD99999',
      'buyer': 'Fresh Mandi Logistics',
      'items': 'Wheat - 50 Kg',
      'amount': '₹ 1,400',
      'date': '22 May 2026, 11:00 AM',
      'status': 'New',
      'phone': '+91 98765 43210',
      'address': 'Bhopal Agro Terminal, MP',
      'paymentStatus': 'Escrow Secured',
    };

    // 1. Render Order Details for New Order
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ],
        child: MaterialApp(
          home: OrderDetailsScreen(order: mockOrder),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Accept Order'), findsOneWidget);
    expect(find.text('Decline Order'), findsOneWidget);

    // 2. Tap Accept Order -> Navigates to Packaging splash page
    await tester.tap(find.text('Accept Order'));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.byType(OrderActionSplashPage), findsOneWidget);
    expect(find.text('Order Accepted!'), findsOneWidget);
    expect(find.text('Packaging for Delivery in Progress'), findsOneWidget);
    expect(find.text('#ORD99999'), findsOneWidget);
    expect(find.text('₹ 1,400'), findsOneWidget);

    // 3. Dismiss splash page back to Order Details
    await tester.tap(find.text('Back to My Orders'));
    await tester.pumpAndSettle();

    // 4. Order is now In Processing, verify Delivery button appears
    expect(find.text('Mark as Delivered & Complete'), findsOneWidget);

    // 5. Tap Mark as Delivered -> Navigates to Success splash page
    await tester.tap(find.text('Mark as Delivered & Complete'));
    await tester.pump(const Duration(milliseconds: 350));
    await tester.pumpAndSettle();

    expect(find.byType(OrderActionSplashPage), findsOneWidget);
    expect(find.text('Delivery Completed!'), findsOneWidget);
    expect(find.text('Payment Credited to Wallet'), findsOneWidget);

    // 6. Dismiss splash page
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    expect(find.text('Completed'), findsWidgets);
  });

  testWidgets('SalesReportScreen graph and metrics dynamically change according to timeline selection', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ],
        child: const MaterialApp(
          home: SalesReportScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Default is This Month (1M)
    expect(find.text('₹ 25,680'), findsOneWidget);
    expect(find.text('18'), findsOneWidget);
    expect(find.text('+14.8% growth'), findsOneWidget);
    expect(find.text('1 May'), findsOneWidget);

    // Switch to This Week (1W)
    await tester.tap(find.text('1W'));
    await tester.pumpAndSettle();
    expect(find.text('₹ 6,240'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);
    expect(find.text('+8.5% this week'), findsOneWidget);
    expect(find.text('Mon'), findsOneWidget);

    // Switch to Last 3 Months (3M)
    await tester.tap(find.text('3M'));
    await tester.pumpAndSettle();
    expect(find.text('₹ 78,500'), findsOneWidget);
    expect(find.text('54'), findsOneWidget);
    expect(find.text('+22.3% vs prev qtr'), findsOneWidget);
    expect(find.text('March'), findsOneWidget);

    // Switch to This Year (1Y)
    await tester.tap(find.text('1Y'));
    await tester.pumpAndSettle();
    expect(find.text('₹ 2,85,000'), findsOneWidget);
    expect(find.text('192'), findsOneWidget);
    expect(find.text('+36.4% annual growth'), findsOneWidget);
    expect(find.text('Jan'), findsOneWidget);
  });

  testWidgets('WalletTab enables adding new bank account with DBT verification', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ],
        child: const MaterialApp(
          home: MainNavigationScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Navigate to Wallet
    await tester.tap(find.text('Wallet'));
    await tester.pumpAndSettle();

    expect(find.text('Linked Bank Accounts'), findsOneWidget);
    expect(find.text('State Bank of India'), findsOneWidget);

    // Tap Add Bank Account
    await tester.tap(find.text('Add Bank Account'));
    await tester.pumpAndSettle();

    expect(find.text('Account Holder Name'), findsOneWidget);
    expect(find.text('Select Bank'), findsOneWidget);
    expect(find.text('Account Number'), findsOneWidget);
    expect(find.text('IFSC Code'), findsOneWidget);
    expect(find.text('Verify & Link Bank Account'), findsOneWidget);

    // Fill in new bank account
    final textFields = find.byType(TextField);
    await tester.enterText(textFields.at(1), '50100234567890');
    await tester.enterText(textFields.at(2), '50100234567890');
    await tester.enterText(textFields.at(3), 'HDFC0001234');
    await tester.pumpAndSettle();

    // Submit
    await tester.ensureVisible(find.text('Verify & Link Bank Account'));
    await tester.tap(find.text('Verify & Link Bank Account'));
    await tester.pumpAndSettle();

    // Verify newly added account is visible in Linked Bank Accounts
    expect(find.textContaining('7890'), findsOneWidget);
    expect(find.textContaining('HDFC0001234'), findsOneWidget);
  });

  testWidgets('App automatically restores saved login session across app restarts', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    // 1. First scenario: No user logged in -> WelcomeScreen shows
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(FarmerApp(key: UniqueKey()));
    await tester.pumpAndSettle();

    expect(find.text('Login as Farmer'), findsOneWidget);
    expect(find.text('Login as FPO'), findsOneWidget);

    // 2. Second scenario: User has an active saved session -> boots straight to Dashboard
    final savedUser = UserProfile(
      userId: 'farmer_rajesh',
      pin: '1234',
      role: UserRole.farmer,
      fullName: 'Rajesh Kisan Patil',
      mobileNumber: '9876543210',
      farmerId: 'FID-MH-2026-90',
    );
    SharedPreferences.setMockInitialValues({
      'current_logged_in_user': savedUser.toJson(),
    });

    await tester.pumpWidget(FarmerApp(key: UniqueKey()));
    await tester.pump(const Duration(milliseconds: 4500));
    await tester.pumpAndSettle();

    // Directly on Farmer Homepage without welcome screen
    expect(find.text('Hello Rajesh Kisan Patil! \u{1F44B}'), findsOneWidget);
    expect(find.text('Login as Farmer'), findsNothing);
  });

  testWidgets('OrdersTab displays incoming Warehouse Purchase Orders with locked QC rate and details', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => LanguageProvider(),
        child: const MaterialApp(
          home: OrdersTab(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Orders tab rendered
    expect(find.text('My Orders'), findsOneWidget);

    // Verify Warehouse Purchase Orders are shown
    expect(find.textContaining('PO-CWC-2026-9814'), findsWidgets);
    expect(find.text('Central Warehousing Corp (CWC) Sehore'), findsOneWidget);
    expect(find.text('₹ 1,42,500'), findsOneWidget);
    expect(find.byIcon(Icons.warehouse_rounded), findsWidgets);

    // Filter by New Warehouse Orders
    final newFilter = find.byKey(const ValueKey('orders_filter_New'));
    await tester.ensureVisible(newFilter);
    await tester.tap(newFilter);
    await tester.pumpAndSettle();

    expect(find.text('Central Warehousing Corp (CWC) Sehore'), findsOneWidget);
    expect(find.text('National Agro Warehousing Corp (NAWC) Hub'), findsOneWidget);
    expect(find.text('MP State Warehousing & Logistics Godown #4'), findsNothing);

    // Tap on warehouse order to view details
    await tester.tap(find.text('Central Warehousing Corp (CWC) Sehore'));
    await tester.pumpAndSettle();

    expect(find.text('Order Details'), findsOneWidget);
    expect(find.text('Warehouse Information'), findsOneWidget);
    expect(find.text('Accredited Godown'), findsOneWidget);
    expect(find.text('+91 75622 98140'), findsOneWidget);
    expect(find.text('Central Warehousing Corp (CWC) Sehore'), findsOneWidget);
  });
}
