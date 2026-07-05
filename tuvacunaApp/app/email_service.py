import os
import resend
from dotenv import load_dotenv

# Load environment variables from .env file
load_dotenv()

class EmailService:
    def __init__(self):
        self.api_key = os.getenv("RESEND_API_KEY")
        if not self.api_key:
            raise ValueError("RESEND_API_KEY is not set in the environment variables.")
        resend.api_key = self.api_key

    def send_email(self, to_email: str, subject: str, content: str, from_email: str = "onboarding@resend.dev"):
        """
        Sends an email using the Resend API.
        
        Args:
            to_email (str): The recipient's email address.
            subject (str): The subject of the email.
            content (str): The HTML content of the email.
            from_email (str): The sender's email address. Defaults to onboarding@resend.dev (for testing).
                              In production, use a verified domain (e.g., info@yourdomain.com).
        """
        params = {
            "from": from_email,
            "to": [to_email],
            "subject": subject,
            "html": content,
        }
        
        try:
            response = resend.Emails.send(params)
            return response
        except Exception as e:
            print(f"Failed to send email: {e}")
            raise e
