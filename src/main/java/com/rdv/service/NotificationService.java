package com.rdv.service;

import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

import com.rdv.model.Rdv;

public class NotificationService {

    private static final String TWILIO_ACCOUNT_SID = System.getenv("TWILIO_ACCOUNT_SID");
    private static final String TWILIO_AUTH_TOKEN = System.getenv("TWILIO_AUTH_TOKEN");
    private static final String TWILIO_WHATSAPP_FROM = System.getenv("TWILIO_WHATSAPP_FROM");
    private static final String TWILIO_SMS_FROM = System.getenv("TWILIO_SMS_FROM");
    
    private boolean isConfigured = false;

    public NotificationService() {
        if (TWILIO_ACCOUNT_SID != null && !TWILIO_ACCOUNT_SID.isEmpty() &&
            TWILIO_AUTH_TOKEN != null && !TWILIO_AUTH_TOKEN.isEmpty()) {
            isConfigured = true;
            System.out.println("[NotificationService] ✅ Twilio configuré");
            System.out.println("[NotificationService] SMS From: " + (TWILIO_SMS_FROM != null ? "✅" : "❌"));
            System.out.println("[NotificationService] WhatsApp From: " + (TWILIO_WHATSAPP_FROM != null ? "✅" : "❌"));
        } else {
            System.out.println("[NotificationService] ⚠️ Twilio non configuré - SMS/WhatsApp désactivés");
        }
    }

    /**
     * Envoie une notification WhatsApp
     */
    public void envoyerWhatsApp(String toNumber, String message) {
        if (!isConfigured) {
            System.out.println("[NotificationService] WhatsApp non configuré");
            return;
        }
        if (TWILIO_WHATSAPP_FROM == null) {
            System.out.println("[NotificationService] WhatsApp From non configuré");
            return;
        }
        if (toNumber == null || toNumber.isEmpty()) {
            System.out.println("[NotificationService] Numéro WhatsApp destinataire vide");
            return;
        }
        // Formater le numéro pour WhatsApp (ajouter le préfixe if missing)
        String formattedTo = toNumber;
        if (!formattedTo.startsWith("whatsapp:")) {
            // S'assurer que le numéro a le code pays
            if (!formattedTo.startsWith("+")) {
                // Ajouter +261 pour Madagascar par défaut
                formattedTo = "+261" + formattedTo;
            }
            formattedTo = "whatsapp:" + formattedTo;
        }
        String formattedFrom = "whatsapp:" + TWILIO_WHATSAPP_FROM;
        envoyerViaTwilio(formattedTo, formattedFrom, message);
    }

    /**
     * Envoie un SMS
     */
    public void envoyerSMS(String toNumber, String message) {
        if (!isConfigured) {
            System.out.println("[NotificationService] SMS non configuré");
            return;
        }
        if (TWILIO_SMS_FROM == null) {
            System.out.println("[NotificationService] SMS From non configuré");
            return;
        }
        if (toNumber == null || toNumber.isEmpty()) {
            System.out.println("[NotificationService] Numéro SMS destinataire vide");
            return;
        }
        // Formater le numéro
        String formattedTo = toNumber;
        if (!formattedTo.startsWith("+")) {
            formattedTo = "+261" + formattedTo;
        }
        envoyerViaTwilio(formattedTo, TWILIO_SMS_FROM, message);
    }

    /**
     * Notification pour un nouveau rendez-vous
     */
    public void notifierNouveauRendezVous(Rdv rdv) {
        if (rdv == null) return;
        
        System.out.println("[NotificationService] ========== NOTIFICATION NOUVEAU RDV ==========");
        
        // Message pour le patient
        if (rdv.getPatient() != null && rdv.getPatient().getTelephone() != null && !rdv.getPatient().getTelephone().isEmpty()) {
            String messagePatient = String.format(
                "🏥 RDV Medical - Confirmation\n\n" +
                "Bonjour %s,\n\n" +
                "Votre rendez-vous avec le Dr. %s est confirmé pour le %s.\n\n" +
                "Lieu: %s\n\n" +
                "Merci de vous présenter 10 minutes avant.\n\n" +
                "RDV Medical",
                rdv.getPatient().getNomPat(),
                rdv.getMedecin().getNommed(),
                rdv.getDateFormatee(),
                rdv.getMedecin().getLieu()
            );
            envoyerWhatsApp(rdv.getPatient().getTelephone(), messagePatient);
            envoyerSMS(rdv.getPatient().getTelephone(), messagePatient);
        }
        
        // Message pour le médecin
        if (rdv.getMedecin() != null && rdv.getMedecin().getTelephone() != null && !rdv.getMedecin().getTelephone().isEmpty()) {
            String messageMedecin = String.format(
                "🏥 RDV Medical - Nouveau rendez-vous\n\n" +
                "Bonjour Dr. %s,\n\n" +
                "Un nouveau rendez-vous a été pris :\n" +
                "Patient: %s\n" +
                "Date: %s\n\n" +
                "Email patient: %s\n\n" +
                "RDV Medical",
                rdv.getMedecin().getNommed(),
                rdv.getPatient().getNomPat(),
                rdv.getDateFormatee(),
                rdv.getPatient().getEmail()
            );
            envoyerWhatsApp(rdv.getMedecin().getTelephone(), messageMedecin);
            envoyerSMS(rdv.getMedecin().getTelephone(), messageMedecin);
        }
        
        System.out.println("[NotificationService] ============================================");
    }

    /**
     * Notification pour annulation de rendez-vous
     */
    public void notifierAnnulationRendezVous(Rdv rdv) {
        if (rdv == null) return;
        
        System.out.println("[NotificationService] ========== NOTIFICATION ANNULATION RDV ==========");
        
        // Message pour le patient
        if (rdv.getPatient() != null && rdv.getPatient().getTelephone() != null && !rdv.getPatient().getTelephone().isEmpty()) {
            String messagePatient = String.format(
                "🏥 RDV Medical - Annulation\n\n" +
                "Bonjour %s,\n\n" +
                "Votre rendez-vous avec le Dr. %s du %s a été annulé.\n\n" +
                "Vous pouvez prendre un nouveau rendez-vous sur notre plateforme.\n\n" +
                "RDV Medical",
                rdv.getPatient().getNomPat(),
                rdv.getMedecin().getNommed(),
                rdv.getDateFormatee()
            );
            envoyerWhatsApp(rdv.getPatient().getTelephone(), messagePatient);
            envoyerSMS(rdv.getPatient().getTelephone(), messagePatient);
        }
        
        // Message pour le médecin
        if (rdv.getMedecin() != null && rdv.getMedecin().getTelephone() != null && !rdv.getMedecin().getTelephone().isEmpty()) {
            String messageMedecin = String.format(
                "🏥 RDV Medical - Annulation\n\n" +
                "Bonjour Dr. %s,\n\n" +
                "Le rendez-vous avec %s (%s) du %s a été annulé.\n\n" +
                "RDV Medical",
                rdv.getMedecin().getNommed(),
                rdv.getPatient().getNomPat(),
                rdv.getPatient().getEmail(),
                rdv.getDateFormatee()
            );
            envoyerWhatsApp(rdv.getMedecin().getTelephone(), messageMedecin);
            envoyerSMS(rdv.getMedecin().getTelephone(), messageMedecin);
        }
        
        System.out.println("[NotificationService] ============================================");
    }

    private void envoyerViaTwilio(String to, String from, String message) {
        try {
            String urlStr = "https://api.twilio.com/2010-04-01/Accounts/" + TWILIO_ACCOUNT_SID + "/Messages.json";
            URL url = new URL(urlStr);
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            
            String auth = TWILIO_ACCOUNT_SID + ":" + TWILIO_AUTH_TOKEN;
            String encodedAuth = Base64.getEncoder().encodeToString(auth.getBytes(StandardCharsets.UTF_8));
            conn.setRequestProperty("Authorization", "Basic " + encodedAuth);
            conn.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
            conn.setDoOutput(true);
            
            String params = "To=" + java.net.URLEncoder.encode(to, "UTF-8") +
                           "&From=" + java.net.URLEncoder.encode(from, "UTF-8") +
                           "&Body=" + java.net.URLEncoder.encode(message, "UTF-8");
            
            try (OutputStream os = conn.getOutputStream()) {
                os.write(params.getBytes(StandardCharsets.UTF_8));
            }
            
            int responseCode = conn.getResponseCode();
            if (responseCode == 200 || responseCode == 201) {
                System.out.println("[NotificationService] ✅ Message envoyé à " + to);
            } else {
                System.err.println("[NotificationService] ❌ Erreur " + responseCode + " pour " + to);
            }
            conn.disconnect();
        } catch (Exception e) {
            System.err.println("[NotificationService] ❌ Exception: " + e.getMessage());
        }
    }
}