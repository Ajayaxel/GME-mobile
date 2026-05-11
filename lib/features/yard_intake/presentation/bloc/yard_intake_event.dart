import 'package:equatable/equatable.dart';

abstract class YardIntakeEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchYardIntake extends YardIntakeEvent {}

class DeleteYardIntake extends YardIntakeEvent {
  final String id;

  DeleteYardIntake(this.id);

  @override
  List<Object> get props => [id];
}

class UpdateYardIntake extends YardIntakeEvent {
  final String id;
  final Map<String, dynamic> data;

  UpdateYardIntake(this.id, this.data);

  @override
  List<Object> get props => [id, data];
}

class CreateYardIntake extends YardIntakeEvent {
  final Map<String, dynamic> data;

  CreateYardIntake(this.data);

  @override
  List<Object> get props => [data];
}
