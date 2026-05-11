import 'package:equatable/equatable.dart';
import '../../data/models/yard_intake_model.dart';

abstract class YardIntakeState extends Equatable {
  @override
  List<Object> get props => [];
}

class YardIntakeInitial extends YardIntakeState {}

class YardIntakeLoading extends YardIntakeState {}

class YardIntakeLoaded extends YardIntakeState {
  final List<YardIntakeModel> intakeList;

  YardIntakeLoaded(this.intakeList);

  @override
  List<Object> get props => [intakeList];
}

class YardIntakeError extends YardIntakeState {
  final String message;

  YardIntakeError(this.message);

  @override
  List<Object> get props => [message];
}

class YardIntakeDeleteLoading extends YardIntakeState {}

class YardIntakeDeleteSuccess extends YardIntakeState {}

class YardIntakeUpdateLoading extends YardIntakeState {}

class YardIntakeUpdateSuccess extends YardIntakeState {}

class YardIntakeCreateLoading extends YardIntakeState {}

class YardIntakeCreateSuccess extends YardIntakeState {}
