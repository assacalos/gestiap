import 'package:http/http.dart' as http;

Future<void> sendPasswordEmail(String email, String password) async {
  try {
    var url = 'https://api.sendgrid.com/v3/mail/send';
    var headers = {
      'Authorization': 'Bearer YOUR_SENDGRID_API_KEY',
      'Content-Type': 'application/json',
    };

    var body = {
      "personalizations": [
        {
          "to": [
            {"email": email},
          ],
          "subject": "Your New Account Details",
        },
      ],
      "from": {"email": "your-email@example.com"},
      "content": [
        {
          "type": "text/plain",
          "value":
              "Hello, \n\nYour account has been created. Here are your credentials:\nEmail: $email\nPassword: $password\nPlease change your password once you log in.",
        },
      ],
    };

    var response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: body,
    );
    if (response.statusCode == 202) {
      print("Email sent successfully");
    } else {
      print("Failed to send email");
    }
  } catch (e) {
    print("Erreur lors de l'envoi de l'email: $e");
  }
}
