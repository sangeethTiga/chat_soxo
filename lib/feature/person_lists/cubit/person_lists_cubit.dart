import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:soxo_chat/feature/chat/domain/models/chat_res/chat_list_response.dart';
import 'package:soxo_chat/feature/person_lists/domain/models/chat_request/chat_request.dart';
import 'package:soxo_chat/feature/person_lists/domain/models/user_response.dart';
import 'package:soxo_chat/feature/person_lists/domain/repositories/person_repositories.dart';
import 'package:soxo_chat/shared/app/enums/api_fetch_status.dart';

part 'person_lists_state.dart';

@injectable
class PersonListsCubit extends Cubit<PersonListsState> {
  final PersonListRepositories _personListRepositories;
  PersonListsCubit(this._personListRepositories)
    : super(InitialPersonListsState());

  Future<void> getPersonList() async {
    emit(state.copyWith(isUser: ApiFetchStatus.loading));
    final res = await _personListRepositories.personList();
    if (res.data != null) {
      emit(
        state.copyWith(personList: res.data, isUser: ApiFetchStatus.success),
      );
    } else {
      emit(state.copyWith(isUser: ApiFetchStatus.failed));
    }
  }

  void toggleUserSelection(UserResponse user) {
    final currentSelected = List<UserResponse>.from(state.selectedUsers ?? []);

    final existingIndex = currentSelected.indexWhere((u) => u.id == user.id);

    if (existingIndex != -1) {
      currentSelected.removeAt(existingIndex);
    } else {
      currentSelected.add(user);
    }

    emit(
      state.copyWith(
        selectedUsers: currentSelected,
        isSelectionMode: currentSelected.isNotEmpty,
      ),
    );
  }

  void addUserToSelection(UserResponse user) {
    if (!state.isUserSelected(user.id ?? 0)) {
      final updatedSelection = List<UserResponse>.from(
        state.selectedUsers ?? [],
      )..add(user);
      emit(
        state.copyWith(selectedUsers: updatedSelection, isSelectionMode: true),
      );
    }
  }

  void removeUserFromSelection(UserResponse user) {
    final updatedSelection = state.selectedUsers
        ?.where((u) => u.id != user.id)
        .toList();

    emit(
      state.copyWith(
        selectedUsers: updatedSelection,
        isSelectionMode: updatedSelection?.isNotEmpty,
      ),
    );
  }

  Future<ChatListResponse?> createChat(ChatRequest req) async {
    try {
      emit(state.copyWith(isCreate: ApiFetchStatus.loading));

      final res = await _personListRepositories.createChat(req);

      if (res.data != null && res.data!.chatId != null) {
        log('SUCCESS - Chat created with ID: ${res.data!.chatId}');
        emit(
          state.copyWith(
            isCreate: ApiFetchStatus.success,
            chatListResponse: res.data,
          ),
        );
        return res.data;
      } else {
        log('FAILED - No data or chatId in response');
        emit(state.copyWith(isCreate: ApiFetchStatus.failed));
        return null;
      }
    } catch (e) {
      log('ERROR creating chat: $e');
      emit(state.copyWith(isCreate: ApiFetchStatus.failed));
      return null;
    }
  }

  Future<void> initStateOfClear() async {
    emit(
      state.copyWith(
        selectedUsers: [],
        isSelectionMode: false,
        isCreate: ApiFetchStatus.idle,
        isUser: ApiFetchStatus.idle,
      ),
    );
  }
}
