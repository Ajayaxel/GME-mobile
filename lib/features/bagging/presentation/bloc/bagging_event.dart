import 'package:equatable/equatable.dart';

abstract class BaggingEvent extends Equatable {
  const BaggingEvent();

  @override
  List<Object?> get props => [];
}

class FetchBaggingEntries extends BaggingEvent {}

class CreateBaggingEntry extends BaggingEvent {
  final Map<String, dynamic> entryData;
  const CreateBaggingEntry(this.entryData);

  @override
  List<Object?> get props => [entryData];
}

class DeleteBaggingEntry extends BaggingEvent {
  final String id;
  const DeleteBaggingEntry(this.id);

  @override
  List<Object?> get props => [id];
}
