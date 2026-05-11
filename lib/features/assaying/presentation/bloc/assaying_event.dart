import 'package:equatable/equatable.dart';

abstract class AssayingEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchAssayingRecords extends AssayingEvent {}
