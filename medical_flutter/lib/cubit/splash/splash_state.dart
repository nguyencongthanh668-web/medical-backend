import 'package:equatable/equatable.dart';

enum SplashStatus {initial, loading, success, failure}

class SplashState extends Equatable {
  final SplashStatus status;
  final bool? isRememberMe;
  final String? message;

  const SplashState({required this.status,
    this.isRememberMe,
    this.message,
  });

  SplashState copyWith({SplashStatus? status,
    bool? isRememberMe,
    String? message,
  }) {
    return SplashState(
      status: status ?? this.status,
      isRememberMe: isRememberMe ?? this.isRememberMe,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
    status,
    isRememberMe,
    message,
  ];
}