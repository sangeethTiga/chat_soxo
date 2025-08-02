import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';

part 'chat_state.dart';

@injectable
class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(InitilaChatState());

  Future<void> arrowSelected() async {
    emit(state.copyWith(isArrow: !(state.isArrow ?? false)));
  }
}
