class Validators {
  static String? validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email es requerido';
    }
    
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(email)) {
      return 'Email inválido';
    }
    
    return null;
  }

  static String? validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Contraseña es requerida';
    }
    
    if (password.length < 6) {
      return 'Contraseña debe tener al menos 6 caracteres';
    }
    
    return null;
  }

  static String? validateNickname(String? nickname) {
    if (nickname == null || nickname.isEmpty) {
      return 'Nickname es requerido';
    }
    
    if (nickname.length < 3) {
      return 'Nickname debe tener al menos 3 caracteres';
    }
    
    if (nickname.length > 20) {
      return 'Nickname no puede exceder 20 caracteres';
    }
    
    return null;
  }

  static String? validateAge(int? age) {
    if (age == null) {
      return 'Edad es requerida';
    }
    
    if (age < 13) {
      return 'Debes tener al menos 13 años';
    }
    
    if (age > 120) {
      return 'Edad inválida';
    }
    
    return null;
  }

  static String? validateBio(String? bio) {
    if (bio == null || bio.isEmpty) {
      return 'Biografía es requerida';
    }
    
    if (bio.length < 10) {
      return 'Biografía debe tener al menos 10 caracteres';
    }
    
    if (bio.length > 500) {
      return 'Biografía no puede exceder 500 caracteres';
    }
    
    return null;
  }

  static String? validateDiscord(String? discord) {
    if (discord == null || discord.isEmpty) {
      return null; // Optional field
    }
    
    // Discord usernames must be 2-32 characters
    if (discord.length < 2 || discord.length > 32) {
      return 'Discord username inválido';
    }
    
    return null;
  }

  static String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName es requerido';
    }
    return null;
  }
}
