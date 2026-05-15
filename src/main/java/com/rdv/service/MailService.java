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
    private final String FROM_EMAIL = "mitiarj05@gmail.com";
    private final String FROM_NAME = "RDV Medical";

    public MailService() {
        apiKey = System.getenv("MAILJET_API_KEY");
        secretKey = System.getenv("MAILJET_SECRET_KEY");
        
        System.out.println("[MailService] ========== INITIALISATION MAILJET ==========");
        System.out.println("[MailService] MAILJET_API_KEY: " + (apiKey != null ? "✅ TROUVEE" : "❌ ABSENTE"));
        System.out.println("[MailService] MAILJET_SECRET_KEY: " + (secretKey != null ? "✅ TROUVEE" : "❌ ABSENTE"));
        System.out.println("[MailService] Email expéditeur: " + FROM_EMAIL);
        
        if (apiKey != null && !apiKey.isEmpty() && secretKey != null && !secretKey.isEmpty()) {
            isConfigured = true;
            System.out.println("[MailService] ✅ Mailjet initialisé avec succès !");
        } else {
            System.err.println("[MailService] ❌ Mailjet non configuré");
        }
    }

    public void envoyerConfirmation(Rdv rdv) {
        if (!isConfigured) {
            System.err.println("[MailService] ❌ Mailjet non configuré");
            return;
        }
        if (rdv == null || rdv.getPatient() == null || rdv.getMedecin() == null) {
            System.err.println("[MailService] ❌ RDV invalide");
            return;
        }
        
        String patientEmail = rdv.getPatient().getEmail();
        String medecinEmail = rdv.getMedecin().getEmail();
        
        System.out.println("[MailService] 📧 Envoi confirmation à patient: " + patientEmail);
        System.out.println("[MailService] 📧 Envoi confirmation à médecin: " + medecinEmail);
        
        // Email au PATIENT
        String sujetPatient = "✅ Confirmation de votre rendez-vous médical";
        String contenuPatient = String.format(
            "<!DOCTYPE html><html><head><meta charset='UTF-8'></head>" +
            "<body style='font-family: Arial, sans-serif;'>" +
            "<div style='max-width: 500px; margin: 0 auto; padding: 20px; border: 1px solid #ddd; border-radius: 10px;'>" +
            "<h2 style='color: #1a73e8;'>🏥 RDV Medical</h2>" +
            "<h3 style='color: #34a853;'>✓ Confirmation de rendez-vous</h3>" +
            "<p>Bonjour <strong>%s</strong>,</p>" +
            "<p>Votre rendez-vous a été confirmé :</p>" +
            "<ul>" +
            "<li><strong>👨‍⚕️ Médecin :</strong> Dr. %s</li>" +
            "<li><strong>🔬 Spécialité :</strong> %s</li>" +
            "<li><strong>📅 Date :</strong> %s</li>" +
            "<li><strong>📍 Lieu :</strong> %s</li>" +
            "</ul>" +
            "<p>Merci de vous présenter 10 minutes avant.</p>" +
            "<hr><p style='font-size: 12px; color: #999;'>RDV Medical</p>" +
            "</div></body></html>",
            rdv.getPatient().getNomPat(),
            rdv.getMedecin().getNommed(),
            rdv.getMedecin().getSpecialite(),
            rdv.getDateFormatee(),
            rdv.getMedecin().getLieu()
        );
        
        envoyerViaMailjetAPI(patientEmail, sujetPatient, contenuPatient);
        
        // Email au MEDECIN
        if (medecinEmail != null && !medecinEmail.isEmpty()) {
            String sujetMedecin = "📅 Nouveau rendez-vous - " + rdv.getPatient().getNomPat();
            String contenuMedecin = String.format(
                "<!DOCTYPE html><html><head><meta charset='UTF-8'></head>" +
                "<body style='font-family: Arial, sans-serif;'>" +
                "<div style='max-width: 500px; margin: 0 auto; padding: 20px; border: 1px solid #ddd; border-radius: 10px;'>" +
                "<h2 style='color: #1a73e8;'>🏥 RDV Medical</h2>" +
                "<h3 style='color: #fbbc04;'>📅 Nouveau rendez-vous</h3>" +
                "<p>Bonjour Dr. <strong>%s</strong>,</p>" +
                "<p>Un nouveau rendez-vous a été pris :</p>" +
                "<ul>" +
                "<li><strong>👤 Patient :</strong> %s</li>" +
                "<li><strong>📧 Email :</strong> %s</li>" +
                "<li><strong>📅 Date :</strong> %s</li>" +
                "</ul>" +
                "<p>Cordialement,<br>RDV Medical</p>" +
                "</div></body></html>",
                rdv.getMedecin().getNommed(),
                rdv.getPatient().getNomPat(),
                rdv.getPatient().getEmail(),
                rdv.getDateFormatee()
            );
            envoyerViaMailjetAPI(medecinEmail, sujetMedecin, contenuMedecin);
        }
    }

    public void envoyerAnnulation(Rdv rdv) {
        if (!isConfigured || rdv == null || rdv.getPatient() == null) return;
        
        String patientEmail = rdv.getPatient().getEmail();
        if (patientEmail == null || patientEmail.isEmpty()) return;
        
        System.out.println("[MailService] 📧 Envoi annulation à: " + patientEmail);
        
        String sujet = "❌ Annulation de votre rendez-vous médical";
        String contenu = String.format(
            "<html><body>" +
            "<h2 style='color:#ea4335;'>❌ Annulation de rendez-vous</h2>" +
            "<p>Bonjour <strong>%s</strong>,</p>" +
            "<p>Votre rendez-vous avec le Dr. %s du %s a été annulé.</p>" +
            "<p>Vous pouvez prendre un nouveau rendez-vous.</p>" +
            "<hr><p>RDV Medical</p></body></html>",
            rdv.getPatient().getNomPat(),
            rdv.getMedecin().getNommed(),
            rdv.getDateFormatee()
        );
        
        envoyerViaMailjetAPI(patientEmail, sujet, contenu);
    }
    
    private void envoyerViaMailjetAPI(String destinataire, String sujet, String contenuHtml) {
        try {
            // Utilisation de l'email validé comme expéditeur UNIQUE
            String jsonPayload = "{"
                + "\"Messages\": ["
                + "{"
                + "\"From\": {\"Email\": \"" + FROM_EMAIL + "\", \"Name\": \"" + FROM_NAME + "\"},"
                + "\"To\": [{\"Email\": \"" + destinataire + "\", \"Name\": \"\"}],"
                + "\"Subject\": \"" + sujet.replace("\"", "\\\"").replace("\n", " ").replace("\r", " ") + "\","
                + "\"HTMLPart\": \"" + contenuHtml.replace("\"", "\\\"").replace("\n", " ").replace("\r", " ") + "\""
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