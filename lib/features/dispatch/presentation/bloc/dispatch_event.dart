import 'package:equatable/equatable.dart';

abstract class DispatchEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchDispatchRecords extends DispatchEvent {}
