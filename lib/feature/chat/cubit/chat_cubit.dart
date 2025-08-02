import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'chat_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(InitilaHomeState());
}
