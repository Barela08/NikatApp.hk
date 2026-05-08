import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/providers_provider.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.providerId});
  final String providerId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  bool _sending = false;

  String _chatRoomId(String uid, String pid) {
    final sorted = [uid, pid]..sort();
    return sorted.join('_');
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    setState(() => _sending = true);
    _controller.clear();

    final chatId = _chatRoomId(user.id, widget.providerId);
    await FirebaseFirestore.instance
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .collection(AppConstants.messagesCollection)
        .add({
      'senderId': user.id,
      'senderName': user.name,
      'text': text,
      'type': 'text',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await FirebaseFirestore.instance
        .collection(AppConstants.chatsCollection)
        .doc(chatId)
        .set({
      'participants': [user.id, widget.providerId],
      'lastMessage': text,
      'lastMessageAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    setState(() => _sending = false);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final providerAsync = ref.watch(providerDetailProvider(widget.providerId));
    final user = userAsync.valueOrNull;

    if (user == null) return const Scaffold(body: Center(child: CircularProgressIndicator(color: AppColors.primary)));

    final chatId = _chatRoomId(user.id, widget.providerId);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: providerAsync.when(
          data: (p) => Text(p?.shopName ?? 'Chat'),
          loading: () => const Text('Chat'),
          error: (_, __) => const Text('Chat'),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(AppConstants.chatsCollection)
                  .doc(chatId)
                  .collection(AppConstants.messagesCollection)
                  .orderBy('createdAt')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                final messages = snapshot.data!.docs;

                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                if (messages.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('💬', style: TextStyle(fontSize: 60)),
                        SizedBox(height: 12),
                        Text('Start a conversation', style: TextStyle(color: AppColors.onSurfaceMuted)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, i) {
                    final msg = messages[i].data() as Map<String, dynamic>;
                    final isMe = msg['senderId'] == user.id;
                    final time = (msg['createdAt'] as Timestamp?)?.toDate();

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                        children: [
                          Container(
                            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.72),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isMe ? AppColors.primary : AppColors.surfaceVariant,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(16),
                                topRight: const Radius.circular(16),
                                bottomLeft: Radius.circular(isMe ? 16 : 4),
                                bottomRight: Radius.circular(isMe ? 4 : 16),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Text(msg['text'] ?? '', style: TextStyle(fontSize: 15, color: isMe ? Colors.black : AppColors.onSurface)),
                                if (time != null) ...[
                                  const SizedBox(height: 4),
                                  Text(DateFormat('hh:mm a').format(time),
                                      style: TextStyle(fontSize: 10, color: isMe ? Colors.black54 : AppColors.onSurfaceMuted)),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: const BoxDecoration(
              color: AppColors.surface,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(hintText: 'Type a message...', border: InputBorder.none, filled: false),
                      style: const TextStyle(fontSize: 15),
                      maxLines: null,
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: _sending ? null : _send,
                    child: Container(
                      width: 44, height: 44,
                      decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: _sending
                          ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                          : const Icon(Icons.send_rounded, color: Colors.black, size: 20),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
