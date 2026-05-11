import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repository/transportation_repository.dart';
import 'transportation_event.dart';
import 'transportation_state.dart';

class TransportationBloc extends Bloc<TransportationEvent, TransportationState> {
  final TransportationRepository repository;

  TransportationBloc({required this.repository}) : super(TransportationInitial()) {
    on<FetchTransporters>((event, emit) async {
      emit(TransportationLoading());
      try {
        final records = await repository.getTransporters();
        emit(TransportationLoaded(transporters: records));
      } catch (e) {
        emit(TransportationError(message: e.toString()));
      }
    });
  }
}
