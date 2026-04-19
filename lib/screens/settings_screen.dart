import 'package:flutter/material.dart';

import '../utils/theme.dart';

class SettingsScreen extends StatelessWidget {

  const SettingsScreen({super.key});

  @override

  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: MyfyTheme.darkBackground,

      appBar: AppBar(

        title: const Text('Settings'),

        leading: IconButton(

          icon: const Icon(Icons.arrow_back_ios_new_rounded),

          onPressed: () => Navigator.pop(context),

        ),

      ),

      body: ListView(

        padding: const EdgeInsets.all(20),

        children: [

          _SectionTitle(title: 'Download'),

          _SettingTile(

            icon: Icons.folder_rounded,

            title: 'Download Location',

            subtitle: '/storage/emulated/0/Download/Myfy',

            onTap: () {},

          ),

          _SettingTile(

            icon: Icons.high_quality_rounded,

            title: 'Default Audio Quality',

            subtitle: '320 kbps',

            onTap: () {},

          ),

          const Divider(color: MyfyTheme.borderColor, height: 32),

          _SectionTitle(title: 'Server'),

          _SettingTile(

            icon: Icons.dns_rounded,

            title: 'Termux Server IP',

            subtitle: 'http://127.0.0.1:5000',

            onTap: () {},

          ),

          _SettingTile(

            icon: Icons.sync_rounded,

            title: 'Test Connection',

            subtitle: 'Check if backend is reachable',

            onTap: () {

              ScaffoldMessenger.of(context).showSnackBar(

                const SnackBar(content: Text('Testing connection...')),

              );

            },

          ),

          const Divider(color: MyfyTheme.borderColor, height: 32),

          _SectionTitle(title: 'Appearance'),

          _SettingTile(

            icon: Icons.dark_mode_rounded,

            title: 'Theme',

            subtitle: 'Dark (Orange)',

            onTap: () {},

          ),

          const Divider(color: MyfyTheme.borderColor, height: 32),

          _SectionTitle(title: 'About'),

          _SettingTile(

            icon: Icons.info_outline_rounded,

            title: 'Version',

            subtitle: '1.0.0',

            onTap: () {},

          ),

        ],

      ),

    );

  }

}

class _SectionTitle extends StatelessWidget {

  final String title;

  const _SectionTitle({required this.title});

  @override

  Widget build(BuildContext context) {

    return Padding(

      padding: const EdgeInsets.only(bottom: 12, left: 8),

      child: Text(

        title,

        style: const TextStyle(

          color: MyfyTheme.primaryOrange,

          fontSize: 14,

          fontWeight: FontWeight.w600,

          letterSpacing: 0.5,

        ),

      ),

    );

  }

}

class _SettingTile extends StatelessWidget {

  final IconData icon;

  final String title;

  final String subtitle;

  final VoidCallback onTap;

  const _SettingTile({

    required this.icon,

    required this.title,

    required this.subtitle,

    required this.onTap,

  });

  @override

  Widget build(BuildContext context) {

    return ListTile(

      leading: Icon(icon, color: MyfyTheme.primaryOrange),

      title: Text(title, style: const TextStyle(color: Colors.white)),

      subtitle: Text(subtitle, style: const TextStyle(color: MyfyTheme.textSecondary, fontSize: 13)),

      trailing: const Icon(Icons.chevron_right_rounded, color: MyfyTheme.textSecondary, size: 20),

      onTap: onTap,

      contentPadding: const EdgeInsets.symmetric(horizontal: 8),

    );

  }

}