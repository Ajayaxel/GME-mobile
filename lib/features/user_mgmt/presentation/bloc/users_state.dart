import 'package:equatable/equatable.dart';
import '../../domain/models/user_model.dart';

abstract class UsersState extends Equatable {
  @override
  List<Object?> get props => [];
}

class UsersInitial extends UsersState {}

class UsersLoading extends UsersState {}

class UsersLoaded extends UsersState {
  final List<UserModel> users;
  UsersLoaded({required this.users});

  @override
  List<Object?> get props => [users];
}

class UserActionSuccess extends UsersState {
  final String message;
  UserActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class UsersError extends UsersState {
  final String message;
  UsersError({required this.message});

  @override
  List<Object?> get props => [message];
}
