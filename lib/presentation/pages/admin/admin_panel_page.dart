import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:premade/core/network/supabase_service.dart';
import 'package:premade/core/theme/app_colors.dart';

class AdminPanelPage extends ConsumerStatefulWidget {
  const AdminPanelPage({super.key});

  @override
  ConsumerState<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends ConsumerState<AdminPanelPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> _bannedUsers = [];
  List<Map<String, dynamic>> _reports = [];
  Map<String, dynamic> _stats = {};
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredUsers {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _users;

    return _users.where((user) {
      final nickname = user['nickname']?.toString().toLowerCase() ?? '';
      final email = user['email']?.toString().toLowerCase() ?? '';
      final country = user['country']?.toString().toLowerCase() ?? '';
      final role = user['role']?.toString().toLowerCase() ?? '';
      return nickname.contains(query) ||
          email.contains(query) ||
          country.contains(query) ||
          role.contains(query);
    }).toList();
  }

  Future<void> _loadAdminData() async {
    setState(() => _isLoading = true);
    try {
      final supabase = ref.read(supabaseServiceProvider);
      final users = await supabase.adminListUsers();
      final bannedUsers = await supabase.adminListBannedUsers();
      final reports = await supabase.adminListReports();
      final stats = await supabase.adminGetStats();

      if (mounted) {
        setState(() {
          _users = users;
          _bannedUsers = bannedUsers;
          _reports = reports;
          _stats = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cargar panel admin: $e')),
        );
      }
    }
  }

  Future<void> _openEditor([Map<String, dynamic>? user]) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => _AdminUserEditor(user: user),
    );
    if (changed == true) _loadAdminData();
  }

  Future<void> _deleteUser(Map<String, dynamic> user) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text(
          'Se marcara como eliminado a ${user['nickname'] ?? 'este usuario'}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    try {
      await ref
          .read(supabaseServiceProvider)
          .adminDeleteUserProfile(user['id'].toString());
      await _loadAdminData();
    } catch (e) {
      _showError('Error al eliminar: $e');
    }
  }

  Future<void> _banUser(Map<String, dynamic> user) async {
    final reasonController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Banear usuario'),
        content: TextField(
          controller: reasonController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Motivo',
            hintText: 'Ej: insultos, spam, acoso...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Banear', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    final reason = reasonController.text.trim();
    reasonController.dispose();
    if (confirmed != true) return;

    try {
      await ref.read(supabaseServiceProvider).adminBanUser(
            profileId: user['id'].toString(),
            reason: reason.isEmpty ? null : reason,
          );
      await _loadAdminData();
    } catch (e) {
      _showError('Error al banear: $e');
    }
  }

  Future<void> _unbanUser(Map<String, dynamic> user) async {
    try {
      await ref
          .read(supabaseServiceProvider)
          .adminUnbanUser(user['id'].toString());
      await _loadAdminData();
    } catch (e) {
      _showError('Error al quitar ban: $e');
    }
  }

  Future<void> _updateReportStatus(String reportId, String status) async {
    try {
      await ref.read(supabaseServiceProvider).adminUpdateReportStatus(
            reportId: reportId,
            status: status,
          );
      await _loadAdminData();
    } catch (e) {
      _showError('Error al actualizar reporte: $e');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textPrimary = theme.colorScheme.onSurface;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(Icons.arrow_back_rounded, color: textPrimary),
          ),
          title: Text(
            'Panel admin',
            style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              tooltip: 'Crear usuario',
              onPressed: () => _openEditor(),
              icon: const Icon(Icons.person_add_alt_1_rounded),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Usuarios'),
              Tab(text: 'Baneados'),
              Tab(text: 'Reportes'),
            ],
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  _buildUsersTab(),
                  _buildBannedTab(),
                  _buildReportsTab(),
                ],
              ),
      ),
    );
  }

  Widget _buildUsersTab() {
    final filteredUsers = _filteredUsers;

    return RefreshIndicator(
      onRefresh: _loadAdminData,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        itemCount: filteredUsers.isEmpty ? 3 : filteredUsers.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _StatsGrid(stats: _stats);
          }
          if (index == 1) {
            return _SearchBox(
              controller: _searchController,
              query: _searchQuery,
              onChanged: (value) => setState(() => _searchQuery = value),
              onClear: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
            );
          }

          if (filteredUsers.isEmpty) {
            return const Padding(
              padding: EdgeInsets.only(top: 28),
              child: Center(child: Text('No hay usuarios')),
            );
          }

          final user = filteredUsers[index - 2];
          return _UserCard(
            user: user,
            onTap: () => _openEditor(user),
            onEdit: () => _openEditor(user),
            onBan: () => _banUser(user),
            onDelete: () => _deleteUser(user),
          );
        },
      ),
    );
  }

  Widget _buildBannedTab() {
    return RefreshIndicator(
      onRefresh: _loadAdminData,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        itemCount: _bannedUsers.isEmpty ? 1 : _bannedUsers.length,
        itemBuilder: (context, index) {
          if (_bannedUsers.isEmpty) {
            return const Padding(
              padding: EdgeInsets.only(top: 44),
              child: Center(child: Text('No hay usuarios baneados')),
            );
          }
          final user = _bannedUsers[index];
          return _BannedUserCard(
            user: user,
            onUnban: () => _unbanUser(user),
          );
        },
      ),
    );
  }

  Widget _buildReportsTab() {
    return RefreshIndicator(
      onRefresh: _loadAdminData,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        itemCount: _reports.isEmpty ? 1 : _reports.length,
        itemBuilder: (context, index) {
          if (_reports.isEmpty) {
            return const Padding(
              padding: EdgeInsets.only(top: 44),
              child: Center(child: Text('No hay reportes')),
            );
          }
          final report = _reports[index];
          return _ReportCard(
            report: report,
            onStatus: (status) =>
                _updateReportStatus(report['id'].toString(), status),
            onBan: () => _banUser({
              'id': report['reported_user_id'],
              'nickname': report['reported_nickname'],
            }),
          );
        },
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _StatsGrid({required this.stats});

  @override
  Widget build(BuildContext context) {
    final items = [
      _StatItem('Usuarios', stats['total_users'] ?? 0, Icons.people_rounded),
      _StatItem(
          'Nuevos 7d', stats['new_users_7d'] ?? 0, Icons.trending_up_rounded),
      _StatItem('Baneados', stats['banned_users'] ?? 0, Icons.block_rounded),
      _StatItem('Reportes', stats['pending_reports'] ?? 0, Icons.flag_rounded),
    ];

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisExtent: 86,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
        ),
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primarySoft,
                  child: Icon(item.icon, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.value.toString(),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatItem {
  final String label;
  final dynamic value;
  final IconData icon;

  const _StatItem(this.label, this.value, this.icon);
}

class _SearchBox extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBox({
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: 'Buscar usuario',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: query.isEmpty
              ? null
              : IconButton(
                  tooltip: 'Limpiar',
                  onPressed: onClear,
                  icon: const Icon(Icons.close_rounded),
                ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onBan;
  final VoidCallback onDelete;

  const _UserCard({
    required this.user,
    required this.onTap,
    required this.onEdit,
    required this.onBan,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final role = user['role']?.toString() ?? 'member';
    final isBanned = user['banned_at'] != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: isBanned
              ? AppColors.error.withOpacity(0.12)
              : role == 'admin'
                  ? AppColors.accentLight
                  : AppColors.primarySoft,
          child: Icon(
            isBanned
                ? Icons.block_rounded
                : role == 'admin'
                    ? Icons.admin_panel_settings_rounded
                    : Icons.person_rounded,
            color: isBanned
                ? AppColors.error
                : role == 'admin'
                    ? AppColors.accent
                    : AppColors.primary,
          ),
        ),
        title: Text(
          user['nickname']?.toString() ?? 'Usuario',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text('${user['email'] ?? ''} - $role'),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') onEdit();
            if (value == 'ban') onBan();
            if (value == 'delete') onDelete();
          },
          itemBuilder: (context) => const [
            PopupMenuItem(value: 'edit', child: Text('Editar')),
            PopupMenuItem(value: 'ban', child: Text('Banear')),
            PopupMenuItem(value: 'delete', child: Text('Eliminar')),
          ],
        ),
      ),
    );
  }
}

class _BannedUserCard extends StatelessWidget {
  final Map<String, dynamic> user;
  final VoidCallback onUnban;

  const _BannedUserCard({
    required this.user,
    required this.onUnban,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.error.withOpacity(0.12),
          child: const Icon(Icons.block_rounded, color: AppColors.error),
        ),
        title: Text(
          user['nickname']?.toString() ?? 'Usuario',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        subtitle: Text(user['ban_reason']?.toString() ?? 'Sin motivo indicado'),
        trailing: TextButton(
          onPressed: onUnban,
          child: const Text('Quitar ban'),
        ),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final Map<String, dynamic> report;
  final ValueChanged<String> onStatus;
  final VoidCallback onBan;

  const _ReportCard({
    required this.report,
    required this.onStatus,
    required this.onBan,
  });

  @override
  Widget build(BuildContext context) {
    final status = report['status']?.toString() ?? 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flag_rounded, color: AppColors.error),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    report['reason']?.toString() ?? 'Reporte',
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
                _StatusChip(status: status),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Reportado: ${report['reported_nickname'] ?? 'Usuario'}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text('Por: ${report['reporter_nickname'] ?? 'Usuario'}'),
            if ((report['description']?.toString() ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(report['description'].toString()),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onBan,
                    icon: const Icon(Icons.block_rounded),
                    label: const Text('Banear'),
                  ),
                ),
                const SizedBox(width: 10),
                PopupMenuButton<String>(
                  onSelected: onStatus,
                  itemBuilder: (context) => const [
                    PopupMenuItem(value: 'pending', child: Text('Pendiente')),
                    PopupMenuItem(
                      value: 'under_review',
                      child: Text('En revision'),
                    ),
                    PopupMenuItem(value: 'resolved', child: Text('Resuelto')),
                    PopupMenuItem(
                        value: 'dismissed', child: Text('Descartado')),
                  ],
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Text('Estado'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'resolved' => AppColors.success,
      'dismissed' => AppColors.textSecondary,
      'under_review' => AppColors.warning,
      _ => AppColors.error,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status,
        style: TextStyle(color: color, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _AdminUserEditor extends ConsumerStatefulWidget {
  final Map<String, dynamic>? user;

  const _AdminUserEditor({this.user});

  @override
  ConsumerState<_AdminUserEditor> createState() => _AdminUserEditorState();
}

class _AdminUserEditorState extends ConsumerState<_AdminUserEditor> {
  late TextEditingController _authIdController;
  late TextEditingController _emailController;
  late TextEditingController _nicknameController;
  late TextEditingController _ageController;
  late TextEditingController _countryController;
  late TextEditingController _bioController;
  late TextEditingController _discordController;
  String _role = 'member';
  bool _isSaving = false;

  bool get _isEditing => widget.user != null;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _authIdController =
        TextEditingController(text: user?['auth_id']?.toString() ?? '');
    _emailController =
        TextEditingController(text: user?['email']?.toString() ?? '');
    _nicknameController =
        TextEditingController(text: user?['nickname']?.toString() ?? '');
    _ageController =
        TextEditingController(text: (user?['age'] ?? 18).toString());
    _countryController =
        TextEditingController(text: user?['country']?.toString() ?? 'Espana');
    _bioController =
        TextEditingController(text: user?['bio']?.toString() ?? '');
    _discordController = TextEditingController(
        text: user?['discord_username']?.toString() ?? '');
    _role = user?['role']?.toString() ?? 'member';
  }

  @override
  void dispose() {
    _authIdController.dispose();
    _emailController.dispose();
    _nicknameController.dispose();
    _ageController.dispose();
    _countryController.dispose();
    _bioController.dispose();
    _discordController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final age = int.tryParse(_ageController.text.trim());
    if (age == null || age < 13 || age > 120) {
      _showError('La edad debe estar entre 13 y 120');
      return;
    }
    if (_emailController.text.trim().isEmpty ||
        _nicknameController.text.trim().isEmpty ||
        _countryController.text.trim().isEmpty) {
      _showError('Email, nickname y pais son obligatorios');
      return;
    }
    if (!_isEditing && _authIdController.text.trim().isEmpty) {
      _showError('Para crear un perfil necesitas un auth_id existente');
      return;
    }

    setState(() => _isSaving = true);
    try {
      final supabase = ref.read(supabaseServiceProvider);
      if (_isEditing) {
        await supabase.adminUpdateUserProfile(
          profileId: widget.user!['id'].toString(),
          email: _emailController.text.trim(),
          nickname: _nicknameController.text.trim(),
          age: age,
          country: _countryController.text.trim(),
          role: _role,
          bio: _bioController.text.trim().isEmpty
              ? null
              : _bioController.text.trim(),
          discordUsername: _discordController.text.trim().isEmpty
              ? null
              : _discordController.text.trim(),
        );
      } else {
        await supabase.adminCreateUserProfile(
          authId: _authIdController.text.trim(),
          email: _emailController.text.trim(),
          nickname: _nicknameController.text.trim(),
          age: age,
          country: _countryController.text.trim(),
          role: _role,
        );
      }
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _showError('Error al guardar: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottomInset + 20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isEditing ? 'Editar usuario' : 'Crear perfil',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 16),
            if (!_isEditing) ...[
              _Field(controller: _authIdController, label: 'Auth ID existente'),
              const SizedBox(height: 12),
            ],
            _Field(controller: _emailController, label: 'Email'),
            const SizedBox(height: 12),
            _Field(controller: _nicknameController, label: 'Nickname'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _Field(
                    controller: _ageController,
                    label: 'Edad',
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Field(controller: _countryController, label: 'Pais'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _role,
              decoration: const InputDecoration(labelText: 'Rol'),
              items: const [
                DropdownMenuItem(value: 'member', child: Text('Member')),
                DropdownMenuItem(value: 'moderator', child: Text('Moderator')),
                DropdownMenuItem(value: 'admin', child: Text('Admin')),
              ],
              onChanged: (value) => setState(() => _role = value ?? 'member'),
            ),
            if (_isEditing) ...[
              const SizedBox(height: 12),
              _Field(controller: _bioController, label: 'Bio', maxLines: 3),
              const SizedBox(height: 12),
              _Field(controller: _discordController, label: 'Discord'),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : _save,
                icon: _isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_rounded),
                label: Text(_isSaving ? 'Guardando...' : 'Guardar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final TextInputType? keyboardType;

  const _Field({
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label),
    );
  }
}
