import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/balance_card_widget.dart';
import './widgets/payment_settings_widget.dart';
import './widgets/qr_scanner_widget.dart';
import './widgets/receive_qr_widget.dart';
import './widgets/security_settings_widget.dart';
import './widgets/transaction_item_widget.dart';

class SolanaWallet extends StatefulWidget {
  const SolanaWallet({Key? key}) : super(key: key);

  @override
  State<SolanaWallet> createState() => _SolanaWalletState();
}

class _SolanaWalletState extends State<SolanaWallet>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Mock wallet data
  double _solBalance = 12.5847;
  double _usdValue = 2156.32;
  bool _isBackedUp = true;
  bool _biometricEnabled = true;
  bool _autoPayEnabled = true;
  double _autoPayLimit = 50.0;

  final String _walletAddress = "9WzDXwBbmkg8ZTbNMqUxvQRAyrZzDsGYdLVL9zYtAWWM";

  final List<Map<String, dynamic>> _transactions = [
    {
      "id": "tx_001",
      "type": "sent",
      "amount": 0.5,
      "providerName": "Dr. Sarah Johnson - Consultation",
      "timestamp": DateTime.now().subtract(const Duration(hours: 2)),
      "status": "completed",
      "txHash": "5KJp89B4owHyGzxggh7VXABdJBTtjVEpLG9mPioCuoc",
    },
    {
      "id": "tx_002",
      "type": "sent",
      "amount": 0.25,
      "providerName": "MedPharm - Prescription",
      "timestamp": DateTime.now().subtract(const Duration(days: 1)),
      "status": "completed",
      "txHash": "3NMvAhrskGXxs1nHrhjoBrzDrAhi62B2nsU7CqR7TJoC",
    },
    {
      "id": "tx_003",
      "type": "received",
      "amount": 5.0,
      "providerName": "Wallet Top-up",
      "timestamp": DateTime.now().subtract(const Duration(days: 2)),
      "status": "completed",
      "txHash": "7xKQRNvydHG8k4GdQtW5KjxMnBV3RuFvCpan65t1cxCs",
    },
    {
      "id": "tx_004",
      "type": "sent",
      "amount": 0.75,
      "providerName": "HealthLab - Blood Test",
      "timestamp": DateTime.now().subtract(const Duration(days: 3)),
      "status": "pending",
      "txHash": "2GQkKw8ovadhihTGMZHZjRD17TeTaHLobyDgHGY1CtG",
    },
    {
      "id": "tx_005",
      "type": "sent",
      "amount": 0.3,
      "providerName": "Dr. Michael Chen - Follow-up",
      "timestamp": DateTime.now().subtract(const Duration(days: 5)),
      "status": "failed",
      "txHash": "4VqNMa1A3VqoCuTT4v2jMuVZ5QQzqX2FHG8CrC2gSRpw",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showQrScanner() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => QrScannerWidget(
        onQrScanned: (qrData) {
          Navigator.pop(context);
          _processQrPayment(qrData);
        },
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  void _showReceiveQr() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ReceiveQrWidget(
        walletAddress: _walletAddress,
        onClose: () => Navigator.pop(context),
      ),
    );
  }

  void _processQrPayment(String qrData) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Processing payment to: ${qrData.substring(0, 20)}...'),
        backgroundColor: AppTheme.lightTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _addFunds() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Funds'),
        content: const Text(
            'This will redirect you to our secure payment partner to add SOL to your wallet.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Redirecting to payment gateway...'),
                  backgroundColor: AppTheme.lightTheme.primaryColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _sendSol() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Send SOL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose how you want to send SOL:'),
            SizedBox(height: 2.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showQrScanner();
                    },
                    icon: CustomIconWidget(
                      iconName: 'qr_code_scanner',
                      color: Colors.white,
                      size: 20,
                    ),
                    label: const Text('Scan QR'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.lightTheme.primaryColor,
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              const Text('Manual send feature coming soon'),
                          backgroundColor: AppTheme.lightTheme.primaryColor,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                    icon: CustomIconWidget(
                      iconName: 'edit',
                      color: AppTheme.lightTheme.primaryColor,
                      size: 20,
                    ),
                    label: const Text('Manual'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _viewTransactionDetails(Map<String, dynamic> transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transaction Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Provider: ${transaction['providerName']}'),
            SizedBox(height: 1.h),
            Text('Amount: ${transaction['amount']} SOL'),
            SizedBox(height: 1.h),
            Text('Status: ${transaction['status'].toString().toUpperCase()}'),
            SizedBox(height: 1.h),
            Text('Transaction Hash:'),
            Text(
              transaction['txHash'],
              style: AppTheme.getDataTextStyle(
                isLight: true,
                fontSize: 12.sp,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Opening Solana Explorer...'),
                  backgroundColor: AppTheme.lightTheme.primaryColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            child: const Text('View on Explorer'),
          ),
        ],
      ),
    );
  }

  void _generateReceipt(Map<String, dynamic> transaction) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Receipt generated for ${transaction['providerName']}'),
        backgroundColor: AppTheme.successLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _backupWallet() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Backup Wallet'),
        content: const Text(
            'Your wallet backup will be securely stored. Make sure to write down your seed phrase in a safe place.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isBackedUp = true;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Wallet backed up successfully'),
                  backgroundColor: AppTheme.successLight,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              );
            },
            child: const Text('Backup'),
          ),
        ],
      ),
    );
  }

  void _viewSeedPhrase() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seed Phrase'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.warningLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.warningLight.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'warning',
                    color: AppTheme.warningLight,
                    size: 20,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Never share your seed phrase with anyone!',
                      style: AppTheme.getWarningTextStyle(
                        isLight: true,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline
                      .withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                'abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon abandon about',
                style: AppTheme.getDataTextStyle(
                  isLight: true,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _managePaymentMethods() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Payment methods management coming soon'),
        backgroundColor: AppTheme.lightTheme.primaryColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Solana Wallet'),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: AppTheme.textPrimaryLight,
            size: 24,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showReceiveQr,
            icon: CustomIconWidget(
              iconName: 'qr_code',
              color: AppTheme.textPrimaryLight,
              size: 24,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, '/dashboard');
            },
            icon: CustomIconWidget(
              iconName: 'home',
              color: AppTheme.textPrimaryLight,
              size: 24,
            ),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Wallet'),
            Tab(text: 'Security'),
            Tab(text: 'Settings'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Wallet Tab
          SingleChildScrollView(
            child: Column(
              children: [
                BalanceCardWidget(
                  solBalance: _solBalance,
                  usdValue: _usdValue,
                  onAddFunds: _addFunds,
                  onSendSol: _sendSol,
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Transactions',
                        style:
                            AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Text(
                                  'View all transactions coming soon'),
                              backgroundColor: AppTheme.lightTheme.primaryColor,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    final transaction = _transactions[index];
                    return TransactionItemWidget(
                      transaction: transaction,
                      onTap: () => _viewTransactionDetails(transaction),
                      onViewReceipt: () => _generateReceipt(transaction),
                    );
                  },
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
          // Security Tab
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 2.h),
                SecuritySettingsWidget(
                  isBackedUp: _isBackedUp,
                  biometricEnabled: _biometricEnabled,
                  onBiometricToggle: (enabled) {
                    setState(() {
                      _biometricEnabled = enabled;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          enabled
                              ? 'Biometric authentication enabled'
                              : 'Biometric authentication disabled',
                        ),
                        backgroundColor: enabled
                            ? AppTheme.successLight
                            : AppTheme.warningLight,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                  onBackupWallet: _backupWallet,
                  onViewSeedPhrase: _viewSeedPhrase,
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
          // Settings Tab
          SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 2.h),
                PaymentSettingsWidget(
                  autoPayLimit: _autoPayLimit,
                  autoPayEnabled: _autoPayEnabled,
                  onAutoPayLimitChanged: (limit) {
                    setState(() {
                      _autoPayLimit = limit;
                    });
                  },
                  onAutoPayToggle: (enabled) {
                    setState(() {
                      _autoPayEnabled = enabled;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          enabled ? 'Auto-pay enabled' : 'Auto-pay disabled',
                        ),
                        backgroundColor: enabled
                            ? AppTheme.successLight
                            : AppTheme.warningLight,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    );
                  },
                  onManagePaymentMethods: _managePaymentMethods,
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
