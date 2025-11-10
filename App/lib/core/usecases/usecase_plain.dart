abstract class UseCasePlain<Type, Params> {
  Future<Type> call(Params params);
}

class NoParamsPlain {
  const NoParamsPlain();
}
