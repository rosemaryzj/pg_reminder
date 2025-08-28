import 'package:flutter/material.dart';
import '../widgets/app_bar_widget.dart';

class LicensePage extends StatelessWidget {
  const LicensePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: MeoAppBar(
        title: '开源许可证',
        showBackButton: true,
        onBackPressed: () => Navigator.of(context).pop(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 应用许可证信息
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Remind - 项目管理应用',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Version 1.0.0',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'MIT License',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Copyright (c) 2024 Remind App\n\n'
                      'Permission is hereby granted, free of charge, to any person obtaining a copy '
                      'of this software and associated documentation files (the "Software"), to deal '
                      'in the Software without restriction, including without limitation the rights '
                      'to use, copy, modify, merge, publish, distribute, sublicense, and/or sell '
                      'copies of the Software, and to permit persons to whom the Software is '
                      'furnished to do so, subject to the following conditions:\n\n'
                      'The above copyright notice and this permission notice shall be included in all '
                      'copies or substantial portions of the Software.\n\n'
                      'THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR '
                      'IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, '
                      'FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE '
                      'AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER '
                      'LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, '
                      'OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE '
                      'SOFTWARE.',
                      style: TextStyle(fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 第三方许可证按钮
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.library_books,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('第三方开源许可证'),
                subtitle: const Text('查看应用中使用的第三方开源库许可证'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showThirdPartyLicenses(context),
              ),
            ),
            const SizedBox(height: 16),

            // 隐私政策
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.privacy_tip,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('隐私政策'),
                subtitle: const Text('了解我们如何保护您的隐私'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showPrivacyPolicy(context),
              ),
            ),
            const SizedBox(height: 16),

            // 使用条款
            Card(
              child: ListTile(
                leading: Icon(
                  Icons.description,
                  color: theme.colorScheme.primary,
                ),
                title: const Text('使用条款'),
                subtitle: const Text('应用使用条款和服务协议'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () => _showTermsOfService(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showThirdPartyLicenses(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: 'Remind',
      applicationVersion: '1.0.0',
      applicationIcon: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/images/app_logo.png',
            width: 30,
            height: 30,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('隐私政策'),
        content: const SingleChildScrollView(
          child: Text(
            '隐私政策\n\n'
            '最后更新日期：2024年1月\n\n'
            '1. 信息收集\n'
            '我们仅收集您主动提供的信息，包括：\n'
            '• 项目和模块数据\n'
            '• 任务和待办事项\n'
            '• 应用设置和偏好\n\n'
            '2. 信息使用\n'
            '我们使用收集的信息来：\n'
            '• 提供应用功能和服务\n'
            '• 改善用户体验\n'
            '• 保存您的数据和设置\n\n'
            '3. 信息保护\n'
            '• 所有数据仅存储在您的设备本地\n'
            '• 我们不会将您的数据传输到外部服务器\n'
            '• 您可以随时导出或删除您的数据\n\n'
            '4. 数据控制\n'
            '您对自己的数据拥有完全控制权：\n'
            '• 可以随时查看、修改或删除数据\n'
            '• 可以导出数据进行备份\n'
            '• 卸载应用将删除所有本地数据\n\n'
            '如有任何问题，请联系我们。',
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('使用条款'),
        content: const SingleChildScrollView(
          child: Text(
            '使用条款\n\n'
            '最后更新日期：2024年1月\n\n'
            '1. 接受条款\n'
            '通过下载、安装或使用本应用，您同意遵守这些使用条款。\n\n'
            '2. 应用描述\n'
            'Remind是一个项目管理应用，帮助用户组织和管理项目、任务和团队协作。\n\n'
            '3. 用户责任\n'
            '您同意：\n'
            '• 合法使用本应用\n'
            '• 不进行任何可能损害应用功能的行为\n'
            '• 对您的数据和账户安全负责\n\n'
            '4. 知识产权\n'
            '本应用及其内容受版权法保护。您获得使用许可，但不拥有应用的知识产权。\n\n'
            '5. 免责声明\n'
            '本应用按"现状"提供，我们不对以下情况承担责任：\n'
            '• 数据丢失或损坏\n'
            '• 应用中断或错误\n'
            '• 因使用应用而产生的任何损失\n\n'
            '6. 条款变更\n'
            '我们保留随时修改这些条款的权利。重大变更将通过应用内通知告知用户。\n\n'
            '7. 联系我们\n'
            '如对这些条款有任何疑问，请联系我们。',
            style: TextStyle(fontSize: 14, height: 1.4),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('关闭'),
          ),
        ],
      ),
    );
  }
}
