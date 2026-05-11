import 'package:equatable/equatable.dart';

abstract class WarehousingEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchWarehousingRecords extends WarehousingEvent {}
