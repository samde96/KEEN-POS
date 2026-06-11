import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:keen_pos/models/models.dart';
import 'package:keen_pos/providers/settings_provider.dart';

class MpesaSettingsScreen extends StatefulWidget {
  const MpesaSettingsScreen({Key? key}) : super(key: key);

  @override
  State<MpesaSettingsScreen> createState() => _MpesaSettingsScreenState();
}

class _MpesaSettingsScreenState extends State<MpesaSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _consumerKeyController;
  late TextEditingController _consumerSecretController;
  late TextEditingController _passKeyController;
  late TextEditingController _shortCodeController;
  late TextEditingController _initiatorNameController;
  late TextEditingController _securityCredentialController;

  @override
  void initState() {
    super.initState();
    _consumerKeyController = TextEditingController();
    _consumerSecretController = TextEditingController();
    _passKeyController = TextEditingController();
    _shortCodeController = TextEditingController();
    _initiatorNameController = TextEditingController();
    _securityCredentialController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  Future<void> _loadSettings() async {
    final provider = context.read<SettingsProvider>();
    await provider.fetchMpesaSettings();
    if (provider.mpesaSettings != null) {
      final s = provider.mpesaSettings!;
      setState(() {
        _consumerKeyController.text = s.consumerKey;
        _consumerSecretController.text = s.consumerSecret;
        _passKeyController.text = s.passKey;
        _shortCodeController.text = s.shortCode;
        _initiatorNameController.text = s.initiatorName;
        _securityCredentialController.text = s.securityCredential;
      });
    }
  }

  @override
  void dispose() {
    _consumerKeyController.dispose();
    _consumerSecretController.dispose();
    _passKeyController.dispose();
    _shortCodeController.dispose();
    _initiatorNameController.dispose();
    _securityCredentialController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('M-Pesa Daraja API Settings'),
        elevation: 0,
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.mpesaSettings == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Configure your M-Pesa Daraja API credentials to enable STK Push payments.',
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  _buildTextField(
                    controller: _consumerKeyController,
                    label: 'Consumer Key',
                    hint: 'Your Daraja App Consumer Key',
                  ),
                  _buildTextField(
                    controller: _consumerSecretController,
                    label: 'Consumer Secret',
                    hint: 'Your Daraja App Consumer Secret',
                    obscureText: true,
                  ),
                  _buildTextField(
                    controller: _passKeyController,
                    label: 'Pass Key',
                    hint: 'Online Payment LNM Pass Key',
                    obscureText: true,
                  ),
                  _buildTextField(
                    controller: _shortCodeController,
                    label: 'Business Short Code',
                    hint: 'Paybill or Buy Goods Number',
                    keyboardType: TextInputType.number,
                  ),
                  _buildTextField(
                    controller: _initiatorNameController,
                    label: 'Initiator Name',
                    hint: 'Required for some API operations',
                  ),
                  _buildTextField(
                    controller: _securityCredentialController,
                    label: 'Security Credential',
                    hint: 'Encrypted password for initiator',
                    obscureText: true,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: provider.isLoading ? null : _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF17A2B8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: provider.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Save Settings',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'This field is required';
          }
          return null;
        },
      ),
    );
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      final settings = MpesaSettings(
        consumerKey: _consumerKeyController.text.trim(),
        consumerSecret: _consumerSecretController.text.trim(),
        passKey: _passKeyController.text.trim(),
        shortCode: _shortCodeController.text.trim(),
        initiatorName: _initiatorNameController.text.trim(),
        securityCredential: _securityCredentialController.text.trim(),
      );

      final success = await context.read<SettingsProvider>().updateMpesaSettings(settings);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Settings updated successfully' : 'Failed to update settings'),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
        if (success) {
          Navigator.pop(context);
        }
      }
    }
  }
}