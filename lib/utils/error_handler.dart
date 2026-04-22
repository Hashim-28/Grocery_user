import 'package:supabase_flutter/supabase_flutter.dart';

class ErrorHandler {
  static String getFriendlyMessage(Object e) {
    if (e is AuthException) {
      return _friendlyAuthMessage(e.message);
    } else if (e is PostgrestException) {
      return _friendlyPostgrestMessage(e);
    }

    final msg = e.toString();
    final lower = msg.toLowerCase();

    if (lower.contains('network') || lower.contains('socket') || lower.contains('connection')) {
      return 'Network error. Please check your internet connection.';
    }
    if (lower.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }
    if (lower.contains('permission') || lower.contains('denied')) {
      return 'Access denied. Please contact support or check your permissions.';
    }

    // Strip class prefixes like "Exception: ..." or "PostgrestException: ..."
    final colonIndex = msg.indexOf(': ');
    if (colonIndex != -1 && colonIndex < 40) {
      return msg.substring(colonIndex + 2);
    }
    if (msg.startsWith('Exception')) return 'Something went wrong. Please try again.';
    return msg.length > 120 ? 'Something went wrong. Please try again.' : msg;
  }

  static String _friendlyAuthMessage(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid login credentials') || lower.contains('invalid_credentials')) {
      return 'Invalid email or password. Please try again.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Please verify your email before logging in.';
    }
    if (lower.contains('user not found')) {
      return 'No account found with this email.';
    }
    if (lower.contains('too many requests') || lower.contains('rate limit')) {
      return 'Too many attempts. Please try again later.';
    }
    return message;
  }

  static String _friendlyPostgrestMessage(PostgrestException e) {
    final lower = e.message.toLowerCase();
    
    if (lower.contains('duplicate key value') || lower.contains('unique constraint')) {
      return 'This record already exists. Please try another name or ID.';
    }
    if (lower.contains('violates foreign key constraint') || lower.contains('foreign_key_violation')) {
      return 'Cannot perform this action because it is linked to other active records.';
    }
    if (lower.contains('check constraint')) {
      return 'Invalid data provided. Please check your inputs.';
    }
    if (lower.contains('row-level security') || lower.contains('rls')) {
      return 'You do not have permission to perform this action.';
    }
    if (lower.contains('not null constraint')) {
      return 'Required fields cannot be empty.';
    }

    if (e.message.isNotEmpty && e.message.length < 100) {
      return e.message;
    }
    
    return 'Action failed. Please verify your data and try again.';
  }
}
