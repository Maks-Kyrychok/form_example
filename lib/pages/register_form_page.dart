import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:form_example/pages/user_info_page.dart';

import '../models/user.dart';

class RegisterFormPage extends StatefulWidget {
  const RegisterFormPage({Key? key}) : super(key: key);

  @override
  State<RegisterFormPage> createState() => _RegisterFormPageState();
}

class _RegisterFormPageState extends State<RegisterFormPage> {
  bool _hidePass = true;

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _storyController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();

  String _selectedCountry = 'Ukraine';

  final List<String> _countries = [
    "Ukraine",
    "Canada",
    "USA",
    "China",
    "United Kingdom",
    "India"
  ];

  FocusNode? _nameFocus;
  FocusNode? _phoneFocus;
  FocusNode? _passFocus;

  User newUser = User();

  @override
  void initState() {
    super.initState();
    _nameFocus = FocusNode();
    _phoneFocus = FocusNode();
    _passFocus = FocusNode();
  }

  void _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _storyController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    _nameFocus!.dispose();
    _phoneFocus!.dispose();
    _passFocus!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Register form'),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              autofocus: true,
              focusNode: _nameFocus,
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Full name *',
                suffixIcon: ClearFieldWidget(controller: _nameController),
              ),
              keyboardType: TextInputType.name,
              validator: _validateName,
              onFieldSubmitted: (_) {
                _fieldFocusChange(context, _nameFocus!, _phoneFocus!);
              },
              onSaved: (value) => newUser.name = value!,
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              focusNode: _phoneFocus,
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone number *',
                suffixIcon: ClearFieldWidget(controller: _phoneController),
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter(RegExp(r'^[()\d -]{1,15}$'),
                    allow: true),
              ],
              validator: (value) => _validatePhoneNumber(value)
                  ? null
                  : 'Enter valid phone number (###)###-####',
              onFieldSubmitted: (_) {
                _fieldFocusChange(context, _phoneFocus!, _passFocus!);
              },
              onSaved: (value) => newUser.phone = value!,
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email address'),
              keyboardType: TextInputType.emailAddress,
              validator: (mail) => _validateEmail(mail),
              onSaved: (value) => newUser.email = value!,
            ),
            const SizedBox(
              height: 20,
            ),
            DropdownButtonFormField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Country?',
              ),
              value: _selectedCountry,
              items: _countries.map((country) {
                return DropdownMenuItem(
                  value: country,
                  child: Text(country),
                );
              }).toList(),
              onChanged: (country) {
                setState(() {
                  _selectedCountry = country as String;
                });
              },
              // validator: (val) {
              //   return val == null ? 'Please select country' : null;
              // },
              onSaved: (value) => newUser.country = _selectedCountry,
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: _storyController,
              decoration: const InputDecoration(
                labelText: 'Life story',
              ),
              maxLines: 3,
              inputFormatters: [
                LengthLimitingTextInputFormatter(100),
              ],
              onSaved: (value) => newUser.story = value!,
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              focusNode: _passFocus,
              controller: _passController,
              decoration: InputDecoration(
                labelText: 'Password *',
                suffixIcon: IconButton(
                  icon:
                      Icon(_hidePass ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _hidePass = !_hidePass;
                    });
                  },
                ),
              ),
              obscureText: _hidePass,
              maxLength: 8,
              validator: _validatePass,
            ),
            const SizedBox(
              height: 20,
            ),
            TextFormField(
              controller: _confirmPassController,
              decoration:
                  const InputDecoration(labelText: 'Confirm password *'),
              obscureText: _hidePass,
              maxLength: 8,
              validator: _validateConfirmPass,
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                primary: const Color.fromARGB(255, 7, 31, 50),
              ),
              child: const Text(
                'Push',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _showDialog(name: _nameController.text);
      log('Name: ${_nameController.text}');
      log('Phone: ${_phoneController.text}');
      log('Email: ${_emailController.text}');
      log('Country: $_selectedCountry');
      log('Story: ${_storyController.text}');
      log('Pass: ${_passController.text}');
      log('Confirm: ${_confirmPassController.text}');
    } else {
      _showMassage(message: 'Form not valid');
    }
  }

  String? _validateName(String? value) {
    final nameExp = RegExp(r'^[A-Za-z ]+$');
    if (value!.isEmpty) {
      return 'Name is required';
    } else if (!nameExp.hasMatch(value)) {
      return 'Please enter alphabetical characters';
    } else {
      return null;
    }
  }

  bool _validatePhoneNumber(String? input) {
    final phoneExp = RegExp(r'^\(\d\d\d\)\d\d\d-\d\d\d\d$');
    return phoneExp.hasMatch(input!);
  }

  String? _validateEmail(String? mail) {
    if (mail!.isEmpty) {
      return 'Email is required';
    } else if (!_emailController.text.contains('@')) {
      return 'Invalid email address';
    } else {
      return null;
    }
  }

  String? _validatePass(String? pass) {
    if (pass!.isEmpty) {
      return 'Password is required';
    } else if (pass.length < 8) {
      return 'Pass to short';
    } else {
      return null;
    }
  }

  String? _validateConfirmPass(confirmPass) {
    if (confirmPass!.isEmpty) {
      return 'Confirm password is required';
    } else if (_confirmPassController.text != _passController.text) {
      return 'confirm password not correct';
    } else {
      return null;
    }
  }

  void _showMassage({required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.red,
        content: Text(
          message,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 18.0),
        )));
  }

  void _showDialog({required String name}) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Registration saccessfull',
            style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18.0,
                color: Color.fromARGB(255, 103, 57, 228)),
          ),
          content: Text(
            '$name is now vrified rgister form',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18.0),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserInfoPage(userInfo: newUser),
                  ),
                );
              },
              child: const Text(
                'Verifield',
                style: TextStyle(
                  color: Color.fromARGB(255, 103, 57, 228),
                  fontSize: 18.0,
                ),
              ),
            )
          ],
        );
      },
    );
  }
}

class ClearFieldWidget extends StatelessWidget {
  const ClearFieldWidget({
    Key? key,
    required TextEditingController controller,
  })  : _fieldController = controller,
        super(key: key);

  final TextEditingController _fieldController;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _fieldController.clear();
      },
      child: const Icon(Icons.delete_outlined),
    );
  }
}
