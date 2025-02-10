import 'package:equatable/equatable.dart';

abstract class LoginState extends Equatable {
  @override
  List<Object> get props => [];
}

class LoginInitial extends LoginState {}

class LoginLoading extends LoginState {}

class LoginSuccess extends LoginState {
  final String token;
  final String userType;
  final String? garageName;

  LoginSuccess({
    required this.token,
    required this.userType,
    this.garageName,
  });

  @override
  List<Object> get props => [token, userType];
}

class LoginFailure extends LoginState {
  final String error;

  LoginFailure({required this.error});

  @override
  List<Object> get props => [error];
}
