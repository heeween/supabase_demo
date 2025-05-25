import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;
const supabaseBataURL = "https://yiwtjvbsymuygdggzqtr.supabase.co";
const supabaseBetaAnonKey =
    "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inlpd3RqdmJzeW11eWdkZ2d6cXRyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk5Nzc3MzEsImV4cCI6MjA1NTU1MzczMX0.ZB7XOQsGFBV7n3jqTvxW6CM39c7-o1uYNslqxVgvOLI";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseBataURL, anonKey: supabaseBetaAnonKey);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  User? _user;
  List<UserIdentity>? _identities;
  String _userInfo = '';
  final _emailController = TextEditingController(text: "evan@jolii.ai");
  final _passwordController = TextEditingController(text: "asdf1234");
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _updateUserInfo() async {
    if (_user != null) {
      final identities = await supabase.auth.getUserIdentities();
      setState(() {
        _identities = identities;
        _userInfo = 'User ID: ${_user?.id}';
      });
    }
  }

  Future<void> _signInWithEmail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await supabase.auth.signInWithPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      final user = response.user;
      if (user != null) {
        setState(() {
          _user = user;
        });
        await _updateUserInfo();
        print('Email sign-in successful: ${user.id}');
      }
    } catch (e) {
      print('Email sign-in error: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signInAnonymously() async {
    try {
      final response = await supabase.auth.signInAnonymously();
      final user = response.user;
      if (user != null) {
        setState(() {
          _user = user;
        });
        await _updateUserInfo();
        print('Anonymous sign-in successful: ${user.id}');
      }
    } catch (e) {
      print('Anonymous sign-in error: $e');
    }
  }

  Future<void> _linkWithGoogle() async {
    try {
      final response = await supabase.auth.linkIdentity(
        OAuthProvider.google,
      );
      print('Google sign-in response: $response');
      final user = supabase.auth.currentUser;
      if (user != null) {
        setState(() {
          _user = user;
        });
        await _updateUserInfo();
      }
    } catch (e) {
      print('Google sign-in error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (_user != null) ...[
                Text(_userInfo, textAlign: TextAlign.start),
                if (_identities != null && _identities!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ..._identities!.map(
                    (identity) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        'Provider: ${identity.provider}\nID: ${identity.id}',
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _signInWithEmail,
                child:
                    _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Sign In with Email'),
              ),
              const SizedBox(height: 16),
              const Text('OR', textAlign: TextAlign.center),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: _signInAnonymously,
                child: const Text('Sign In Anonymously'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _linkWithGoogle,
                child: const Text('Link with Google'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
