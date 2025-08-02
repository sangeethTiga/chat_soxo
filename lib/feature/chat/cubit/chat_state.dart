part of 'chat_cubit.dart';

class ChatState extends Equatable {
  final bool? isArrow;

  const ChatState({this.isArrow = false});

  ChatState copyWith({bool? isArrow}) =>
      ChatState(isArrow: isArrow ?? this.isArrow);
  @override
  List<Object?> get props => [isArrow];
}

class InitilaChatState extends ChatState {}
