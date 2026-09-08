import 'dart:async';

import 'package:blurb/features/auth/domain/exceptions/auth_exception.dart';
import 'package:blurb/features/auth/domain/repositories/auth_repository.dart';
import 'package:blurb/features/auth/presentation/cubits/social_auth/social_auth_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

class _OAuthRepository extends Fake implements AuthRepository {
	Future<void> Function() launch = () async {};
	int attempts = 0;

	@override
	Future<void> signInWithFacebook() {
		attempts++;
		return launch();
	}
}

void main() {
	test('can retry Facebook after returning from a closed browser', () async {
		final repository = _OAuthRepository();
		final launch = Completer<void>();
		repository.launch = () => launch.future;
		final cubit = SocialAuthCubit(authRepository: repository);
		addTearDown(cubit.close);

		final pending = cubit.signInWithFacebook();
		expect(cubit.state, isA<SocialAuthSubmitting>());
		await cubit.signInWithFacebook();
		expect(repository.attempts, 1);

		launch.complete();
		await pending;
		expect(cubit.state, isA<SocialAuthInitial>());
		await cubit.signInWithFacebook();
		expect(repository.attempts, 2);
	});

	test('reports browser launch failure and permits retry', () async {
		final repository = _OAuthRepository();
		repository.launch = () async {
			throw const AuthException(AuthExceptionCode.operationNotAllowed);
		};
		final cubit = SocialAuthCubit(authRepository: repository);
		addTearDown(cubit.close);

		await cubit.signInWithFacebook();
		expect(
			(cubit.state as SocialAuthFailure).code,
			AuthExceptionCode.operationNotAllowed,
		);
		repository.launch = () async {};
		await cubit.signInWithFacebook();
		expect(cubit.state, isA<SocialAuthInitial>());
	});

	test('OAuth completion is safe after the login page is disposed', () async {
		final repository = _OAuthRepository();
		final launch = Completer<void>();
		repository.launch = () => launch.future;
		final cubit = SocialAuthCubit(authRepository: repository);

		final pending = cubit.signInWithFacebook();
		await cubit.close();
		launch.complete();
		await expectLater(pending, completes);
	});
}
