package com.rdv.service;

import com.rdv.model.Rdv;
import com.sendgrid.Method;
import com.sendgrid.Request;
import com.sendgrid.Response;
import com.sendgrid.SendGrid;
import com.sendgrid.helpers.mail.Mail;
import com.sendgrid.helpers.mail.objects.Content;
import com.sendgrid.helpers.mail.objects.Email;

public class MailService {

    private SendGrid sendGrid;

    public MailService() {
        String apiKey = System.getenv("SENDGRID_API_KEY");
        
        if (apiKey != null && !apiKey.isEmpty()) {
            sendGrid = new SendGrid(apiKey);
            System.out.println("[MailService] ✅ SendGrid initialisé avec succès");
        } else {
            System.err.println("[MailService] ❌ SENDGRID_API_KEY non trouvée");
        }
    }

    public void envoyerConfirmation(Rdv rdv) {
        // Vérifications
        if (rdv == null) {
            System.err.println("[MailService] ❌ RDV est null");
            return;
        }
        if (rdv.getPatient() == null) {
            System.err.println("[MailService] ❌ Patient est null");
            return;
        }
        if (rdv.getMedecin() == null) {
            System.err.println("[MailService] ❌ Médecin est null");
            return;
        }
        if (sendGrid == null) {
            System.err.println("[MailService] ❌ SendGrid non initialisé");
            return;
        }
        
        String patientEmail = rdv.getPatient().getEmail();
        if (patientEmail == null || patientEmail.isEmpty()) {
            System.err.println("[MailService] ❌ Email patient manquant");
            return;
        }
        
        System.out.println("[MailService] 📧 Envoi confirmation à: " + patientEmail);
        
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
            "<p>Votre rendez-vous a été confirmé avec les informations suivantes :</p>" +
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
            "<p style='font-size: 12px; color: #999; text-align: center;'>RDV Medical - Plateforme de rendez-vous médicaux<br>Cet email est un message automatique, merci de ne pas y répondre.</p>" +
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
        
        try {
            Email from = new Email("noreply@rdv-medical.com");
            Email to = new Email(patientEmail);
            Content content = new Content("text/html", contenuHtml);
            Mail mail = new Mail(from, sujet, to, content);
            
            Request request = new Request();
            request.setMethod(Method.POST);
            request.setEndpoint("mail/send");
            request.setBody(mail.build());
            
            Response response = sendGrid.api(request);
            
            if (response.getStatusCode() == 202) {
                System.out.println("[MailService] ✅ Email envoyé avec succès à " + patientEmail);
            } else {
                System.err.println("[MailService] ❌ Erreur SendGrid - Status: " + response.getStatusCode());
                System.err.println("[MailService] Réponse: " + response.getBody());
            }
        } catch (Exception e) {
            System.err.println("[MailService] ❌ Exception: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public void envoyerAnnulation(Rdv rdv) {
        if (rdv == null || rdv.getPatient() == null || sendGrid == null) return;
        
        String patientEmail = rdv.getPatient().getEmail();
        System.out.println("[MailService] 📧 Envoi annulation à: " + patientEmail);
        
        String sujet = "❌ Annulation de votre rendez-vous médical - RDV Medical";
        
        String contenuHtml = String.format(
            "<!DOCTYPE html>" +
            "<html>" +
            "<head><meta charset='UTF-8'></head>" +
            "<body style='font-family: Arial, sans-serif; background-color: #f4f4f4; padding: 20px;'>" +
            "<div style='max-width: 500px; margin: 0 auto; background: white; border-radius: 10px; padding: 20px; box-shadow: 0 2px 10px rgba(0,0,0,0.1);'>" +
            "<div style='text-align: center; border-bottom: 2px solid #ea4335; padding-bottom: 15px; margin-bottom: 20px;'>" +
            "<h2 style='color: #ea4335; margin: 0;'>🏥 RDV Medical</h2>" +
            "<p style='color: #666; margin: 5px 0 0;'>Plateforme de rendez-vous médicaux</p>" +
            "</div>" +
            "<h3 style='color: #ea4335;'>❌ Annulation de rendez-vous</h3>" +
            "<p>Bonjour <strong>%s</strong>,</p>" +
            "<p>Nous vous informons que votre rendez-vous a été annulé.</p>" +
            "<table style='width: 100%%; border-collapse: collapse; margin: 15px 0; background-color: #fce8e6; border-radius: 8px;'>" +
            "<tr><td style='padding: 10px;'><strong>👨‍⚕️ Médecin</strong></td><td style='padding: 10px;'>Dr. %s</td></tr>" +
            "<tr><td style='padding: 10px;'><strong>📅 Date</strong></td><td style='padding: 10px;'>%s</td></tr>" +
            "</table>" +
            "<div style='background-color: #e8f0fe; padding: 12px; border-radius: 8px; margin: 15px 0;'>" +
            "<p style='margin: 0; font-size: 14px;'><strong>ℹ️ Information :</strong> Vous pouvez prendre un nouveau rendez-vous sur notre plateforme.</p>" +
            "</div>" +
            "<hr style='margin: 20px 0; border-color: #eee;'>" +
            "<p style='font-size: 12px; color: #999; text-align: center;'>RDV Medical - Plateforme de rendez-vous médicaux</p>" +
            "</div>" +
            "</body>" +
            "</html>",
            rdv.getPatient().getNomPat(),
            rdv.getMedecin().getNommed(),
            rdv.getDateFormatee()
        );
        
        try {
            Email from = new Email("noreply@rdv-medical.com");
            Email to = new Email(patientEmail);
            Content content = new Content("text/html", contenuHtml);
            Mail mail = new Mail(from, sujet, to, content);
            
            Request request = new Request();
            request.setMethod(Method.POST);
            request.setEndpoint("mail/send");
            request.setBody(mail.build());
            
            Response response = sendGrid.api(request);
            
            if (response.getStatusCode() == 202) {
                System.out.println("[MailService] ✅ Annulation envoyée à " + patientEmail);
            } else {
                System.err.println("[MailService] ❌ Erreur annulation: " + response.getStatusCode());
            }
        } catch (Exception e) {
            System.err.println("[MailService] ❌ Exception annulation: " + e.getMessage());
        }
    }
}