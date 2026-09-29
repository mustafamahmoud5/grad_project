import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../data/repositories/onboarding_repository.dart';

class OnboardingCubit extends Cubit<int> {
  OnboardingCubit({
    required OnboardingRepository repository,
    required this.pageCount,
  }) : _repository = repository,
       super(0);

  final OnboardingRepository _repository;
  final int pageCount;

  void changePage(int index) => emit(index.clamp(0, pageCount - 1));

  bool get isFirstPage => state == 0;

  bool get isLastPage => state == pageCount - 1;

  Future<void> complete() => _repository.complete();
}
