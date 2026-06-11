import 'package:flutter/material.dart';
import 'api_client.dart';

void main() {
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

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'judul': judul,
        'isi': isi,
        'kategori': kategori,
        'dibuat_pada': dibuatPada.toUtc().toIso8601String(),
      };

  static Catatan fromJson(Map<String, dynamic> m) => Catatan(
        id: m['id'] as int?,
        judul: m['judul'] as String,
        isi: m['isi'] as String,
        kategori: m['kategori'] as String,
        dibuatPada: DateTime.parse(m['dibuat_pada'] as String),
      );

  Catatan copyWith({String? judul, String? isi, String? kategori}) => Catatan(
        id: id,
        judul: judul ?? this.judul,
        isi: isi ?? this.isi,
        kategori: kategori ?? this.kategori,
        dibuatPada: dibuatPada,
      );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Mahasiswa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
          primary: Colors.pink[400],
          secondary: Colors.pinkAccent[100],
          surface: const Color(0xFFFFF1F5),
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFF1F5),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.pink[100],
          foregroundColor: Colors.pink[900],
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const HomePage());
          case '/form':
            final arg = settings.arguments;
            return MaterialPageRoute(
              builder: (_) => CatatanFormPage(initial: arg as Catatan?),
            );
          case '/detail':
            final c = settings.arguments as Catatan;
            return MaterialPageRoute(
              builder: (_) => DetailCatatanPage(catatan: c),
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
  String _filterKategori = 'Semua';
  final _kategoriOpsi = const ['Semua', 'Kuliah', 'Tugas', 'Pribadi', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    _muatUlang();
  }

  void _muatUlang() {
    setState(() {
      _futureCatatan = ApiClient.instance.getAll();
    });
  }

  Future<void> _bukaForm({Catatan? initial}) async {
    await Navigator.pushNamed(context, '/form', arguments: initial);
    _muatUlang();
  }

  Future<void> _konfirmasiHapus(Catatan c) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus catatan?'),
        content: Text('"${c.judul}" akan dihapus permanen.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (yakin == true) {
      try {
        await ApiClient.instance.delete(c.id!);
        if (!mounted) return;
        _muatUlang();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"${c.judul}" dihapus')),
        );
      } on ApiException catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: ${e.message}')),
        );
      }
    }
  }

  Widget _itemCatatan(Catatan c) {
    return Card(
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(c.judul,
            style: TextStyle(
                fontWeight: FontWeight.bold, color: Colors.pink[900])),
        subtitle: Text(
          "${c.kategori} • ${c.isi}",
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit_outlined, color: Colors.pink[300]),
              onPressed: () => _bukaForm(initial: c),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red[300]),
              onPressed: () => _konfirmasiHapus(c),
            ),
          ],
        ),
        onTap: () async {
          await Navigator.pushNamed(context, '/detail', arguments: c);
          _muatUlang();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Mahasiswa'),
        actions: [
          DropdownButton<String>(
            value: _filterKategori,
            underline: const SizedBox(),
            icon: const Icon(Icons.filter_list, color: Colors.pink),
            items: _kategoriOpsi
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: (v) {
              setState(() => _filterKategori = v!);
              _muatUlang();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _muatUlang,
          ),
        ],
      ),
      body: FutureBuilder<List<Catatan>>(
        future: _futureCatatan,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            final e = snapshot.error;
            final pesan = e is ApiException ? e.message : 'Terjadi kesalahan: $e';
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 8),
                  Text(pesan, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(onPressed: _muatUlang, child: const Text('Coba lagi')),
                ],
              ),
            );
          }
          var data = snapshot.data ?? const [];
          if (_filterKategori != 'Semua') {
            data = data.where((c) => c.kategori == _filterKategori).toList();
          }
          if (data.isEmpty) return const _EmptyState();
          return ListView.separated(
            itemCount: data.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            padding: const EdgeInsets.all(12),
            itemBuilder: (_, i) => _itemCatatan(data[i]),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _bukaForm(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
        backgroundColor: Colors.pink[200],
        foregroundColor: Colors.pink[900],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notes, size: 64, color: Colors.pink[100]),
          const SizedBox(height: 16),
          Text(
            'Belum ada catatan.\nTap + untuk menambah.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.pink[300]),
          ),
        ],
      ),
    );
  }
}

class CatatanFormPage extends StatefulWidget {
  final Catatan? initial;
  const CatatanFormPage({super.key, this.initial});

  @override
  State<CatatanFormPage> createState() => _CatatanFormPageState();
}

class _CatatanFormPageState extends State<CatatanFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _judulCtrl;
  late final TextEditingController _isiCtrl;
  late String _kategori;
  final _kategoriOpsi = const ['Kuliah', 'Tugas', 'Pribadi', 'Lainnya'];

  bool get _isEdit => widget.initial != null;
  bool _menyimpan = false;

  @override
  void initState() {
    super.initState();
    _judulCtrl = TextEditingController(text: widget.initial?.judul ?? '');
    _isiCtrl = TextEditingController(text: widget.initial?.isi ?? '');
    _kategori = widget.initial?.kategori ?? 'Kuliah';
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _isiCtrl.dispose();
    super.dispose();
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _menyimpan = true);
    try {
      if (_isEdit) {
        final updated = widget.initial!.copyWith(
          judul: _judulCtrl.text.trim(),
          isi: _isiCtrl.text.trim(),
          kategori: _kategori,
        );
        await ApiClient.instance.update(updated);
      } else {
        final baru = Catatan(
          judul: _judulCtrl.text.trim(),
          isi: _isiCtrl.text.trim(),
          kategori: _kategori,
          dibuatPada: DateTime.now(),
        );
        await ApiClient.instance.insert(baru);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_isEdit ? 'Catatan diperbarui' : 'Catatan ditambahkan'),
      ));
      Navigator.pop(context);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _menyimpan = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan: ${e.message}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Edit Catatan' : 'Tambah Catatan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _judulCtrl,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Judul tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: _kategori,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  border: OutlineInputBorder(),
                ),
                items: _kategoriOpsi
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (v) => setState(() => _kategori = v!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _isiCtrl,
                decoration: const InputDecoration(
                  labelText: 'Isi Catatan',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Isi tidak boleh kosong' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _menyimpan ? null : _simpan,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: _menyimpan
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('SIMPAN'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DetailCatatanPage extends StatelessWidget {
  final Catatan catatan;
  const DetailCatatanPage({super.key, required this.catatan});

  String _formatTanggal(DateTime dt) {
    final local = dt.toLocal();
    return "${local.day}/${local.month}/${local.year} ${local.hour}:${local.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Catatan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.pushNamed(context, '/form', arguments: catatan);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              catatan.judul,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.pink[800],
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(catatan.kategori),
                  backgroundColor: Colors.pink[50],
                  labelStyle: TextStyle(color: Colors.pink[900]),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTanggal(catatan.dibuatPada),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const Divider(height: 32),
            Text(
              catatan.isi,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    height: 1.5,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
