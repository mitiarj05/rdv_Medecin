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
        apiKey = System.getenv("MAILJET_API_KEY");
        secretKey = System.getenv("MAILJET_SECRET_KEY");
        
        System.out.println("[MailService] ========== INITIALISATION MAILJET ==========");
        System.out.println("[MailService] MAILJET_API_KEY: " + (apiKey != null ? "✅ TROUVEE" : "❌ ABSENTE"));
        System.out.println("[MailService] MAILJET_SECRET_KEY: " + (secretKey != null ? "✅ TROUVEE" : "❌ ABSENTE"));
        
        if (apiKey != null && !apiKey.isEmpty() && secretKey != null && !secretKey.isEmpty()) {
            isConfigured = true;
            System.out.println("[MailService] ✅ Mailjet initialisé avec succès !");
        } else {
            System.err.println("[MailService] ❌ Mailjet non configuré");
        }
    }

    public void envoyerConfirmation(Rdv rdv) {
        if (!isConfigured || rdv == null || rdv.getPatient() == null || rdv.getMedecin() == null) {
            System.err.println("[MailService] Configuration invalide");
            return;
        }
        
        String patientEmail = rdv.getPatient().getEmail();
        if (patientEmail == null || patientEmail.isEmpty()) return;
        
        System.out.println("[MailService] 📧 Envoi confirmation à: " + patientEmail);
        
        String sujet = "✅ Confirmation de votre rendez-vous médical";
        String contenuHtml = String.format(
            "<html><body>" +
            "<h2 style='color:#1a73e8;'>🏥 RDV Medical</h2>" +
            "<h3>✓ Confirmation de rendez-vous</h3>" +
            "<p>Bonjour <strong>%s</strong>,</p>" +
            "<p>Votre rendez-vous a été confirmé :</p>" +
            "<ul>" +
            "<li><strong>Médecin :</strong> Dr. %s</li>" +
            "<li><strong>Spécialité :</strong> %s</li>" +
            "<li><strong>Date :</strong> %s</li>" +
            "<li><strong>Lieu :</strong> %s</li>" +
            "</ul>" +
            "<p>Merci de vous présenter 10 minutes avant.</p>" +
            "<hr><p style='font-size:12px;color:#999;'>RDV Medical</p>" +
            "</body></html>",
            rdv.getPatient().getNomPat(),
            rdv.getMedecin().getNommed(),
            rdv.getMedecin().getSpecialite(),
            rdv.getDateFormatee(),
            rdv.getMedecin().getLieu()
        );
        
        envoyerViaMailjetAPI(patientEmail, sujet, contenuHtml);
    }

    public void envoyerAnnulation(Rdv rdv) {
        if (!isConfigured || rdv == null || rdv.getPatient() == null) return;
        
        String patientEmail = rdv.getPatient().getEmail();
        if (patientEmail == null || patientEmail.isEmpty()) return;
        
        System.out.println("[MailService] 📧 Envoi annulation à: " + patientEmail);
        
        String sujet = "❌ Annulation de votre rendez-vous médical";
        String contenuHtml = String.format(
            "<html><body>" +
            "<h2 style='color:#ea4335;'>❌ Annulation de rendez-vous</h2>" +
            "<p>Bonjour <strong>%s</strong>,</p>" +
            "<p>Votre rendez-vous du %s a été annulé.</p>" +
            "<p>Vous pouvez prendre un nouveau rendez-vous.</p>" +
            "<hr><p style='font-size:12px;color:#999;'>RDV Medical</p>" +
            "</body></html>",
            rdv.getPatient().getNomPat(),
            rdv.getDateFormatee()
        );
        
        envoyerViaMailjetAPI(patientEmail, sujet, contenuHtml);
    }
    
    private void envoyerViaMailjetAPI(String destinataire, String sujet, String contenuHtml) {
        try {
            // UTILISE TON EMAIL VALIDÉ
            String jsonPayload = "{"
                + "\"Messages\": ["
                + "{"
                + "\"From\": {\"Email\": \"mitiarj05@gmail.com\", \"Name\": \"RDV Medical\"},"
                + "\"To\": [{\"Email\": \"" + destinataire + "\", \"Name\": \"Patient\"}],"
                + "\"Subject\": \"" + sujet.replace("\"", "\\\"") + "\","
                + "\"HTMLPart\": \"" + contenuHtml.replace("\"", "\\\"").replace("\n", "").replace("\r", "") + "\""
                + "}"
                + "]"
                + "}";
            
            URL url = new URL("https://api.mailjet.com/v3.1/send");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("Content-Type", "application/json");
            
            String auth = apiKey + ":" + secretKey;
            String encodedAuth = Base64.getEncoder().encodeToString(auth.getBytes(StandardCharsets.UTF_8));
            conn.setRequestProperty("Authorization", "Basic " + encodedAuth);
            conn.setDoOutput(true);
            
            try (OutputStream os = conn.getOutputStream()) {
                os.write(jsonPayload.getBytes(StandardCharsets.UTF_8));
            }
            
            int responseCode = conn.getResponseCode();
            if (responseCode == 200 || responseCode == 201) {
                System.out.println("[MailService] ✅ Email envoyé à " + destinataire);
            } else {
                System.err.println("[MailService] ❌ Erreur " + responseCode + " pour " + destinataire);
            }
            conn.disconnect();
        } catch (Exception e) {
            System.err.println("[MailService] ❌ Exception: " + e.getMessage());
        }
    }
}