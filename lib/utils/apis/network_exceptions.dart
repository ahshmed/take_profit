import 'package:dio/dio.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'network_exceptions.freezed.dart';

@freezed
class NetworkExceptions with _$NetworkExceptions {
  const factory NetworkExceptions.requestCancelled() = RequestCancelled;

  const factory NetworkExceptions.unauthorizedRequest() = UnauthorizedRequest;

  const factory NetworkExceptions.badRequest() = BadRequest;

  const factory NetworkExceptions.notFound(String reason, Response? response) =
  NotFound;

  const factory NetworkExceptions.methodNotAllowed() = MethodNotAllowed;

  const factory NetworkExceptions.notAcceptable() = NotAcceptable;

  const factory NetworkExceptions.requestTimeout() = RequestTimeout;

  const factory NetworkExceptions.sendTimeout(
      String reason, Response? response) = SendTimeout;

  const factory NetworkExceptions.conflict() = Conflict;

  const factory NetworkExceptions.internalServerError() = InternalServerError;

  const factory NetworkExceptions.notImplemented() = NotImplemented;

  const factory NetworkExceptions.serviceUnavailable() = ServiceUnavailable;

  const factory NetworkExceptions.noInternetConnection() = NoInternetConnection;

  const factory NetworkExceptions.formatException() = FormatException;

  const factory NetworkExceptions.unableToProcess() = UnableToProcess;

  const factory NetworkExceptions.defaultError(String error) = DefaultError;

  const factory NetworkExceptions.unexpectedError() = UnexpectedError;

  static NetworkExceptions handleResponse(
      int? statusCode, DioException error, Response? response) {
    //print("....error status code...$statusCode");
    errorStatusCode = statusCode!;
    switch (statusCode) {
      case 400:
        return NetworkExceptions.notFound(error.message.toString(), response);
      case 401:
        return NetworkExceptions.notFound(error.message.toString(), response);
      case 403:
        return const NetworkExceptions.unauthorizedRequest();
      case 404:
        return NetworkExceptions.notFound(error.message.toString(), response);
      case 409:
        return const NetworkExceptions.conflict();
      case 408:
        return const NetworkExceptions.requestTimeout();
      case 500:
        return const NetworkExceptions.internalServerError();
      case 503:
        return const NetworkExceptions.serviceUnavailable();
      case 504:
        return const NetworkExceptions.serviceUnavailable();
      default:
        var responseCode = statusCode;
        return NetworkExceptions.defaultError(
          "Received invalid status code: $responseCode",
        );
    }
  }

  static NetworkExceptions getDioException(error) {
    if (error is Exception) {
      try {
        late NetworkExceptions networkExceptions;
        if (error is DioException) { // Changed from DioError to DioException
          switch (error.type) {
            case DioExceptionType.cancel:
              networkExceptions = const NetworkExceptions.requestCancelled();
              break;
            case DioExceptionType.connectionTimeout: // Changed from connectTimeout
              networkExceptions = const NetworkExceptions.requestTimeout();
              break;
            case DioExceptionType.unknown: // Changed from other
              if (error.error.runtimeType.toString() == "SocketException") {
                networkExceptions =
                const NetworkExceptions.noInternetConnection();
              } else {
                networkExceptions = NetworkExceptions.sendTimeout(
                    error.message.toString(), error.response);
              }
              break;
            case DioExceptionType.receiveTimeout:
              networkExceptions =
                  NetworkExceptions.sendTimeout("Server taking too long to respond!", error.response);
              break;
            case DioExceptionType.badResponse: // Changed from response
              networkExceptions = NetworkExceptions.handleResponse(
                  error.response?.statusCode, error, error.response);
              break;
            case DioExceptionType.sendTimeout:
              networkExceptions =
                  NetworkExceptions.sendTimeout(error.message.toString(), error.response);
              break;
            case DioExceptionType.connectionError: // New in Dio v5
              networkExceptions = const NetworkExceptions.noInternetConnection();
              break;
            case DioExceptionType.badCertificate: // New in Dio v5
              networkExceptions = const NetworkExceptions.defaultError("Bad SSL Certificate");
              break;
          }
        } else if (error.runtimeType.toString() == "SocketException") {
          networkExceptions = const NetworkExceptions.noInternetConnection();
        } else if (error.runtimeType.toString() == "FormatException") {
          networkExceptions = const NetworkExceptions.formatException();
        } else {
          networkExceptions = const NetworkExceptions.unexpectedError();
        }
        return networkExceptions;
      } catch (_) {
        return const NetworkExceptions.unexpectedError();
      }
    } else {
      if (error.toString().contains("is not a subtype of")) {
        return const NetworkExceptions.unableToProcess();
      } else {
        return const NetworkExceptions.unexpectedError();
      }
    }
  }

  static String getErrorMessage(NetworkExceptions networkExceptions) {
    var errorMessage = "";
    networkExceptions.when(notImplemented: () {
      errorMessage = "Not Implemented";
    }, requestCancelled: () {
      errorMessage = "Request Cancelled";
    }, internalServerError: () {
      errorMessage = "Internal Server Error";
    }, notFound: (String reason, Response? response) {
      errorMessage = reason;
    }, serviceUnavailable: () {
      errorMessage = "Service unavailable";
    }, methodNotAllowed: () {
      errorMessage = "Method Allowed";
    }, badRequest: () {
      errorMessage = "Bad request";
    }, unauthorizedRequest: () {
      errorMessage = "Unauthorized request";
    }, unexpectedError: () {
      errorMessage = "Unexpected error occurred";
    }, requestTimeout: () {
      errorMessage = "Connection request timeout";
    }, noInternetConnection: () {
      errorMessage = "No internet connection";
    }, conflict: () {
      errorMessage = "Error due to a conflict";
    }, sendTimeout: (String reason, Response? response) {
      errorMessage =
      "Server taking too long to respond! \n$reason \n$response";
    }, unableToProcess: () {
      errorMessage = "Unable to process the data";
    }, defaultError: (String error) {
      errorMessage = error;
    }, formatException: () {
      errorMessage = "FormatException something went wrong with data ";
    }, notAcceptable: () {
      errorMessage = "Not acceptable";
    });
    return errorMessage;
  }

  static int errorStatusCode = 0;
}