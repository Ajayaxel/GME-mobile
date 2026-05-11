import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../data/models/yard_intake_model.dart';

abstract class YardIntakeRepository {
  Future<Either<Failure, List<YardIntakeModel>>> getYardIntake();
  Future<Either<Failure, void>> deleteYardIntake(String id);
  Future<Either<Failure, void>> updateYardIntake(String id, Map<String, dynamic> data);
  Future<Either<Failure, void>> createYardIntake(Map<String, dynamic> data);
}
