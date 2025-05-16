// lib/screens/transfer_screen.dart (continuação)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';
import '../widgets/custom_button.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({Key? key}) : super(key: key);

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recipientController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  // Mock recipients for auto-complete
  final List<Map<String, String>> _mockRecipients = [
    {'name': 'Maria Silva', 'account': '23456-7'},
    {'name': 'Carlos Oliveira', 'account': '34567-8'},
    {'name': 'Ana Santos', 'account': '45678-9'},
    {'name': 'Paulo Mendes', 'account': '56789-0'},
  ];
  
  String? _selectedRecipient;
  
  @override
  void dispose() {
    _recipientController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    
    // Currency formatter
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    
    if (user == null) {
      // If no user is logged in, redirect to login
      Future.microtask(() {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transferência'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance information
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Saldo disponível',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      currencyFormat.format(user.balance),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Recipient selection
              const Text(
                'Para quem você deseja transferir?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return const Iterable<String>.empty();
                  }
                  
                  return _mockRecipients
                      .where((recipient) => recipient['name']!
                          .toLowerCase()
                          .contains(textEditingValue.text.toLowerCase()))
                      .map((recipient) => '${recipient['name']} (${recipient['account']})')
                      .toList();
                },
                onSelected: (String selection) {
                  setState(() {
                    _selectedRecipient = selection;
                    _recipientController.text = selection;
                  });
                },
                fieldViewBuilder: (
                  BuildContext context,
                  TextEditingController controller,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted,
                ) {
                  _recipientController.text = controller.text;
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    decoration: InputDecoration(
                      labelText: 'Nome ou conta do destinatário',
                      prefixIcon: const Icon(Icons.person),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.contact_page),
                        onPressed: () {
                          // Show contact picker
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Lista de contatos em breve!'),
                            ),
                          );
                        },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, informe o destinatário';
                      }
                      return null;
                    },
                  );
                },
              ),
              
              const SizedBox(height: 16),
              
              // Amount input
              const Text(
                'Qual valor você deseja transferir?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Valor',
                  prefixText: 'R\$ ',
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, informe o valor';
                  }
                  
                  final amount = double.tryParse(value);
                  if (amount == null) {
                    return 'Valor inválido';
                  }
                  
                  if (amount <= 0) {
                    return 'O valor deve ser maior que zero';
                  }
                  
                  if (amount > user.balance) {
                    return 'Saldo insuficiente';
                  }
                  
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // Description input
              const Text(
                'Descrição (opcional)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descrição',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLength: 50,
              ),
              
              const SizedBox(height: 32),
              
              // Transfer button
              CustomButton(
                text: 'Continuar',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Extract recipient name from selected recipient
                    final recipientName = _selectedRecipient != null
                        ? _selectedRecipient!.split(' (')[0]
                        : _recipientController.text;
                    
                    // Extract account number if available
                    final accountNumber = _selectedRecipient != null
                        ? _selectedRecipient!.split('(')[1].replaceAll(')', '')
                        : '';
                    
                    // Navigate to confirm screen with arguments
                    Navigator.of(context).pushNamed(
                      AppRoutes.transferConfirm,
                      arguments: {
                        'recipient': recipientName,
                        'account': accountNumber,
                        'amount': double.parse(_amountController.text),
                        'description': _descriptionController.text,
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}