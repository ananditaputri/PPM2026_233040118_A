import 'package:flutter/material.dart';
import 'db_helper.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class Catatan {
  final int? id;
  final String judul;
  final String isi;
  final String kategori;
  final DateTime dibuatPada;

  Catatan({
    this.id,
    required this.judul,
    required this.isi,
    required this.kategori,
    required this.dibuatPada,
  });

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'judul': judul,
        'isi': isi,
        'kategori': kategori,
        'dibuat_pada': dibuatPada.millisecondsSinceEpoch,
      };

  static Catatan fromMap(Map<String, Object?> m) => Catatan(
        id: m['id'] as int?,
        judul: m['judul'] as String,
        isi: m['isi'] as String,
        kategori: m['kategori'] as String,
        dibuatPada:
            DateTime.fromMillisecondsSinceEpoch(m['dibuat_pada'] as int),
      );

  Catatan copyWith({
    String? judul,
    String? isi,
    String? kategori,
  }) {
    return Catatan(
      id: id,
      judul: judul ?? this.judul,
      isi: isi ?? this.isi,
      kategori: kategori ?? this.kategori,
      dibuatPada: dibuatPada,
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Catatan Mahasiswa',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FF),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Color(0xFF6C63FF),
          foregroundColor: Colors.white,
        ),
      ),
      home: const HomePage(),
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/form':
            return MaterialPageRoute(
              builder: (_) => CatatanFormPage(
                initial: settings.arguments as Catatan?,
              ),
            );

          case '/detail':
            return MaterialPageRoute(
              builder: (_) => DetailCatatanPage(
                catatan: settings.arguments as Catatan,
              ),
            );
        }
        return null;
      },
    );
  }
}
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<List<Catatan>> _futureCatatan;

  @override
  void initState() {
    super.initState();
    _muatUlang();
  }

  void _muatUlang() {
    setState(() {
      _futureCatatan = DbHelper.instance.getAll();
    });
  }

  Future<void> _bukaForm({Catatan? initial}) async {
    await Navigator.pushNamed(
      context,
      '/form',
      arguments: initial,
    );

    _muatUlang();
  }

  Future<void> _konfirmasiHapus(Catatan c) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Hapus Catatan'),
        content: Text(
          'Yakin ingin menghapus "${c.judul}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (yakin == true) {
      await DbHelper.instance.delete(c.id!);

      if (!mounted) return;

      _muatUlang();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${c.judul} berhasil dihapus'),
        ),
      );
    }
  }

  Color _warnaKategori(String kategori) {
    switch (kategori) {
      case 'Kuliah':
        return Colors.blue;
      case 'Tugas':
        return Colors.orange;
      case 'Pribadi':
        return Colors.green;
      default:
        return Colors.purple;
    }
  }

  Widget _itemCatatan(Catatan c) {
    final warna = _warnaKategori(c.kategori);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: Card(
        elevation: 5,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/detail',
              arguments: c,
            );
          },
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: warna.withOpacity(0.15),
            child: Icon(
              Icons.note_alt_rounded,
              color: warna,
            ),
          ),
          title: Text(
            c.judul,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: warna.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    c.kategori,
                    style: TextStyle(
                      color: warna,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                color: Colors.blue,
                onPressed: () => _bukaForm(initial: c),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                color: Colors.red,
                onPressed: () => _konfirmasiHapus(c),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note_alt_outlined,
            size: 100,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          const Text(
            'Belum Ada Catatan',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tekan tombol tambah untuk membuat catatan baru',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Mahasiswa'),
        actions: [
          IconButton(
            onPressed: _muatUlang,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<Catatan>>(
        future: _futureCatatan,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error : ${snapshot.error}',
              ),
            );
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return _emptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (context, index) {
              return _itemCatatan(data[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        elevation: 8,
        onPressed: () => _bukaForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Catatan'),
      ),
    );
  }
}
