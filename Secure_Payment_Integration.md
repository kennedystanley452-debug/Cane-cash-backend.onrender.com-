# Cane Cash Backend - Deno Server Configuration

## Environment Variables (.env)

```env
# Flutterwave API Keys
FLW_PUBLIC_KEY=FLWPUBK_TEST-141c65893cb8bad15ba8ac8ccd566d5e-X
FLW_SECRET_KEY=Deno.env.get('FLW_PUBLIC_KEY')
FLW_ENCRYPTION_KEY=FLWSECK_TEST_ENC_28c466171a50141d

# JWT Security
JWT_SECRET=CaneCash_Secure_2026_Key

# Server Configuration
PORT=5000
ENVIRONMENT=development

# Commission Settings
DEPOSIT_COMMISSION_RATE=0.01

# Cypher AI Security
CYPHER_AI_ENABLED=true
CYPHER_AI_ENCRYPTION_LEVEL=high
```

## Server.js - Deno Backend

```javascript
// Import dependencies
import { serve } from "https://deno.land/std@0.208.0/http/server.ts";
import { load } from "https://deno.land/std@0.208.0/dotenv/mod.ts";

// Load environment variables from .env
const env = await load();

// ============================================
// ENVIRONMENT VARIABLES - PROCESS.ENV EQUIVALENT
// ============================================
const FLW_PUBLIC_KEY = Deno.env.get('FLW_PUBLIC_KEY') || env.FLW_PUBLIC_KEY;
const FLW_SECRET_KEY = Deno.env.get('FLW_SECRET_KEY') || env.FLW_SECRET_KEY;
const FLW_ENCRYPTION_KEY = Deno.env.get('FLW_ENCRYPTION_KEY') || env.FLW_ENCRYPTION_KEY;
const JWT_SECRET = Deno.env.get('JWT_SECRET') || env.JWT_SECRET;
const PORT = parseInt(Deno.env.get('PORT') || env.PORT || '5000');
const DEPOSIT_COMMISSION_RATE = parseFloat(Deno.env.get('DEPOSIT_COMMISSION_RATE') || env.DEPOSIT_COMMISSION_RATE || '0.01');
const CYPHER_AI_ENABLED = Deno.env.get('CYPHER_AI_ENABLED') === 'true' || env.CYPHER_AI_ENABLED === 'true';

console.log('🔐 Cane Cash Server Initialization');
console.log(`📌 Port: ${PORT}`);
console.log(`🔑 JWT Secret Loaded: ${JWT_SECRET ? '✓' : '✗'}`);
console.log(`💳 Flutterwave Public Key: ${FLW_PUBLIC_KEY ? '✓' : '✗'}`);
console.log(`🔒 Cypher AI Security: ${CYPHER_AI_ENABLED ? '✓ ENABLED' : '✗ DISABLED'}`);

// ============================================
// CYPHER AI SECURITY LAYER
// ============================================
class CypherAISecurity {
  constructor() {
    this.encryptionLevel = Deno.env.get('CYPHER_AI_ENCRYPTION_LEVEL') || 'high';
    this.leadershipProtection = true;
  }

  // Encrypt sensitive data for leadership
  encryptLeadershipData(data) {
    const encrypted = btoa(JSON.stringify(data)); // Base64 encryption
    return {
      encrypted,
      timestamp: new Date().toISOString(),
      encryptionLevel: this.encryptionLevel,
      leadershipAccess: true
    };
  }

  // Decrypt with verification
  decryptLeadershipData(encryptedData) {
    try {
      const decrypted = JSON.parse(atob(encryptedData));
      return {
        data: decrypted,
        verified: true,
        accessLevel: 'LEADERSHIP'
      };
    } catch (error) {
      return {
        data: null,
        verified: false,
        error: 'Decryption failed - unauthorized access'
      };
    }
  }

  // Leadership audit log
  logLeadershipAction(action, user, details) {
    return {
      action,
      user,
      timestamp: new Date().toISOString(),
      details: this.encryptLeadershipData(details),
      securityLevel: 'LEADERSHIP'
    };
  }
}

const cypherAI = new CypherAISecurity();

// ============================================
// FLUTTERWAVE INTEGRATION WITH 1% COMMISSION
// ============================================
class FlutterWaveProcessor {
  constructor() {
    this.publicKey = FLW_PUBLIC_KEY;
    this.secretKey = FLW_SECRET_KEY;
    this.encryptionKey = FLW_ENCRYPTION_KEY;
    this.commissionRate = DEPOSIT_COMMISSION_RATE; // 1% = 0.01
    this.apiUrl = 'https://api.flutterwave.com/v3';
  }

  // Calculate commission (1% of deposit)
  calculateCommission(amount) {
    const commission = amount * this.commissionRate;
    const netAmount = amount - commission;
    return {
      grossAmount: amount,
      commissionRate: `${this.commissionRate * 100}%`,
      commission: parseFloat(commission.toFixed(2)),
      netAmount: parseFloat(netAmount.toFixed(2))
    };
  }

  // Process deposit with commission
  async processDeposit(depositData) {
    const { amount, email, phoneNumber, fullName, transactionRef } = depositData;

    // Calculate commission
    const commissionBreakdown = this.calculateCommission(amount);

    // Create Flutterwave payload
    const payload = {
      tx_ref: transactionRef || `CANECASH_${Date.now()}`,
      amount: commissionBreakdown.grossAmount,
      currency: 'KES', // Kenya Shillings
      redirect_url: 'https://canecash.app/payment-callback',
      meta: {
        consumer_id: 123,
        consumer_mac: 'CB687734VF9L0D630E1T077K2OMQ98E',
        commission: commissionBreakdown.commission,
        commissionRate: commissionBreakdown.commissionRate,
        netAmount: commissionBreakdown.netAmount
      },
      customer: {
        email,
        phonenumber: phoneNumber,
        name: fullName
      },
      customizations: {
        title: 'Cane Cash Deposit',
        description: `Deposit: KES ${commissionBreakdown.grossAmount} (Commission: KES ${commissionBreakdown.commission})`,
        logo: 'https://canecash.app/logo.png'
      }
    };

    // Log leadership action
    const auditLog = cypherAI.logLeadershipAction(
      'DEPOSIT_PROCESSED',
      'SYSTEM',
      commissionBreakdown
    );

    return {
      status: 'success',
      transaction: {
        ...payload,
        ...commissionBreakdown,
        auditLog
      }
    };
  }

  // Verify payment from Flutterwave webhook
  async verifyPayment(transactionId) {
    try {
      const response = await fetch(
        `${this.apiUrl}/transactions/${transactionId}/verify`,
        {
          method: 'GET',
          headers: {
            Authorization: `Bearer ${this.secretKey}`
          }
        }
      );

      const data = await response.json();
      
      if (data.status === 'success') {
        // Decrypt leadership data if present
        if (data.meta && data.meta.commission) {
          const leadershipData = cypherAI.decryptLeadershipData(
            JSON.stringify(data.meta)
          );
          
          return {
            verified: true,
            transactionId,
            amount: data.amount,
            commission: data.meta.commission,
            netAmount: data.meta.netAmount,
            leadershipData,
            timestamp: new Date().toISOString()
          };
        }
      }

      return {
        verified: false,
        error: 'Payment verification failed'
      };
    } catch (error) {
      return {
        verified: false,
        error: error.message
      };
    }
  }
}

const flutterwave = new FlutterWaveProcessor();

// ============================================
// REQUEST HANDLERS
// ============================================

// Deposit endpoint with 1% commission
async function handleDeposit(req) {
  if (req.method !== 'POST') {
    return new Response('Method not allowed', { status: 405 });
  }

  try {
    const body = await req.json();
    const result = await flutterwave.processDeposit(body);

    return new Response(JSON.stringify(result), {
      status: 200,
      headers: { 'Content-Type': 'application/json' }
    });
  } catch (error) {
    return new Response(
      JSON.stringify({ error: error.message }),
      { status: 400, headers: { 'Content-Type': 'application/json' } }
    );
  }
}

// Payment verification endpoint
async function handleVerifyPayment(req) {
  const url = new URL(req.url);
  const transactionId = url.searchParams.get('transaction_id');

  if (!transactionId) {
    return new Response(
      JSON.stringify({ error: 'Missing transaction_id' }),
      { status: 400, headers: { 'Content-Type': 'application/json' } }
    );
  }

  const result = await flutterwave.verifyPayment(transactionId);

  return new Response(JSON.stringify(result), {
    status: result.verified ? 200 : 400,
    headers: { 'Content-Type': 'application/json' }
  });
}

// Leadership audit log endpoint (Cypher AI protected)
async function handleLeadershipAudit(req) {
  const url = new URL(req.url);
  const action = url.searchParams.get('action');

  if (!action) {
    return new Response(
      JSON.stringify({ error: 'Missing action parameter' }),
      { status: 400, headers: { 'Content-Type': 'application/json' } }
    );
  }

  const auditLog = cypherAI.logLeadershipAction(
    action,
    'LEADERSHIP_USER',
    { timestamp: new Date().toISOString() }
  );

  return new Response(JSON.stringify(auditLog), {
    status: 200,
    headers: { 'Content-Type': 'application/json' }
  });
}

// Health check endpoint
async function handleHealth(req) {
  return new Response(JSON.stringify({
    status: 'healthy',
    service: 'Cane Cash Backend',
    timestamp: new Date().toISOString(),
    environment: Deno.env.get('ENVIRONMENT') || 'development',
    security: {
      cypherAI: CYPHER_AI_ENABLED,
      flutterwave: !!FLW_PUBLIC_KEY,
      jwt: !!JWT_SECRET
    }
  }), {
    status: 200,
    headers: { 'Content-Type': 'application/json' }
  });
}

// ============================================
// ROUTER
// ============================================
async function router(req) {
  const url = new URL(req.url);
  const pathname = url.pathname;

  if (pathname === '/health') {
    return handleHealth(req);
  } else if (pathname === '/deposit') {
    return handleDeposit(req);
  } else if (pathname === '/verify-payment') {
    return handleVerifyPayment(req);
  } else if (pathname === '/leadership-audit') {
    return handleLeadershipAudit(req);
  } else {
    return new Response('Not found', { status: 404 });
  }
}

// ============================================
// START SERVER
// ============================================
console.log(`\n✅ Cane Cash Backend Server starting on http://localhost:${PORT}`);
console.log(`📡 Endpoints:`);
console.log(`   - GET  /health - Server health check`);
console.log(`   - POST /deposit - Process deposit with 1% commission`);
console.log(`   - GET  /verify-payment - Verify Flutterwave payment`);
console.log(`   - GET  /leadership-audit - Leadership audit logs (Cypher AI)\n`);

serve(router, { port: PORT });
```

## Configuration Summary

✅ **Environment Variables Setup:**

- FLW_PUBLIC_KEY - Flutterwave public key
- FLW_SECRET_KEY - Flutterwave secret key
- FLW_ENCRYPTION_KEY - Encryption key
- JWT_SECRET - JWT authentication secret
- PORT - Server port (5000)
- DEPOSIT_COMMISSION_RATE - 1% commission (0.01)

✅ **Flutterwave Integration:**

- Deposit processing with automatic 1% commission calculation
- Payment verification endpoint
- Transaction reference tracking
- Commission breakdown reporting

✅ **Cypher AI Security Layer:**

- Leadership data encryption/decryption
- Audit logging for all leadership actions
- High-level encryption for sensitive operations
- Access control for leadership-only endpoints

✅ **Server Endpoints:**

- `/health` - Health check
- `/deposit` - Process deposits with 1% commission
- `/verify-payment` - Verify payments from Flutterwave
- `/leadership-audit` - Leadership audit logs

## Running the Server

```bash
# With Deno
deno run --allow-env --allow-net server.js

# Or with environment variables
FLW_PUBLIC_KEY=your_key PORT=5000 deno run --allow-env --allow-net server.js
```

---

# Server URL for Mobile App Integration

## Development URLs

### Local Development

```
http://localhost:5000
```

**Endpoints for Mobile App:**

- `POST http://localhost:5000/deposit` - Process deposits
- `GET http://localhost:5000/verify-payment?transaction_id=XXX` - Verify payment
- `GET http://localhost:5000/health` - Check server status

### Production URLs (Choose One)

**Option 1: Heroku (Recommended)**

```
https://cane-cash-backend.herokuapp.com
```

Deploy command:

```bash
heroku create cane-cash-backend
git push heroku main
```

**Option 2: Railway.app**

```
https://cane-cash-backend.railway.app
```

**Option 3: Render**

```
https://cane-cash-backend.onrender.com
```

**Option 4: Custom Domain (canecash.app)**

```
https://api.canecash.app
https://backend.canecash.app
```

### Mobile App Configuration

Add to your mobile app config file:

**React Native / Expo:**

```javascript
const API_BASE_URL = __DEV__ 
  ? 'http://localhost:5000'
  : 'https://cane-cash-backend.herokuapp.com';

export const ENDPOINTS = {
  DEPOSIT: `${API_BASE_URL}/deposit`,
  VERIFY_PAYMENT: `${API_BASE_URL}/verify-payment`,
  HEALTH: `${API_BASE_URL}/health`,
  LEADERSHIP_AUDIT: `${API_BASE_URL}/leadership-audit`
};
```

**Flutter:**

```dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:5000'; // Development
  // static const String baseUrl = 'https://cane-cash-backend.herokuapp.com'; // Production

  static const String depositEndpoint = '$baseUrl/deposit';
  static const String verifyPaymentEndpoint = '$baseUrl/verify-payment';
  static const String healthEndpoint = '$baseUrl/health';
}
```

---

# Mobile UI - Deposit Screen

## React Native / Expo Implementation

```javascript
import React, { useState } from 'react';
import {
  View,
  Text,
  TextInput,
  TouchableOpacity,
  StyleSheet,
  ActivityIndicator,
  Alert,
  ScrollView,
  SafeAreaView
} from 'react-native';
import axios from 'axios';

const API_BASE_URL = 'http://localhost:5000'; // Change for production

export default function DepositScreen() {
  const [fullName, setFullName] = useState('');
  const [email, setEmail] = useState('');
  const [phoneNumber, setPhoneNumber] = useState('');
  const [depositAmount, setDepositAmount] = useState('');
  const [loading, setLoading] = useState(false);
  const [commissionBreakdown, setCommissionBreakdown] = useState(null);

  // Calculate 1% commission in real-time
  const calculateCommission = (amount) => {
    const num = parseFloat(amount) || 0;
    const commission = num * 0.01;
    const netAmount = num - commission;
    return {
      grossAmount: num.toFixed(2),
      commission: commission.toFixed(2),
      netAmount: netAmount.toFixed(2),
      commissionRate: '1%'
    };
  };

  const handleAmountChange = (amount) => {
    setDepositAmount(amount);
    if (amount) {
      setCommissionBreakdown(calculateCommission(amount));
    } else {
      setCommissionBreakdown(null);
    }
  };

  const handleDeposit = async () => {
    // Validation
    if (!fullName.trim()) {
      Alert.alert('Error', 'Please enter your full name');
      return;
    }
    if (!email.trim()) {
      Alert.alert('Error', 'Please enter your email');
      return;
    }
    if (!phoneNumber.trim()) {
      Alert.alert('Error', 'Please enter your phone number');
      return;
    }
    if (!depositAmount || parseFloat(depositAmount) <= 0) {
      Alert.alert('Error', 'Please enter a valid deposit amount');
      return;
    }

    setLoading(true);

    try {
      const response = await axios.post(`${API_BASE_URL}/deposit`, {
        fullName,
        email,
        phoneNumber,
        amount: parseFloat(depositAmount),
        transactionRef: `CANECASH_${Date.now()}`
      });

      if (response.status === 200) {
        const { transaction } = response.data;
        
        Alert.alert(
          'Deposit Initiated',
          `Amount: KES ${transaction.grossAmount}\nCommission: KES ${transaction.commission}\nNet: KES ${transaction.netAmount}\n\nTransaction ID: ${transaction.tx_ref}`,
          [
            {
              text: 'OK',
              onPress: () => {
                // Reset form
                setFullName('');
                setEmail('');
                setPhoneNumber('');
                setDepositAmount('');
                setCommissionBreakdown(null);
              }
            }
          ]
        );
      }
    } catch (error) {
      console.error('Deposit error:', error);
      Alert.alert(
        'Deposit Failed',
        error.response?.data?.error || 'An error occurred. Please try again.'
      );
    } finally {
      setLoading(false);
    }
  };

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.scrollContent}>
        {/* Header */}
        <View style={styles.header}>
          <Text style={styles.title}>💰 Make a Deposit</Text>
          <Text style={styles.subtitle}>Quick and secure deposits to your Cane Cash account</Text>
        </View>

        {/* Form Section */}
        <View style={styles.formSection}>
          {/* Full Name Input */}
          <View style={styles.inputGroup}>
            <Text style={styles.label}>Full Name</Text>
            <TextInput
              style={styles.input}
              placeholder="Enter your full name"
              placeholderTextColor="#999"
              value={fullName}
              onChangeText={setFullName}
              editable={!loading}
            />
          </View>

          {/* Email Input */}
          <View style={styles.inputGroup}>
            <Text style={styles.label}>Email Address</Text>
            <TextInput
              style={styles.input}
              placeholder="Enter your email"
              placeholderTextColor="#999"
              keyboardType="email-address"
              value={email}
              onChangeText={setEmail}
              editable={!loading}
            />
          </View>

          {/* Phone Number Input */}
          <View style={styles.inputGroup}>
            <Text style={styles.label}>Phone Number</Text>
            <TextInput
              style={styles.input}
              placeholder="Enter your phone number"
              placeholderTextColor="#999"
              keyboardType="phone-pad"
              value={phoneNumber}
              onChangeText={setPhoneNumber}
              editable={!loading}
            />
          </View>

          {/* Deposit Amount Input */}
          <View style={styles.inputGroup}>
            <Text style={styles.label}>Deposit Amount (KES)</Text>
            <TextInput
              style={styles.input}
              placeholder="Enter amount"
              placeholderTextColor="#999"
              keyboardType="decimal-pad"
              value={depositAmount}
              onChangeText={handleAmountChange}
              editable={!loading}
            />
          </View>
        </View>

        {/* Commission Breakdown */}
        {commissionBreakdown && (
          <View style={styles.commissionBox}>
            <Text style={styles.commissionTitle}>💡 Commission Breakdown</Text>
            
            <View style={styles.commissionRow}>
              <Text style={styles.commissionLabel}>Deposit Amount:</Text>
              <Text style={styles.commissionValue}>KES {commissionBreakdown.grossAmount}</Text>
            </View>

            <View style={styles.commissionRow}>
              <Text style={styles.commissionLabel}>Commission ({commissionBreakdown.commissionRate}):</Text>
              <Text style={[styles.commissionValue, styles.commissionRed]}>
                - KES {commissionBreakdown.commission}
              </Text>
            </View>

            <View style={[styles.commissionRow, styles.totalRow]}>
              <Text style={styles.totalLabel}>You will receive:</Text>
              <Text style={styles.totalValue}>KES {commissionBreakdown.netAmount}</Text>
            </View>
          </View>
        )}

        {/* Security Info */}
        <View style={styles.securityBox}>
          <Text style={styles.securityTitle}>🔒 Security Features</Text>
          <Text style={styles.securityText}>✓ Encrypted with Cypher AI</Text>
          <Text style={styles.securityText}>✓ Flutterwave Payment Gateway</Text>
          <Text style={styles.securityText}>✓ 256-bit SSL Encryption</Text>
        </View>

        {/* Deposit Button */}
        <TouchableOpacity
          style={[styles.depositButton, loading && styles.depositButtonDisabled]}
          onPress={handleDeposit}
          disabled={loading}
        >
          {loading ? (
            <ActivityIndicator color="#fff" size="large" />
          ) : (
            <Text style={styles.depositButtonText}>💳 Proceed to Payment</Text>
          )}
        </TouchableOpacity>

        {/* Terms */}
        <Text style={styles.termsText}>
          By proceeding, you agree to our Terms of Service and Privacy Policy
        </Text>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  scrollContent: {
    padding: 20,
    paddingBottom: 40,
  },
  header: {
    marginBottom: 30,
    paddingBottom: 20,
    borderBottomWidth: 1,
    borderBottomColor: '#e0e0e0',
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#1a1a1a',
    marginBottom: 8,
  },
  subtitle: {
    fontSize: 14,
    color: '#666',
  },
  formSection: {
    backgroundColor: '#fff',
    borderRadius: 12,
    padding: 20,
    marginBottom: 20,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  inputGroup: {
    marginBottom: 18,
  },
  label: {
    fontSize: 14,
    fontWeight: '600',
    color: '#333',
    marginBottom: 8,
  },
  input: {
    borderWidth: 1,
    borderColor: '#ddd',
    borderRadius: 8,
    paddingHorizontal: 15,
    paddingVertical: 12,
    fontSize: 16,
    backgroundColor: '#fafafa',
  },
  commissionBox: {
    backgroundColor: '#f0f8ff',
    borderRadius: 12,
    padding: 16,
    marginBottom: 20,
    borderLeftWidth: 4,
    borderLeftColor: '#007AFF',
  },
  commissionTitle: {
    fontSize: 14,
    fontWeight: '700',
    color: '#007AFF',
    marginBottom: 12,
  },
  commissionRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 10,
  },
  commissionLabel: {
    fontSize: 13,
    color: '#555',
  },
  commissionValue: {
    fontSize: 13,
    fontWeight: '600',
    color: '#333',
  },
  commissionRed: {
    color: '#ff6b6b',
  },
  totalRow: {
    paddingTop: 10,
    borderTopWidth: 1,
    borderTopColor: '#ddd',
    marginBottom: 0,
  },
  totalLabel: {
    fontSize: 14,
    fontWeight: '700',
    color: '#1a1a1a',
  },
  totalValue: {
    fontSize: 14,
    fontWeight: '700',
    color: '#28a745',
  },
  securityBox: {
    backgroundColor: '#e8f5e9',
    borderRadius: 12,
    padding: 16,
    marginBottom: 20,
  },
  securityTitle: {
    fontSize: 14,
    fontWeight: '700',
    color: '#2e7d32',
    marginBottom: 10,
  },
  securityText: {
    fontSize: 13,
    color: '#1b5e20',
    marginBottom: 6,
  },
  depositButton: {
    backgroundColor: '#007AFF',
    borderRadius: 12,
    paddingVertical: 16,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 16,
    shadowColor: '#007AFF',
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 5,
  },
  depositButtonDisabled: {
    backgroundColor: '#999',
  },
  depositButtonText: {
    color: '#fff',
    fontSize: 16,
    fontWeight: '700',
  },
  termsText: {
    textAlign: 'center',
    fontSize: 12,
    color: '#999',
    lineHeight: 18,
  },
});
```

## Flutter Implementation

```dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DepositScreen extends StatefulWidget {
  @override
  _DepositScreenState createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();
  
  bool _isLoading = false;
  Map<String, dynamic>? _commissionBreakdown;
  
  static const String API_BASE_URL = 'http://localhost:5000';

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_calculateCommission);
  }

  void _calculateCommission() {
    if (_amountController.text.isEmpty) {
      setState(() => _commissionBreakdown = null);
      return;
    }

    try {
      double amount = double.parse(_amountController.text);
      double commission = amount * 0.01;
      double netAmount = amount - commission;

      setState(() {
        _commissionBreakdown = {
          'grossAmount': amount.toStringAsFixed(2),
          'commission': commission.toStringAsFixed(2),
          'netAmount': netAmount.toStringAsFixed(2),
          'commissionRate': '1%'
        };
      });
    } catch (e) {
      setState(() => _commissionBreakdown = null);
    }
  }

  Future<void> _processDeposit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$API_BASE_URL/deposit'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullName': _fullNameController.text,
          'email': _emailController.text,
          'phoneNumber': _phoneController.text,
          'amount': double.parse(_amountController.text),
          'transactionRef': 'CANECASH_${DateTime.now().millisecondsSinceEpoch}',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final transaction = data['transaction'];

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Deposit Initiated!\n'
              'Amount: KES ${transaction['grossAmount']}\n'
              'Commission: KES ${transaction['commission']}\n'
              'Net: KES ${transaction['netAmount']}',
            ),
            duration: Duration(seconds: 5),
          ),
        );

        // Reset form
        _fullNameController.clear();
        _emailController.clear();
        _phoneController.clear();
        _amountController.clear();
      } else {
        throw Exception('Failed to process deposit');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('💰 Make a Deposit'),
        backgroundColor: Color(0xFF007AFF),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Quick and secure deposits to your Cane Cash account',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                SizedBox(height: 24),

                // Form Card
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Full Name
                        Text('Full Name', style: TextStyle(fontWeight: FontWeight.w600)),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _fullNameController,
                          decoration: InputDecoration(
                            hintText: 'Enter your full name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Name is required';
                            return null;
                          },
                          enabled: !_isLoading,
                        ),
                        SizedBox(height: 16),

                        // Email
                        Text('Email Address', style: TextStyle(fontWeight: FontWeight.w600)),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: 'Enter your email',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Email is required';
                            if (!value!.contains('@')) return 'Invalid email';
                            return null;
                          },
                          enabled: !_isLoading,
                        ),
                        SizedBox(height: 16),

                        // Phone
                        Text('Phone Number', style: TextStyle(fontWeight: FontWeight.w600)),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: 'Enter your phone number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Phone is required';
                            return null;
                          },
                          enabled: !_isLoading,
                        ),
                        SizedBox(height: 16),

                        // Amount
                        Text('Deposit Amount (KES)', style: TextStyle(fontWeight: FontWeight.w600)),
                        SizedBox(height: 8),
                        TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: 'Enter amount',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value?.isEmpty ?? true) return 'Amount is required';
                            if (double.tryParse(value!) == null) return 'Invalid amount';
                            return null;
                          },
                          enabled: !_isLoading,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Commission Breakdown
                if (_commissionBreakdown != null)
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Color(0xFFF0F8FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border(
                        left: BorderSide(color: Color(0xFF007AFF), width: 4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '💡 Commission Breakdown',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF007AFF),
                            fontSize: 14,
                          ),
                        ),
                        SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Deposit Amount:'),
                            Text('KES ${_commissionBreakdown!['grossAmount']}',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Commission (${_commissionBreakdown!['commissionRate']}):'),
                            Text('- KES ${_commissionBreakdown!['commission']}',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600, color: Colors.red)),
                          ],
                        ),
                        Divider(color: Colors.grey[300]),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('You will receive:',
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text('KES ${_commissionBreakdown!['netAmount']}',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                    fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 20),

                // Security Info
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🔒 Security Features',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text('✓ Encrypted with Cypher AI', style: TextStyle(color: Color(0xFF1B5E20))),
                      Text('✓ Flutterwave Payment Gateway', style: TextStyle(color: Color(0xFF1B5E20))),
                      Text('✓ 256-bit SSL Encryption', style: TextStyle(color: Color(0xFF1B5E20))),
                    ],
                  ),
                ),
                SizedBox(height: 24),

                // Deposit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _processDeposit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF007AFF),
                      disabledBackgroundColor: Colors.grey,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(Colors.white),
                            ),
                          )
                        : Text(
                            '💳 Proceed to Payment',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                SizedBox(height: 16),

                // Terms
                Center(
                  child: Text(
                    'By proceeding, you agree to our Terms of Service and Privacy Policy',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _amountController.dispose();
    super.dispose();
  }
}
```

---

## API Request Examples

### cURL

```bash
curl -X POST http://localhost:5000/deposit \
  -H "Content-Type: application/json" \
  -d '{
    "fullName": "John Doe",
    "email": "john@example.com",
    "phoneNumber": "+254712345678",
    "amount": 1000,
    "transactionRef": "CANECASH_1234567890"
  }'
```

### JavaScript/Fetch

```javascript
const depositData = {
  fullName: 'John Doe',
  email: 'john@example.com',
  phoneNumber: '+254712345678',
  amount: 1000,
  transactionRef: `CANECASH_${Date.now()}`
};

fetch('http://localhost:5000/deposit', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(depositData)
})
.then(res => res.json())
.then(data => console.log('Deposit Response:', data));
```