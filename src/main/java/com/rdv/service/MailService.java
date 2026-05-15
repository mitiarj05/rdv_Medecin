package com.rdv.service;

import com.mailjet.client.ClientOptions;
import com.mailjet.client.MailjetClient;
import com.mailjet.client.MailjetRequest;
import com.mailjet.client.MailjetResponse;
import com.mailjet.client.errors.MailjetException;
import com.mailjet.client.resource.Emailv31;
import com.rdv.model.Rdv;

import org.json.JSONArray;
import org.json.JSONObject;

public class MailService {

    private MailjetClient client;
    private boolean isConfigured = false;

    public MailService() {
        String apiKey = System.getenv("MAILJET_API_KEY");
        String secretKey = System.getenv("MAILJET_SECRET_KEY");
        
        if (apiKey != null && !apiKey.isEmpty() && secretKey != null && !secretKey.isEmpty()) {
            ClientOptions options = ClientOptions.builder()
                .apiKey(apiKey)
                .apiSecretKey(secretKey)
                .build();
            client = new MailjetClient(options);
            isConfigured = true;
            System.out.println("[MailService] ✅ Mailjet initialisé avec succès");
            System.out.println("[MailService] API Key: " + apiKey.substring(0, 10) + "...");
        } else {
            System.err.println("[MailService] ❌ MAILJET_API_KEY ou MAILJET_SECRET_KEY non trouvées");
        }
    }

    public void envoyerConfirmation(Rdv rdv) {
        if (rdv == null || rdv.getPatient() == null || rdv.getMedecin() == null) {
            System.err.println("[MailService] ❌ Données RDV manquantes");
            return;
        }
        
        if (!isConfigured) {
            System.err.println("[MailService] ❌ Mailjet non configuré");
            return;
        }
        
        String patientEmail = rdv.getPatient().getEmail();
        if (patientEmail == null || patientEmail.isEmpty()) {
            System.err.println("[MailService] ❌ Email patient manquant");
            return;
        }
        
        System.out.println("[MailService] =========================================");
        System.out.println("[MailService] 📧 Envoi confirmation à: " + patientEmail);
        System.out.println("[MailService] Patient: " + rdv.getPatient().getNomPat());
        System.out.println("[MailService] Médecin: Dr. " + rdv.getMedecin().getNommed());
        System.out.println("[MailService] Date: " + rdv.getDateFormatee());
        System.out.println("[MailService] =========================================");
        
        String sujet = "✅ Confirmation de votre rendez-vous médical - RDV Medical";
        
        String contenuHtml = String.format(
            "<!DOCTYPE html>" +
            "<html>" +
            "<head><meta charset='UTF-8'></head>" +
            "<body style='font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px;'>" +
            "<div style='max-width: 500px; margin: 0 auto; background: white; border-radius: 10px; padding: 20px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);'>" +
            "<div style='text-align: center; border-bottom: 2px solid #1a73e8; padding-bottom: 15px; margin-bottom: 20px;'>" +
            "<h2 style='color: #1a73e8; margin: 0;'>🏥 RDV Medical</h2>" +
            "<p style='color: #666; margin: 5px 0 0;'>Plateforme de rendez-vous médicaux</p>" +
            "</div>" +
            "<h3 style='color: #34a853;'>✓ Confirmation de rendez-vous</h3>" +
            "<p>Bonjour <strong>%s</strong>,</p>" +
            "<p>Votre rendez-vous a été confirmé :</p>" +
            "<table style='width: 100%%; border-collapse: collapse; margin: 15px 0;'>" +
            "<tr style='background-color: #f5f5f5;'><td style='padding: 10px;'><strong>👨‍⚕️ Médecin</strong></td><td style='padding: 10px;'>Dr. %s</td></tr>" +
            "<tr><td style='padding: 10px;'><strong>🔬 Spécialité</strong></td><td style='padding: 10px;'>%s</td></tr>" +
            "<tr style='background-color: #f5f5f5;'><td style='padding: 10px;'><strong>📅 Date et heure</strong></td><td style='padding: 10px;'>%s</td></tr>" +
            "<tr><td style='padding: 10px;'><strong>📍 Lieu</strong></td><td style='padding: 10px;'>%s</td></tr>" +
            "<tr style='background-color: #f5f5f5;'><td style='padding: 10px;'><strong>💰 Tarif</strong></td><td style='padding: 10px;'>%d Ar/h</td></tr>" +
            "</table>" +
            "<div style='background-color: #e8f0fe; padding: 12px; border-radius: 8px; margin: 15px 0;'>" +
            "<p style='margin: 0; font-size: 14px;'><strong>ℹ️ Information :</strong> Merci de vous présenter 10 minutes avant l'heure du rendez-vous.</p>" +
            "</div>" +
            "<hr style='margin: 20px 0; border-color: #eee;'>" +
            "<p style='font-size: 12px; color: #999; text-align: center;'>RDV Medical - Plateforme de rendez-vous médicaux<br>Cet email est automatique, merci de ne pas répondre.</p>" +
            "</div>" +
            "</body>" +
            "</html>",
            rdv.getPatient().getNomPat(),
            rdv.getMedecin().getNommed(),
            rdv.getMedecin().getSpecialite(),
            rdv.getDateFormatee(),
            rdv.getMedecin().getLieu(),
            rdv.getMedecin().getTauxHoraire()
        );
        
        envoyerAvecMailjet(patientEmail, sujet, contenuHtml);
    }

    public void envoyerAnnulation(Rdv rdv) {
        if (rdv == null || rdv.getPatient() == null) return;
        if (!isConfigured) return;
        
        String patientEmail = rdv.getPatient().getEmail();
        System.out.println("[MailService] 📧 Envoi annulation à: " + patientEmail);
        
        String sujet = "❌ Annulation de votre rendez-vous médical - RDV Medical";
        String contenuHtml = String.format(
            "<!DOCTYPE html>" +
            "<html>" +
            "<body style='font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px;'>" +
            "<div style='max-width: 500px; margin: 0 auto; background: white; border-radius: 10px; padding: 20px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);'>" +
            "<div style='text-align: center; border-bottom: 2px solid #ea4335; padding-bottom: 15px; margin-bottom: 20px;'>" +
            "<h2 style='color: #ea4335; margin: 0;'>🏥 RDV Medical</h2>" +
            "<p style='color: #666; margin: 5px 0 0;'>Plateforme de rendez-vous médicaux</p>" +
            "</div>" +
            "<h3 style='color: #ea4335;'>❌ Annulation de rendez-vous</h3>" +
            "<p>Bonjour <strong>%s</strong>,</p>" +
            "<p>Votre rendez-vous avec le Dr. %s du %s a été annulé.</p>" +
            "<div style='background-color: #e8f0fe; padding: 12px; border-radius: 8px; margin: 15px 0;'>" +
            "<p style='margin: 0;'><strong>ℹ️</strong> Vous pouvez prendre un nouveau rendez-vous sur notre plateforme.</p>" +
            "</div>" +
            "<hr>" +
            "<p style='font-size: 12px; color: #999; text-align: center;'>RDV Medical</p>" +
            "</div>" +
            "</body>" +
            "</html>",
            rdv.getPatient().getNomPat(),
            rdv.getMedecin().getNommed(),
            rdv.getDateFormatee()
        );
        
        envoyerAvecMailjet(patientEmail, sujet, contenuHtml);
    }
    
    private void envoyerAvecMailjet(String destinataire, String sujet, String contenuHtml) {
        try {
            MailjetRequest request = new MailjetRequest(Emailv31.resource)
                .property(Emailv31.MESSAGES, new JSONArray()
                    .put(new JSONObject()
                        .put(Emailv31.Message.FROM, new JSONObject()
                            .put("Email", "noreply@rdv-medical.com")
                            .put("Name", "RDV Medical"))
                        .put(Emailv31.Message.TO, new JSONArray()
                            .put(new JSONObject()
                                .put("Email", destinataire)
                                .put("Name", destinataire.split("@")[0])))
                        .put(Emailv31.Message.SUBJECT, sujet)
                        .put(Emailv31.Message.HTMLPART, contenuHtml)
                        .put(Emailv31.Message.CUSTOMID, "RDVMedical")));
            
            MailjetResponse response = client.post(request);
            
            if (response.getStatus() == 200 || response.getStatus() == 201) {
                System.out.println("[MailService] ✅ Email envoyé avec succès à " + destinataire);
            } else {
                System.err.println("[MailService] ❌ Erreur Mailjet - Status: " + response.getStatus());
                System.err.println("[MailService] Réponse: " + response.getData());
            }
        } catch (MailjetException e) {
            System.err.println("[MailService] ❌ Exception Mailjet: " + e.getMessage());
            e.printStackTrace();
        }
    }
}