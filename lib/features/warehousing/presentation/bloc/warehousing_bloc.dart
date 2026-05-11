import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repository/warehousing_repository.dart';
import 'warehousing_event.dart';
import 'warehousing_state.dart';

class WarehousingBloc extends Bloc<WarehousingEvent, WarehousingState> {
  final WarehousingRepository repository;

  WarehousingBloc({required this.repository}) : super(WarehousingInitial()) {
    on<FetchWarehousingRecords>((event, emit) async {
      emit(WarehousingLoading());
      try {
        final records = await repository.getRecords();
        emit(WarehousingLoaded(records: records));
      } catch (e) {
        emit(WarehousingError(message: e.toString()));
      }
    });
  }
}
