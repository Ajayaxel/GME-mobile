import 'package:equatable/equatable.dart';
import '../../data/models/login_models.dart';

abstract class AuthState extends Equatable {
  final String email;
  final String password;

  const AuthState({this.email = '', this.password = ''});

  @override
  List<Object?> get props => [email, password];
}

class AuthInitial extends AuthState {
  const AuthInitial({super.email, super.password});
}

class AuthLoading extends AuthState {
  const AuthLoading({super.email, super.password});
}

class AuthSuccess extends AuthState {
  final LoginResponseModel response;

  const AuthSuccess(this.response, {super.email, super.password});

  @override
  List<Object?> get props => [response, email, password];
}

class AuthFailureState extends AuthState {
  final String message;

  const AuthFailureState(this.message, {super.email, super.password});

  @override
  List<Object?> get props => [message, email, password];
}
