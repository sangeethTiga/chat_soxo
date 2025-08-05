part of 'person_lists_cubit.dart';

class PersonListsState extends Equatable {
  final List<UserResponse>? personList;
  final ApiFetchStatus? isUser;
  final List<UserResponse>? selectedUsers;
  final bool isSelectionMode;
  final ApiFetchStatus? isCreate;

  const PersonListsState({
    this.personList,
    this.isUser = ApiFetchStatus.idle,
    this.selectedUsers,
    this.isSelectionMode = false,
    this.isCreate = ApiFetchStatus.idle,
  });

  PersonListsState copyWith({
    List<UserResponse>? personList,
    ApiFetchStatus? isUser,
    List<UserResponse>? selectedUsers,
    bool? isSelectionMode,
    ApiFetchStatus? isCreate,
  }) {
    return PersonListsState(
      personList: personList ?? this.personList,
      isUser: isUser ?? this.isUser,
      selectedUsers: selectedUsers ?? this.selectedUsers,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      isCreate: isCreate ?? this.isCreate,
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
  ];
}

class InitialPersonListsState extends PersonListsState {}
