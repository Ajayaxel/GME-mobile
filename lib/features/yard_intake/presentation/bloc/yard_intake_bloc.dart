import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repository/yard_intake_repository.dart';
import 'yard_intake_event.dart';
import 'yard_intake_state.dart';

class YardIntakeBloc extends Bloc<YardIntakeEvent, YardIntakeState> {
  final YardIntakeRepository repository;

  YardIntakeBloc({required this.repository}) : super(YardIntakeInitial()) {
    on<FetchYardIntake>(_onFetchYardIntake);
    on<DeleteYardIntake>(_onDeleteYardIntake);
    on<UpdateYardIntake>(_onUpdateYardIntake);
    on<CreateYardIntake>(_onCreateYardIntake);
  }

  Future<void> _onFetchYardIntake(
    FetchYardIntake event,
    Emitter<YardIntakeState> emit,
  ) async {
    emit(YardIntakeLoading());
    final result = await repository.getYardIntake();
    result.fold(
      (failure) => emit(YardIntakeError(failure.message)),
      (intakeList) => emit(YardIntakeLoaded(intakeList)),
    );
  }

  Future<void> _onDeleteYardIntake(
    DeleteYardIntake event,
    Emitter<YardIntakeState> emit,
  ) async {
    emit(YardIntakeDeleteLoading());
    final result = await repository.deleteYardIntake(event.id);
    result.fold(
      (failure) => emit(YardIntakeError(failure.message)),
      (_) => emit(YardIntakeDeleteSuccess()),
    );
  }

  Future<void> _onUpdateYardIntake(
    UpdateYardIntake event,
    Emitter<YardIntakeState> emit,
  ) async {
    emit(YardIntakeUpdateLoading());
    final result = await repository.updateYardIntake(event.id, event.data);
    result.fold(
      (failure) => emit(YardIntakeError(failure.message)),
      (_) => emit(YardIntakeUpdateSuccess()),
    );
  }

  Future<void> _onCreateYardIntake(
    CreateYardIntake event,
    Emitter<YardIntakeState> emit,
  ) async {
    emit(YardIntakeCreateLoading());
    final result = await repository.createYardIntake(event.data);
    result.fold(
      (failure) => emit(YardIntakeError(failure.message)),
      (_) => emit(YardIntakeCreateSuccess()),
    );
  }
}
