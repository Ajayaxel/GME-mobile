import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repository/financials_repository.dart';
import 'financials_event.dart';
import 'financials_state.dart';

class FinancialsBloc extends Bloc<FinancialsEvent, FinancialsState> {
  final FinancialsRepository repository;

  FinancialsBloc({required this.repository}) : super(FinancialsInitial()) {
    on<FetchInvoices>((event, emit) async {
      emit(FinancialsLoading());
      try {
        final records = await repository.getInvoices();
        emit(FinancialsLoaded(invoices: records));
      } catch (e) {
        emit(FinancialsError(message: e.toString()));
      }
    });
  }
}
