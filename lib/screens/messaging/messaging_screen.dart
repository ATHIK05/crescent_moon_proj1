import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/messaging_provider.dart';
import '../../widgets/empty_state.dart';
import '../../models/message_model.dart';
import 'chat_screen.dart';

class MessagingScreen extends StatelessWidget {
  const MessagingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: Consumer<MessagingProvider>(
        builder: (context, messagingProvider, child) {
          if (messagingProvider.chats.isEmpty) {
            return const EmptyState(
              icon: Icons.message,
              title: 'No Messages',
              message: 'Your conversations with doctors will appear here.',
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              // Refresh chats
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: messagingProvider.chats.length,
              itemBuilder: (context, index) {
                final chat = messagingProvider.chats[index];
                return _buildChatCard(context, chat);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatCard(BuildContext context, ChatModel chat) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          child: Text(
            chat.doctorName.split(' ').map((name) => name[0]).take(2).join(),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Text(
          'Dr. ${chat.doctorName}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: chat.lastMessage != null
            ? Text(
                chat.lastMessage!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              )
            : Text(
                'No messages yet',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (chat.lastMessageTime != null)
              Text(
                _formatTime(chat.lastMessageTime!),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            if (chat.unreadCount > 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  chat.unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChatScreen(chat: chat),
            ),
          );
        },
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return DateFormat('MMM d').format(time);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}