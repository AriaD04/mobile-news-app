// Mengimpor paket dasar Flutter untuk UI Material Design.
import 'package:flutter/material.dart';
// Mengimpor paket Firebase Authentication untuk menangani otentikasi pengguna.
import 'package:firebase_auth/firebase_auth.dart';

/// LoginPage adalah sebuah StatefulWidget.
/// Ini berarti state (data) dari widget ini dapat berubah selama widget aktif,
/// contohnya adalah teks yang diketik pengguna di dalam TextField.
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Membuat TextEditingController untuk mengambil dan mengelola input dari field email.
  final _emailController = TextEditingController();
  // Membuat TextEditingController untuk mengambil dan mengelola input dari field password.
  final _passwordController = TextEditingController();

  /// Fungsi untuk menangani proses login pengguna.
  /// Dideklarasikan sebagai 'async' karena kita akan memanggil operasi
  /// yang membutuhkan waktu untuk berinteraksi dengan server Firebase.
  void _login() async {
    // Mengambil teks dari controller, .trim() digunakan untuk menghapus spasi di awal dan akhir.
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Menggunakan blok try-catch untuk menangani potensi error saat proses login.
    try {
      // Memanggil fungsi signInWithEmailAndPassword dari instance Firebase Auth.
      // 'await' akan menjeda eksekusi di sini hingga proses login selesai (berhasil atau gagal).
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Jika kode setelah 'await' dieksekusi, berarti login berhasil.
      // Arahkan pengguna ke halaman utama ('/home').
      // pushReplacementNamed digunakan agar pengguna tidak bisa kembali ke halaman login
      // dengan menekan tombol "back" pada perangkat.
      Navigator.pushReplacementNamed(context, '/home');

    } catch (e) {
      // Jika terjadi error (misal: password salah, email tidak terdaftar),
      // blok 'catch' ini akan dieksekusi.
      // Tampilkan pesan error kepada pengguna menggunakan SnackBar di bagian bawah layar.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login gagal: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Scaffold menyediakan struktur dasar halaman (app bar, body, dll).
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      // Body utama halaman dengan padding (jarak) di sekelilingnya untuk estetika.
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        // Column digunakan untuk menyusun widget-widget di dalamnya secara vertikal.
        child: Column(
          // Menyusun widget-widget di tengah-tengah layar secara vertikal.
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Field untuk input email.
            TextField(
              controller: _emailController, // Menghubungkan field ini dengan controller email.
              decoration: InputDecoration(labelText: 'Email'),
              // Menampilkan keyboard yang dioptimalkan untuk input alamat email.
              keyboardType: TextInputType.emailAddress,
            ),
            // Memberi jarak vertikal sebesar 16 piksel antara field email dan password.
            const SizedBox(height: 16),
            // Field untuk input password.
            TextField(
              controller: _passwordController, // Menghubungkan field ini dengan controller password.
              decoration: InputDecoration(labelText: 'Password'),
              // Menyembunyikan teks yang diketik (menampilkannya sebagai titik-titik).
              obscureText: true,
            ),
            const SizedBox(height: 24),
            // Tombol utama untuk memicu fungsi login.
            ElevatedButton(
              onPressed: _login, // Memanggil fungsi _login saat tombol ini ditekan.
              child: Text('Login'),
            ),
            // Tombol teks untuk navigasi ke halaman registrasi bagi pengguna baru.
            TextButton(
              // Saat ditekan, arahkan pengguna ke halaman '/register'.
              // pushNamed digunakan agar pengguna bisa kembali ke halaman login jika perlu.
              onPressed: () => Navigator.pushNamed(context, '/register'),
              child: Text('Don\'t have an account? Register'),
            )
          ],
        ),
      ),
    );
  }
}
