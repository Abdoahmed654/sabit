import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sapit/core/storage/auth_storage.dart';
import 'package:sapit/features/chat/domain/entities/chat_group.dart';
import 'package:sapit/features/chat/presentation/bloc/chat_bloc.dart';
import 'package:sapit/features/chat/presentation/bloc/chat_event.dart';
import 'package:sapit/features/chat/presentation/bloc/chat_state.dart';
import 'package:sapit/features/chat/presentation/pages/chat_messages_screen.dart';
import 'package:sapit/features/friends/presentation/bloc/friends_bloc.dart';
import 'package:sapit/features/friends/presentation/bloc/friends_event.dart';
import 'package:sapit/features/friends/presentation/bloc/friends_state.dart';

class ChatGroupsScreen extends StatefulWidget {
  const ChatGroupsScreen({super.key});

  @override
  State<ChatGroupsScreen> createState() => _ChatGroupsScreenState();
}

class _ChatGroupsScreenState extends State<ChatGroupsScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  late ChatBloc _chatBloc;
  late FriendsBloc _friendsBloc;
  int _previousTabIndex = 0;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_handleTabChange);
    WidgetsBinding.instance.addObserver(this);
  }

  void _handleTabChange() {
    // Only trigger when tab animation completes and index actually changed
    if (!_tabController.indexIsChanging) {
      final currentIndex = _tabController.index;
      if (currentIndex != _previousTabIndex) {
        _previousTabIndex = currentIndex;
        // Load cached data immediately when tab changes
        if (currentIndex == 0) {
          // Groups tab - always load (cached data will show first)
          _chatBloc.add(const LoadGroupsEvent());
        } else if (currentIndex == 1) {
          // Friends tab - always load (cached data will show first)
          _friendsBloc.add(const LoadFriendsEvent());
        } else if (currentIndex == 2) {
          // Requests tab - always load (cached data will show first)
          _friendsBloc.add(const LoadPendingRequestsEvent());
        }
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Save references to BLoCs safely
    _chatBloc = context.read<ChatBloc>();
    _friendsBloc = context.read<FriendsBloc>();
    _loadCurrentUserId();
    _loadData();
  }

  Future<void> _loadCurrentUserId() async {
    _currentUserId = await AuthStorage.getUserId();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Reload data when app comes to foreground
    if (state == AppLifecycleState.resumed) {
      _loadData();
    }
  }

  void _loadData() {
    _chatBloc.add(const LoadGroupsEvent());
    _friendsBloc.add(const LoadFriendsEvent());
    _friendsBloc.add(const LoadPendingRequestsEvent());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ChatBloc, ChatState>(
          listener: (context, state) {
            if (state is GroupLeft) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is GroupCreated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is MemberAdded) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is MemberRemoved) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is ChatError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
        BlocListener<FriendsBloc, FriendsState>(
          listener: (context, state) {
            // Reload chat groups when a friend request is accepted (private chat is created)
            if (state is FriendRequestAccepted) {
              _chatBloc.add(const LoadGroupsEvent());
            }
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Chat & Friends'),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(Icons.group_add),
              onPressed: () {
                _showCreateGroupDialog(context);
              },
              tooltip: 'Create Group',
            ),
            IconButton(
              icon: const Icon(Icons.person_add),
              onPressed: () {
                context.push('/friends/add');
              },
              tooltip: 'Add Friend',
            ),
          ],
          elevation: 0,
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(icon: Icon(Icons.chat), text: 'Groups'),
              Tab(icon: Icon(Icons.people), text: 'Friends'),
              Tab(icon: Icon(Icons.person_add), text: 'Requests'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildGroupsTab(),
            _buildFriendsTab(),
            _buildRequestsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildGroupsTab() {
    return BlocConsumer<ChatBloc, ChatState>(
      listener: (context, state) {
        if (state is ChatError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is ChatLoading) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (state is GroupsLoaded) {
          if (state.groups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 64,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No chat groups available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _chatBloc.add(const LoadGroupsEvent());
                    },
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _chatBloc.add(const LoadGroupsEvent());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: state.groups.length,
              itemBuilder: (context, index) {
                final group = state.groups[index];
                return _buildGroupCard(context, group);
              },
            ),
          );
        }

        // For any other state (including MessagesLoaded), show a refresh button
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 16),
              Text(
                'Pull down to load chat groups',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  _chatBloc.add(const LoadGroupsEvent());
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Load Groups'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFriendsTab() {
    return BlocConsumer<FriendsBloc, FriendsState>(
      listener: (context, state) {
        if (state is FriendsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is FriendsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is FriendsLoaded) {
          if (state.friends.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No friends yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: () {
                      context.push('/friends/add');
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('Add Friends'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _friendsBloc.add(const LoadFriendsEvent());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: state.friends.length,
              itemBuilder: (context, index) {
                final friend = state.friends[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        friend.displayName[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      friend.displayName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text('Level ${friend.level}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star, size: 14, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text('${friend.xp}', style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                            Row(
                              children: [
                                const Icon(Icons.monetization_on, size: 14, color: Colors.orange),
                                const SizedBox(width: 4),
                                Text('${friend.coins}', style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }

        // Show loading indicator while loading cached data (will be replaced quickly with cached data)
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildGroupCard(BuildContext context, ChatGroup group) {
    // For private chats with 2 members, show the other person's name
    String? otherPersonName;
    String? otherPersonAvatar;
    if (group.type == GroupType.PRIVATE && 
        group.members != null && 
        group.members!.length == 2 && 
        _currentUserId != null) {
      try {
        final otherMember = group.members!.firstWhere(
          (m) => m.userId != _currentUserId,
        );
        otherPersonName = otherMember.displayName;
        otherPersonAvatar = otherMember.avatarUrl;
      } catch (_) {
        // If current user not found in members, use first member
        otherPersonName = group.members!.first.displayName;
        otherPersonAvatar = group.members!.first.avatarUrl;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ListTile(
        leading: otherPersonAvatar != null
            ? CircleAvatar(
                backgroundImage: NetworkImage(otherPersonAvatar),
                backgroundColor: _getGroupColor(group.type),
              )
            : CircleAvatar(
                backgroundColor: _getGroupColor(group.type),
                child: otherPersonName != null
                    ? Text(
                        otherPersonName[0].toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      )
                    : Icon(
                        _getGroupIcon(group.type),
                        color: Colors.white,
                      ),
              ),
        title: Text(
          otherPersonName ?? group.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          _getGroupTypeLabel(group, otherPersonName),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.arrow_forward_ios, size: 16),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                if (value == 'leave') {
                  _showLeaveGroupDialog(context, group);
                } else if (value == 'manage') {
                  _showManageMembersDialog(context, group);
                }
              },
              itemBuilder: (context) => [
                if (group.type != GroupType.PUBLIC && group.type != GroupType.CHALLENGE)
                  const PopupMenuItem(
                    value: 'manage',
                    child: Row(
                      children: [
                        Icon(Icons.people, color: Colors.blue),
                        SizedBox(width: 8),
                        Text('Manage Members'),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'leave',
                  child: Row(
                    children: [
                      Icon(Icons.exit_to_app, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Leave Group'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatMessagesScreen(group: group),
            ),
          );
          // Reload groups when returning from messages screen
          if (mounted) {
            _chatBloc.add(const LoadGroupsEvent());
          }
        },
      ),
    );
  }

  void _showCreateGroupDialog(BuildContext context) {
    final nameController = TextEditingController();
    final selectedMembers = <String>{};

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Create Group'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Group Name',
                    hintText: 'Enter group name',
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Add Members:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: BlocBuilder<FriendsBloc, FriendsState>(
                    builder: (context, friendsState) {
                      if (friendsState is FriendsError) {
                        return Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red),
                              const SizedBox(height: 8),
                              Text(friendsState.message),
                              TextButton(
                                onPressed: () {
                                  context.read<FriendsBloc>().add(const LoadFriendsEvent());
                                },
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (friendsState is FriendsLoaded) {
                        if (friendsState.friends.isEmpty) {
                          return const Center(
                            child: Text('No friends yet. Add some friends first!'),
                          );
                        }

                        return ListView.builder(
                          itemCount: friendsState.friends.length,
                          itemBuilder: (context, index) {
                            final friend = friendsState.friends[index];
                            final isSelected = selectedMembers.contains(friend.id);
                            return CheckboxListTile(
                              title: Text(friend.displayName),
                              subtitle: Text(friend.email),
                              secondary: CircleAvatar(
                                backgroundImage: friend.avatarUrl != null 
                                  ? NetworkImage(friend.avatarUrl!) 
                                  : null,
                                child: friend.avatarUrl == null
                                  ? Text(friend.displayName[0].toUpperCase())
                                  : null,
                              ),
                              value: isSelected,
                              onChanged: (value) {
                                setState(() {
                                  if (value == true) {
                                    selectedMembers.add(friend.id);
                                  } else {
                                    selectedMembers.remove(friend.id);
                                  }
                                });
                              },
                            );
                          },
                        );
                      }

                      // Show shimmer loading effect instead of spinner
                      return ListView.builder(
                        itemCount: 3,
                        itemBuilder: (context, index) => const ShimmerListItem(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter a group name')),
                  );
                  return;
                }
                // Close dialog immediately to avoid hanging UI
                Navigator.pop(dialogContext);
                // Create private group with selected members
                _chatBloc.add(CreateGroupEvent(
                  name: nameController.text.trim(),
                  memberIds: selectedMembers.toList(),
                ));
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showManageMembersDialog(BuildContext context, ChatGroup group) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Manage Members - ${group.name}'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (group.members != null && group.members!.isNotEmpty) ...[
                const Text('Current Members:', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 200,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: group.members!.length,
                    itemBuilder: (context, index) {
                      final member = group.members![index];
                      final isCurrentUser = member.userId == _currentUserId;
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: member.avatarUrl != null
                              ? NetworkImage(member.avatarUrl!)
                              : null,
                          child: member.avatarUrl == null
                              ? Text(member.displayName?[0].toUpperCase() ?? 'U')
                              : null,
                        ),
                        title: Text(member.displayName ?? 'Unknown'),
                        trailing: isCurrentUser
                            ? const Text('You', style: TextStyle(color: Colors.grey))
                            : IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () {
                                  _chatBloc.add(RemoveMemberFromGroupEvent(
                                    groupId: group.id,
                                    memberId: member.userId,
                                  ));
                                  Navigator.pop(dialogContext);
                                },
                              ),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(dialogContext);
                  _showAddMemberDialog(context, group);
                },
                icon: const Icon(Icons.person_add),
                label: const Text('Add Member'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showAddMemberDialog(BuildContext context, ChatGroup group) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Member'),
        content: SizedBox(
          width: double.maxFinite,
          child: BlocBuilder<FriendsBloc, FriendsState>(
            builder: (context, friendsState) {
              if (friendsState is FriendsLoaded) {
                // Filter out members already in the group
                final existingMemberIds = group.members?.map((m) => m.userId).toSet() ?? {};
                final availableFriends = friendsState.friends
                    .where((f) => !existingMemberIds.contains(f.id))
                    .toList();

                if (availableFriends.isEmpty) {
                  return const Text('No friends available to add');
                }

                return SizedBox(
                  height: 300,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: availableFriends.length,
                    itemBuilder: (context, index) {
                      final friend = availableFriends[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: friend.avatarUrl != null
                              ? NetworkImage(friend.avatarUrl!)
                              : null,
                          child: friend.avatarUrl == null
                              ? Text(friend.displayName[0].toUpperCase())
                              : null,
                        ),
                        title: Text(friend.displayName),
                        subtitle: Text(friend.email),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.green),
                          onPressed: () {
                            _chatBloc.add(AddMemberToGroupEvent(
                              groupId: group.id,
                              userId: friend.id,
                            ));
                            Navigator.pop(dialogContext);
                          },
                        ),
                      );
                    },
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showLeaveGroupDialog(BuildContext context, ChatGroup group) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Leave Group'),
        content: Text('Are you sure you want to leave "${group.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _chatBloc.add(LeaveGroupEvent(groupId: group.id));
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  Color _getGroupColor(GroupType type) {
    switch (type) {
      case GroupType.PUBLIC:
        return Colors.blue;
      case GroupType.PRIVATE:
        return Colors.purple;
      case GroupType.CHALLENGE:
        return Colors.orange;
    }
  }

  IconData _getGroupIcon(GroupType type) {
    switch (type) {
      case GroupType.PUBLIC:
        return Icons.public;
      case GroupType.PRIVATE:
        return Icons.lock;
      case GroupType.CHALLENGE:
        return Icons.emoji_events;
    }
  }

  String _getGroupTypeLabel(ChatGroup group, String? otherPersonName) {
    // For private chats between 2 people, don't show "Private Group"
    if (group.type == GroupType.PRIVATE && otherPersonName != null) {
      return ''; // Empty subtitle for 1-on-1 chats
    }
    
    switch (group.type) {
      case GroupType.PUBLIC:
        return 'Public Group';
      case GroupType.PRIVATE:
        return 'Private Group';
      case GroupType.CHALLENGE:
        return 'Challenge Group';
    }
  }

  Widget _buildRequestsTab() {
    return BlocConsumer<FriendsBloc, FriendsState>(
      listener: (context, state) {
        if (state is FriendRequestAccepted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          _friendsBloc.add(const LoadPendingRequestsEvent());
        } else if (state is FriendRequestBlocked) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.orange,
            ),
          );
          _friendsBloc.add(const LoadPendingRequestsEvent());
        } else if (state is FriendsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is FriendsLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is PendingRequestsLoaded) {
          if (state.requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_add_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No pending requests',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You\'re all caught up!',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _friendsBloc.add(const LoadPendingRequestsEvent());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.requests.length,
              itemBuilder: (context, index) {
                final request = state.requests[index];
                final user = request.user;

                if (user == null) {
                  return const SizedBox.shrink();
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: user.avatarUrl != null
                                  ? NetworkImage(user.avatarUrl!)
                                  : null,
                              child: user.avatarUrl == null
                                  ? Text(
                                      user.displayName[0].toUpperCase(),
                                      style: const TextStyle(fontSize: 24),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.displayName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    user.email,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      _buildStatChip(
                                        Icons.star,
                                        'Lvl ${user.level}',
                                        Colors.amber,
                                      ),
                                      const SizedBox(width: 8),
                                      _buildStatChip(
                                        Icons.bolt,
                                        '${user.xp} XP',
                                        Colors.blue,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _friendsBloc.add(
                                    AcceptFriendRequestEvent(request.id),
                                  );
                                },
                                icon: const Icon(Icons.check),
                                label: const Text('Accept'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  _friendsBloc.add(
                                    BlockFriendRequestEvent(request.id),
                                  );
                                },
                                icon: const Icon(Icons.block),
                                label: const Text('Block'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }

        // Show loading indicator while loading cached data (will be replaced quickly with cached data)
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Widget _buildStatChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerListItem extends StatelessWidget {
  const ShimmerListItem({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Avatar shimmer
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          // Text shimmer
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 150,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Checkbox shimmer
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}

