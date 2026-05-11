import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/login_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;

  AuthBloc({required this.loginUseCase}) : super(const AuthInitial()) {
    on<EmailChanged>((event, emit) {
      emit(AuthInitial(email: event.email, password: state.password));
    });

    on<PasswordChanged>((event, emit) {
      emit(AuthInitial(email: state.email, password: event.password));
    });

    on<LoginRequested>(_onLoginRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state.email.isEmpty || state.password.isEmpty) {
      emit(AuthFailureState("Please enter email and password",
          email: state.email, password: state.password));
      return;
    }

    emit(AuthLoading(email: state.email, password: state.password));
    final result = await loginUseCase(state.email, state.password);
    
    result.fold(
      (failure) => emit(AuthFailureState(failure.message,
          email: state.email, password: state.password)),
      (response) => emit(AuthSuccess(response,
          email: state.email, password: state.password)),
    );
  }
}
