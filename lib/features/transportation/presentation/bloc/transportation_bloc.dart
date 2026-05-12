import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repository/transportation_repository.dart';
import 'transportation_event.dart';
import 'transportation_state.dart';

class TransportationBloc extends Bloc<TransportationEvent, TransportationState> {
  final TransportationRepository repository;

  TransportationBloc({required this.repository}) : super(TransportationInitial()) {
    on<FetchTransporters>(_onFetchTransporters);
    on<CreateTransporter>(_onCreateTransporter);
    on<CreateTrip>(_onCreateTrip);
  }

  Future<void> _onFetchTransporters(FetchTransporters event, Emitter<TransportationState> emit) async {
    emit(TransportationLoading());
    try {
      final records = await repository.getTransporters();
      emit(TransportationLoaded(transporters: records));
    } catch (e) {
      emit(TransportationError(message: e.toString()));
    }
  }

  Future<void> _onCreateTransporter(CreateTransporter event, Emitter<TransportationState> emit) async {
    try {
      await repository.createTransporter(event.data);
      emit(TransportationActionSuccess(message: "Transporter added successfully"));
      add(FetchTransporters());
    } catch (e) {
      emit(TransportationError(message: e.toString()));
    }
  }

  Future<void> _onCreateTrip(CreateTrip event, Emitter<TransportationState> emit) async {
    try {
      await repository.createTrip(event.data);
      emit(TransportationActionSuccess(message: "Trip assigned successfully"));
      add(FetchTransporters());
    } catch (e) {
      emit(TransportationError(message: e.toString()));
    }
  }
}
