import 'package:equatable/equatable.dart';

abstract class UsersEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchUsers extends UsersEvent {}

class CreateUser extends UsersEvent {
  final Map<String, dynamic> userData;
  CreateUser({required this.userData});

  @override
  List<Object?> get props => [userData];
}

class DeleteUser extends UsersEvent {
  final String userId;
  DeleteUser({required this.userId});

  @override
  List<Object?> get props => [userId];
}
