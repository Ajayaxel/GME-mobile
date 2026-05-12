import 'package:equatable/equatable.dart';

abstract class DispatchEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchDispatchRecords extends DispatchEvent {}

class CreateDispatchRecord extends DispatchEvent {
  final Map<String, dynamic> record;
  CreateDispatchRecord({required this.record});

  @override
  List<Object?> get props => [record];
}

class DeleteDispatchRecord extends DispatchEvent {
  final String id;
  DeleteDispatchRecord({required this.id});

  @override
  List<Object?> get props => [id];
}
