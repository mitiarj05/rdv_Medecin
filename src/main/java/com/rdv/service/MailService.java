package com.rdv.service;

import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

import com.rdv.model.Rdv;

public class MailService {

    private String apiKey;
    private String secretKey;
    private boolean isConfigured = false;

    public MailService() {
        // Récupérer les clés depuis les variables d'environnement Render
        apiKey = System.getenv("MAILJET_API_KEY");
        secretKey = System.getenv("MAILJET_SECRET_KEY");
        
        System.out.println("========== MAILJET INITIALIZATION ==========");
        System.out.println("MAILJET_API_KEY: " + (apiKey != null ? "✅ FOUND (" + apiKey.substring(0, 10) + "...)" : "❌ NOT FOUND"));
        System.out.println("MAILJET_SECRET_KEY: " + (secretKey != null ? "✅ FOUND (" + secretKey.substring(0, 10) + "...)" : "❌ NOT FOUND"));
        
        if (apiKey != null && !apiKey.isEmpty() && secretKey != null && !secretKey.isEmpty()) {
            isConfigured = true;
            System.out.println("✅ Mailjet is ready to send emails!");
        } else {
            System.err.println("❌ Mailjet NOT configured - missing API keys");
        }
        System.out.println("============================================");
    }

    public void envoyerConfirmation(Rdv rdv) {
        System.out.println("[MailService] Sending confirmation email...");
        
        if (!isConfigured) {
            System.err.println("[MailService] Mailjet not configured");
            return;
        }
        
        if (rdv == null || rdv.getPatient() == null || rdv.getMedecin() == null) {
            System.err.println("[MailService] Invalid RDV data");
            return;
        }
        
        String patientEmail = rdv.getPatient().getEmail();
        if (patientEmail == null || patientEmail.isEmpty()) {
            System.err.println("[MailService] No patient email");
            return;
        }
        
        System.out.println("[MailService] To: " + patientEmail);
        System.out.println("[MailService] Patient: " + rdv.getPatient().getNomPat());
        System.out.println("[MailService] Doctor: Dr. " + rdv.getMedecin().getNommed());
        System.out.println("[MailService] Date: " + rdv.getDateFormatee());
        
        // Construction de l'email HTML
        String htmlContent = "<!DOCTYPE html>" +
            "<html>" +
            "<head><meta charset='UTF-8'></head>" +
            "<body style='font-family: Arial, sans-serif;'>" +
            "<div style='max-width: 500px; margin: 0 auto; padding: 20px; border: 1px solid #ddd; border-radius: 10px;'>" +
            "<h2 style='color: #1a73e8;'>🏥 RDV Medical</h2>" +
            "<h3 style='color: #34a853;'>✓ Confirmation de rendez-vous</h3>" +
            "<p>Bonjour <strong>" + rdv.getPatient().getNomPat() + "</strong>,</p>" +
            "<p>Votre rendez-vous a été confirmé :</p>" +
            "<table style='width: 100%;'>" +
            "<tr><td><strong>👨‍⚕️ Médecin</strong></td><td>Dr. " + rdv.getMedecin().getNommed() + "</td></tr>" +
            "<tr><td><strong>🔬 Spécialité</strong></td><td>" + rdv.getMedecin().getSpecialite() + "</td></tr>" +
            "<tr><td><strong>📅 Date</strong></td><td>" + rdv.getDateFormatee() + "</td></tr>" +
            "<tr><td><strong>📍 Lieu</strong></td><td>" + rdv.getMedecin().getLieu() + "</td></tr>" +
            "</table>" +
            "<p>Merci de vous présenter 10 minutes avant.</p>" +
            "<hr>" +
            "<p style='font-size: 12px; color: #999;'>RDV Medical</p>" +
            "</div>" +
            "</body>" +
            "</html>";
        
        envoyerViaMailjetAPI(patientEmail, "✅ Confirmation RDV Medical", htmlContent);
    }

    public void envoyerAnnulation(Rdv rdv) {
        if (!isConfigured || rdv == null || rdv.getPatient() == null) return;
        
        String patientEmail = rdv.getPatient().getEmail();
        if (patientEmail == null) return;
        
        System.out.println("[MailService] Sending cancellation to: " + patientEmail);
        
        String htmlContent = "<!DOCTYPE html>" +
            "<html>" +
            "<body style='font-family: Arial, sans-serif;'>" +
            "<div style='max-width: 500px; margin: 0 auto; padding: 20px; border: 1px solid #ddd; border-radius: 10px;'>" +
            "<h2 style='color: #ea4335;'>❌ Annulation de rendez-vous</h2>" +
            "<p>Bonjour <strong>" + rdv.getPatient().getNomPat() + "</strong>,</p>" +
            "<p>Votre rendez-vous du " + rdv.getDateFormatee() + " a été annulé.</p>" +
            "<p>Vous pouvez prendre un nouveau rendez-vous.</p>" +
            "<hr>" +
            "<p style='font-size: 12px; color: #999;'>RDV Medical</p>" +
            "</div>" +
            "</body>" +
            "</html>";
        
        envoyerViaMailjetAPI(patientEmail, "❌ Annulation RDV Medical", htmlContent);
    }
    
    private void envoyerViaMailjetAPI(String toEmail, String subject, String htmlContent) {
        try {
            // Construire la requête JSON pour Mailjet API v3.1
            String jsonPayload = String.format("""
                {
                    "Messages": [
                        {
                            "From": {
                                "Email": "noreply@rdv-medical.com",
                                "Name": "RDV Medical"
                            },
                            "To": [
                                {
                                    "Email": "%s",
                                    "Name": "Patient"
                                }
                            ],
                            "Subject": "%s",
                            "HTMLPart": "%s"
                        }
                    ]
                }
                """, 
                escapeJson(toEmail), 
                escapeJson(subject), 
                escapeJson(htmlContent)
            );
            
            // Créer la connexion HTTP
            URL url = new URL("https://api.mailjet.com/v3.1/send");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json");
            
            // Authentification Basic avec API Key + Secret Key
            String auth = apiKey + ":" + secretKey;
            String encodedAuth = Base64.getEncoder().encodeToString(auth.getBytes(StandardCharsets.UTF_8));
            conn.setRequestProperty("Authorization", "Basic " + encodedAuth);
            
            conn.setDoOutput(true);
            
            // Envoyer la requête
            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = jsonPayload.getBytes(StandardCharsets.UTF_8);
                os.write(input, 0, input.length);
            }
            
            // Lire la réponse
            int responseCode = conn.getResponseCode();
            if (responseCode == 200 || responseCode == 201) {
                System.out.println("[MailService] ✅ Email sent successfully to " + toEmail);
                System.out.println("[MailService] Response code: " + responseCode);
            } else {
                System.err.println("[MailService] ❌ Failed to send email. Response code: " + responseCode);
            }
            
            conn.disconnect();
            
        } catch (Exception e) {
            System.err.println("[MailService] ❌ Exception: " + e.getMessage());
            e.printStackTrace();
        }
    }
    
    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\n", "\\n")
                .replace("\r", "\\r");
    }
}