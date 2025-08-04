part of 'person_lists_cubit.dart';

class PersonListsState extends Equatable {
  final List<UserResponse>? personList;
  final ApiFetchStatus? isUser;
  final List<UserResponse>? selectedUsers;
  final bool isSelectionMode;

  const PersonListsState({
    this.personList,
    this.isUser = ApiFetchStatus.idle,
    this.selectedUsers,
    this.isSelectionMode = false,
  });

  PersonListsState copyWith({
    List<UserResponse>? personList,
    ApiFetchStatus? isUser,
    List<UserResponse>? selectedUsers,
    bool? isSelectionMode,
  }) {
    return PersonListsState(
      personList: personList ?? this.personList,
      isUser: isUser ?? this.isUser,
      selectedUsers: selectedUsers ?? this.selectedUsers,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
    );
  }

  bool isUserSelected(int userId) {
    return selectedUsers?.any((user) => user.id == userId)?? false;
  }

  @override
  List<Object?> get props => [personList, isUser, selectedUsers, isSelectionMode];
}

class InitialPersonListsState extends PersonListsState {}
