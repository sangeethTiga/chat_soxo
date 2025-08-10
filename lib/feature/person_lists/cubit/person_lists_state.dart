part of 'person_lists_cubit.dart';

class PersonListsState extends Equatable {
  final List<UserResponse>? personList;
  final ApiFetchStatus? isUser;
  final List<UserResponse>? selectedUsers;
  final bool isSelectionMode;
  final ApiFetchStatus? isCreate;
  final ChatListResponse? chatListResponse;

  const PersonListsState({
    this.personList,
    this.isUser = ApiFetchStatus.idle,
    this.selectedUsers,
    this.isSelectionMode = false,
    this.isCreate = ApiFetchStatus.idle,
    this.chatListResponse,
  });

  PersonListsState copyWith({
    List<UserResponse>? personList,
    ApiFetchStatus? isUser,
    List<UserResponse>? selectedUsers,
    bool? isSelectionMode,
    ApiFetchStatus? isCreate,
    ChatListResponse? chatListResponse,
  }) {
    return PersonListsState(
      personList: personList ?? this.personList,
      isUser: isUser ?? this.isUser,
      selectedUsers: selectedUsers ?? this.selectedUsers,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      isCreate: isCreate ?? this.isCreate,
      chatListResponse: chatListResponse ?? this.chatListResponse,
    );
  }

  bool isUserSelected(int userId) {
    return selectedUsers?.any((user) => user.id == userId) ?? false;
  }

  @override
  List<Object?> get props => [
    personList,
    isUser,
    selectedUsers,
    isSelectionMode,
    isCreate,
    chatListResponse,
  ];
}

class InitialPersonListsState extends PersonListsState {}
