import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repository/users_repository.dart';
import 'users_event.dart';
import 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  final UsersRepository repository;

  UsersBloc({required this.repository}) : super(UsersInitial()) {
    on<FetchUsers>((event, emit) async {
      emit(UsersLoading());
      try {
        final users = await repository.getUsers();
        emit(UsersLoaded(users: users));
      } catch (e) {
        emit(UsersError(message: e.toString()));
      }
    });

    on<CreateUser>((event, emit) async {
      emit(UsersLoading());
      try {
        await repository.createUser(event.userData);
        emit(UserActionSuccess(message: "User created successfully"));
        add(FetchUsers());
      } catch (e) {
        emit(UsersError(message: e.toString()));
      }
    });

    on<DeleteUser>((event, emit) async {
      emit(UsersLoading());
      try {
        await repository.deleteUser(event.userId);
        emit(UserActionSuccess(message: "User deleted successfully"));
        add(FetchUsers());
      } catch (e) {
        emit(UsersError(message: e.toString()));
      }
    });
  }
}
