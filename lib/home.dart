import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mocksum_flutter/login.dart';
import 'package:mocksum_flutter/settings.dart';
import 'package:mocksum_flutter/tutorials.dart';
import 'package:mocksum_flutter/util/user_provider.dart';
import 'package:provider/provider.dart';
import 'main_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _index = 0;
  bool _isFirstLaunch = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      _getNowIsFirstLaunch();
      if (_isFirstLaunch) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const Tutorials()));
      }
      bool isLogged = await Provider.of<UserStatus>(context, listen: false).verifyToken();
      if (!isLogged) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
      }
    });
  }

  void _getNowIsFirstLaunch() async {
    const storage = FlutterSecureStorage();
    String? first = await storage.read(key: 'first');
    if (first == null) {
      _isFirstLaunch = true;
      await storage.write(key: 'first', value: '1');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: IndexedStack(
          index: _index,
          children: const [MainPage(), Settings()],
        ),
        bottomNavigationBar: BottomNavigationBar(
          showSelectedLabels: false,
          showUnselectedLabels: false,
          backgroundColor: const Color(0xFFF9F9F9),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'home'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'setting')
          ],
          currentIndex: _index,
          onTap: (newIndex) {
            setState(() {
              _index = newIndex;
            });
          },
        ),
      )
    );
  }

}