import requests
import imaplib
import email
import time
import json
from datetime import datetime
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

class PharmacyConsultationSystem:
    """
    Complete system for pharmacy consultations via email
    - Send consultation requests to pharmacists
    - Automatically receive and display their replies
    """
    
    def __init__(self, brevo_api_key, email_address, email_password, smtp_server="smtp.gmail.com", imap_server="imap.gmail.com"):
        """
        Initialize the pharmacy consultation system
        
        Args:
            brevo_api_key: Your Brevo API key for sending emails
            email_address: Your email address (for receiving replies)
            email_password: Your email app password (for reading replies)
            smtp_server: SMTP server for email
            imap_server: IMAP server for reading emails
        """
        self.brevo_api_key = brevo_api_key
        self.email_address = email_address
        self.email_password = email_password
        self.imap_server = imap_server
        
        self.brevo_headers = {
            "accept": "application/json",
            "api-key": self.brevo_api_key,
            "content-type": "application/json"
        }
        
        # Store sent consultations to track replies
        self.sent_consultations = {}
    
    def send_consultation_request(self, pharmacist_email, pharmacist_name, patient_name, 
                                symptoms, medical_history="", current_medications="", urgency_level="Normal"):
        """
        Send consultation request to pharmacist
        
        Args:
            pharmacist_email: Pharmacist's email address
            pharmacist_name: Pharmacist's name
            patient_name: Patient's name
            symptoms: Description of symptoms (e.g., "fever, headache, cough")
            medical_history: Patient's medical history
            current_medications: Current medications patient is taking
            urgency_level: "Low", "Normal", "High", "Emergency"
        
        Returns:
            dict: Response with success status and consultation ID
        """
        
        consultation_id = f"CONSULT_{int(time.time())}"
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        
        # Create professional consultation email
        subject = f"🏥 Pharmacy Consultation Request - {patient_name} [{urgency_level} Priority]"
        
        message_content = f"""
Dear {pharmacist_name},

I hope this email finds you well. I am writing to request your professional consultation for the following case:

📋 PATIENT INFORMATION:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
👤 Patient Name: {patient_name}
📅 Consultation Date: {timestamp}
🆔 Consultation ID: {consultation_id}
⚠️  Priority Level: {urgency_level}

🩺 PRESENTING SYMPTOMS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
{symptoms}

📜 MEDICAL HISTORY:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
{medical_history if medical_history else "No significant medical history reported"}

💊 CURRENT MEDICATIONS:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
{current_medications if current_medications else "No current medications reported"}

🙏 REQUEST FOR CONSULTATION:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Could you please provide your professional advice on:
• Recommended over-the-counter medications
• Dosage recommendations
• Any precautions or warnings
• When to seek further medical attention
• Duration of treatment

Your expertise and guidance would be greatly appreciated.

Please reply to this email with your recommendations.

Thank you for your time and professional service.

Best regards,
Healthcare Assistant
📧 {self.email_address}
📞 For urgent cases, please reply within 2-4 hours

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️  DISCLAIMER: This consultation is for informational purposes only. 
Patient should consult with a licensed physician for serious conditions.
        """.strip()
        
        # Send via Brevo API
        payload = {
            "sender": {
                "name": "Healthcare Assistant",
                "email": self.email_address
            },
            "to": [
                {
                    "email": pharmacist_email,
                    "name": pharmacist_name
                }
            ],
            "subject": subject,
            "textContent": message_content,
            "tags": ["pharmacy-consultation", f"priority-{urgency_level.lower()}"]
        }
        
        try:
            response = requests.post("https://api.brevo.com/v3/smtp/email", 
                                   json=payload, headers=self.brevo_headers)
            
            if response.status_code == 201:
                result = response.json()
                message_id = result.get('messageId', 'N/A')
                
                # Store consultation details for tracking replies
                self.sent_consultations[consultation_id] = {
                    "pharmacist_email": pharmacist_email,
                    "pharmacist_name": pharmacist_name,
                    "patient_name": patient_name,
                    "symptoms": symptoms,
                    "timestamp": timestamp,
                    "message_id": message_id,
                    "status": "sent",
                    "reply_received": False
                }
                
                print(f"✅ Consultation sent to {pharmacist_name}")
                print(f"📋 Consultation ID: {consultation_id}")
                print(f"📧 Message ID: {message_id}")
                
                return {
                    "success": True,
                    "consultation_id": consultation_id,
                    "message_id": message_id,
                    "pharmacist": pharmacist_name
                }
            else:
                error_data = response.json()
                print(f"❌ Failed to send consultation: {error_data}")
                return {"success": False, "error": error_data}
                
        except Exception as e:
            print(f"❌ Error sending consultation: {str(e)}")
            return {"success": False, "error": str(e)}
    
    def check_for_replies(self, mark_as_read=True):
        """
        Check for replies from pharmacists
        
        Args:
            mark_as_read: Whether to mark emails as read after processing
        
        Returns:
            list: List of replies with consultation details
        """
        replies = []
        
        try:
            print("📧 Checking for new replies from pharmacists...")
            
            # Connect to IMAP server
            mail = imaplib.IMAP4_SSL(self.imap_server)
            mail.login(self.email_address, self.email_password)
            mail.select('inbox')
            
            # Search for unread emails
            status, messages = mail.search(None, 'UNSEEN')
            
            if messages[0]:
                email_ids = messages[0].split()
                print(f"📬 Found {len(email_ids)} unread emails")
                
                for email_id in email_ids:
                    # Fetch email
                    status, msg_data = mail.fetch(email_id, '(RFC822)')
                    
                    for response_part in msg_data:
                        if isinstance(response_part, tuple):
                            # Parse email
                            email_message = email.message_from_bytes(response_part[1])
                            
                            sender_email = email.utils.parseaddr(email_message['From'])[1]
                            sender_name = email.utils.parseaddr(email_message['From'])[0]
                            subject = email_message['Subject'] or ""
                            date = email_message['Date']
                            
                            # Check if it's a reply to our consultation
                            is_consultation_reply = any(
                                pharmacy_email == sender_email 
                                for consult in self.sent_consultations.values() 
                                for pharmacy_email in [consult.get('pharmacist_email')]
                            )
                            
                            if is_consultation_reply or "consultation" in subject.lower():
                                # Get email body
                                body = ""
                                if email_message.is_multipart():
                                    for part in email_message.walk():
                                        if part.get_content_type() == "text/plain":
                                            body = part.get_payload(decode=True).decode('utf-8', errors='ignore')
                                            break
                                else:
                                    body = email_message.get_payload(decode=True).decode('utf-8', errors='ignore')
                                
                                # Find matching consultation
                                matching_consultation = None
                                for consult_id, consult_data in self.sent_consultations.items():
                                    if consult_data['pharmacist_email'] == sender_email:
                                        matching_consultation = consult_data
                                        matching_consultation['reply_received'] = True
                                        break
                                
                                reply_data = {
                                    'pharmacist_email': sender_email,
                                    'pharmacist_name': sender_name or "Pharmacist",
                                    'subject': subject,
                                    'reply_content': body.strip(),
                                    'received_date': date,
                                    'consultation_details': matching_consultation
                                }
                                
                                replies.append(reply_data)
                                
                                # Mark as read if requested
                                if mark_as_read:
                                    mail.store(email_id, '+FLAGS', '\\Seen')
            
            mail.close()
            mail.logout()
            
            if replies:
                print(f"✅ Found {len(replies)} pharmacy consultation replies!")
            else:
                print("📭 No new replies from pharmacists")
            
        except Exception as e:
            print(f"❌ Error checking for replies: {str(e)}")
        
        return replies
    
    def display_reply(self, reply_data):
        """
        Display pharmacy reply in a nice format
        
        Args:
            reply_data: Reply data dictionary from check_for_replies()
        """
        print("\n" + "="*80)
        print("💊 PHARMACY CONSULTATION REPLY RECEIVED")
        print("="*80)
        
        consultation = reply_data.get('consultation_details', {})
        
        if consultation:
            print(f"👤 Patient: {consultation.get('patient_name', 'Unknown')}")
            print(f"🩺 Original Symptoms: {consultation.get('symptoms', 'N/A')}")
            print(f"📅 Consultation Date: {consultation.get('timestamp', 'N/A')}")
            print("-" * 80)
        
        print(f"👨‍⚕️ Pharmacist: {reply_data['pharmacist_name']}")
        print(f"📧 Email: {reply_data['pharmacist_email']}")
        print(f"📅 Reply Date: {reply_data['received_date']}")
        print(f"📋 Subject: {reply_data['subject']}")
        print("-" * 80)
        print("💬 PHARMACIST RECOMMENDATIONS:")
        print("-" * 80)
        print(reply_data['reply_content'])
        print("="*80)
    
    def send_bulk_consultations(self, pharmacist_list, patient_name, symptoms, 
                              medical_history="", current_medications="", urgency_level="Normal"):
        """
        Send consultation to multiple pharmacists
        
        Args:
            pharmacist_list: List of dicts with 'email' and 'name' keys
            patient_name: Patient's name
            symptoms: Symptoms description
            medical_history: Medical history
            current_medications: Current medications
            urgency_level: Priority level
        
        Returns:
            dict: Results for each pharmacist
        """
        results = {}
        
        print(f"📤 Sending consultation to {len(pharmacist_list)} pharmacists...")
        
        for i, pharmacist in enumerate(pharmacist_list, 1):
            email = pharmacist.get('email', '')
            name = pharmacist.get('name', 'Pharmacist')
            
            print(f"\n💊 {i}/{len(pharmacist_list)}: Sending to {name}")
            
            result = self.send_consultation_request(
                pharmacist_email=email,
                pharmacist_name=name,
                patient_name=patient_name,
                symptoms=symptoms,
                medical_history=medical_history,
                current_medications=current_medications,
                urgency_level=urgency_level
            )
            
            results[email] = result
            
            # Small delay between sends
            if i < len(pharmacist_list):
                time.sleep(1)
        
        return results
    
    def consultation_monitoring_loop(self, check_interval=30):
        """
        Continuously monitor for replies from pharmacists
        
        Args:
            check_interval: Seconds between reply checks
        """
        print(f"🔄 Starting consultation monitoring (checking every {check_interval} seconds)")
        print("Press Ctrl+C to stop monitoring")
        
        try:
            while True:
                replies = self.check_for_replies()
                
                for reply in replies:
                    self.display_reply(reply)
                
                if replies:
                    print(f"\n✅ Processed {len(replies)} new replies")
                
                print(f"⏰ Next check in {check_interval} seconds... (Ctrl+C to stop)")
                time.sleep(check_interval)
                
        except KeyboardInterrupt:
            print("\n🛑 Monitoring stopped by user")
        except Exception as e:
            print(f"❌ Error in monitoring loop: {str(e)}")


# =============================================================================
# 🎯 CONFIGURATION & USAGE EXAMPLES
# =============================================================================

def main():
    """Main consultation system demo"""
    
    # 🔴 YOUR CONFIGURATION
    BREVO_API_KEY = "Pasted_your_own_key"
    YOUR_EMAIL = "testingforarsalan@gmail.com"
    YOUR_EMAIL_PASSWORD = "Pasted_your_own_app_password"
  
    # Initialize system
    pharmacy_system = PharmacyConsultationSystem(
        brevo_api_key=BREVO_API_KEY,
        email_address=YOUR_EMAIL,
        email_password=YOUR_EMAIL_PASSWORD
    )
    
    print("🏥 PHARMACY CONSULTATION SYSTEM")
    print("="*60)
    
    # Example 1: Send consultation to single pharmacist
    print("\n📤 Sending consultation to pharmacist...")
    
    result = pharmacy_system.send_consultation_request(
        pharmacist_email="kingarain7866@gmail.com",  # Replace with real pharmacist email
        pharmacist_name="Dr. Smith",
        patient_name="John Doe",
        symptoms="Fever (101°F), headache, body aches, mild cough. Started 2 days ago.",
        medical_history="No known allergies. Hypertension controlled with medication.",
        current_medications="Lisinopril 10mg daily",
        urgency_level="Normal"
    )
    
    if result["success"]:
        print("✅ Consultation sent successfully!")
    
    # Example 2: Check for replies
    print("\n📧 Checking for pharmacist replies...")
    replies = pharmacy_system.check_for_replies()
    
    for reply in replies:
        pharmacy_system.display_reply(reply)

def bulk_consultation_example():
    """Send consultation to multiple pharmacists"""
    
    # 🔴 YOUR CONFIGURATION
    BREVO_API_KEY = "Pasted_your_own_key"
    YOUR_EMAIL = "testingforarsalan@gmail.com"
    YOUR_EMAIL_PASSWORD = "Pasted_your_own_app_password"


    pharmacy_system = PharmacyConsultationSystem(BREVO_API_KEY, YOUR_EMAIL, YOUR_EMAIL_PASSWORD)
    
    # List of pharmacists
    pharmacist_list = [
        {"email": "kingarain7866@gmail.com", "name": "Dr. Sarah Johnson"},
        {"email": "pharmacist2@pharmacy2.com", "name": "Dr. Mike Chen"},
        {"email": "pharmacist3@pharmacy3.com", "name": "Dr. Lisa Ahmed"}
    ]
    
    # Send to all pharmacists
    results = pharmacy_system.send_bulk_consultations(
        pharmacist_list=pharmacist_list,
        patient_name="Jane Smith",
        symptoms="Severe migraine headache, nausea, sensitivity to light. Duration: 6 hours.",
        medical_history="History of migraines, takes birth control pills",
        current_medications="Ortho Tri-Cyclen Lo",
        urgency_level="High"
    )
    
    # Show results
    print("\n📊 CONSULTATION RESULTS:")
    for email, result in results.items():
        status = "✅ Success" if result["success"] else "❌ Failed"
        print(f"{email}: {status}")

def monitoring_example():
    """Continuous monitoring for replies"""
    
    # 🔴 YOUR CONFIGURATION
    BREVO_API_KEY = "Pasted_your_own_key"
    YOUR_EMAIL = "testingforarsalan@gmail.com"
    YOUR_EMAIL_PASSWORD = "Pasted_your_own_app_password"
    
    pharmacy_system = PharmacyConsultationSystem(BREVO_API_KEY, YOUR_EMAIL, YOUR_EMAIL_PASSWORD)
    
    # Start continuous monitoring
    pharmacy_system.consultation_monitoring_loop(check_interval=60)  # Check every minute

# =============================================================================
# 🎯 READY TO USE
# =============================================================================

if __name__ == "__main__":
    print("💊 PHARMACY CONSULTATION EMAIL SYSTEM")
    print("="*60)
    print("This system can:")
    print("✅ Send professional consultation requests to pharmacists")
    print("✅ Automatically receive and display their replies")
    print("✅ Handle multiple pharmacists simultaneously")
    print("✅ Monitor continuously for new responses")
    print("="*60)
    
    print("\n🔧 SETUP REQUIRED:")
    print("1. Update BREVO_API_KEY, YOUR_EMAIL, YOUR_EMAIL_PASSWORD")
    print("2. Add real pharmacist email addresses")
    print("3. Uncomment one of the examples below:")
    print()
    
    # Uncomment ONE of these to test:
    main()                        # Send single consultation
    # bulk_consultation_example()   # Send to multiple pharmacists
    # monitoring_example()          # Continuous monitoring