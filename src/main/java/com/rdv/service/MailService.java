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
    private String fromEmail;

    public MailService() {
        String apiKey = System.getenv("SENDGRID_API_KEY");
        fromEmail = "noreply@rdv-medical.com";
        
        if (apiKey != null && !apiKey.isEmpty()) {
            sendGrid = new SendGrid(apiKey);
            System.out.println("[MailService] ✅ SendGrid initialisé avec succès");
        } else {
            System.err.println("[MailService] ❌ SENDGRID_API_KEY non définie");
        }
    }

    public void envoyerConfirmation(Rdv rdv) {
        if (rdv == null || rdv.getPatient() == null || rdv.getMedecin() == null) {
            System.err.println("[MailService] ❌ Données manquantes");
            return;
        }
        
        if (sendGrid == null) {
            System.err.println("[MailService] ❌ SendGrid non initialisé");
            return;
        }
        
        String patientEmail = rdv.getPatient().getEmail();
        System.out.println("[MailService] Envoi confirmation à: " + patientEmail);
        
        String sujet = "✅ Confirmation de votre rendez-vous médical";
        String contenu = String.format(
            "<!DOCTYPE html>" +
            "<html>" +
            "<head><meta charset='UTF-8'></head>" +
            "<body style='font-family: Arial, sans-serif;'>" +
            "<div style='max-width: 500px; margin: 0 auto; padding: 20px; border: 1px solid #ddd; border-radius: 10px;'>" +
            "<h2 style='color: #1a73e8;'>🏥 RDV Medical</h2>" +
            "<h3 style='color: #34a853;'>Confirmation de rendez-vous ✓</h3>" +
            "<p>Bonjour <strong>%s</strong>,</p>" +
            "<p>Votre rendez-vous a été confirmé :</p>" +
            "<table style='width: 100%%;'>" +
            "<tr><td style='padding: 5px;'><strong>👨‍⚕️ Médecin :</strong></td><td>Dr. %s</td></tr>" +
            "<tr><td style='padding: 5px;'><strong>🔬 Spécialité :</strong></td><td>%s</td></tr>" +
            "<tr><td style='padding: 5px;'><strong>📅 Date :</strong></td><td>%s</td></tr>" +
            "<tr><td style='padding: 5px;'><strong>📍 Lieu :</strong></td><td>%s</td></tr>" +
            "</table>" +
            "<p style='margin-top: 20px;'>Merci de vous présenter 10 minutes avant l'heure du rendez-vous.</p>" +
            "<hr>" +
            "<p style='font-size: 12px; color: #999;'>RDV Medical - Plateforme de rendez-vous médicaux</p>" +
            "</div>" +
            "</body>" +
            "</html>",
            rdv.getPatient().getNomPat(),
            rdv.getMedecin().getNommed(),
            rdv.getMedecin().getSpecialite(),
            rdv.getDateFormatee(),
            rdv.getMedecin().getLieu()
        );
        
        envoyerEmail(patientEmail, sujet, contenu);
    }
    
    private void envoyerEmail(String destinataire, String sujet, String contenuHtml) {
        try {
            Email from = new Email(fromEmail);
            Email to = new Email(destinataire);
            Content content = new Content("text/html", contenuHtml);
            Mail mail = new Mail(from, sujet, to, content);
            
            Request request = new Request();
            request.setMethod(Method.POST);
            request.setEndpoint("mail/send");
            request.setBody(mail.build());
            
            Response response = sendGrid.api(request);
            
            if (response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
                System.out.println("[MailService] ✅ Email envoyé à " + destinataire);
            } else {
                System.err.println("[MailService] ❌ Erreur " + response.getStatusCode() + " pour " + destinataire);
            }
        } catch (Exception e) {
            System.err.println("[MailService] ❌ Exception: " + e.getMessage());
            e.printStackTrace();
        }
    }

    public void envoyerAnnulation(Rdv rdv) {
        if (rdv == null || rdv.getPatient() == null) return;
        
        String sujet = "❌ Annulation de votre rendez-vous médical";
        String contenu = String.format(
            "<h2>Annulation de rendez-vous</h2>" +
            "<p>Bonjour %s,</p>" +
            "<p>Votre rendez-vous avec le Dr. %s du %s a été annulé.</p>" +
            "<p>Vous pouvez prendre un nouveau rendez-vous sur notre plateforme.</p>",
            rdv.getPatient().getNomPat(),
            rdv.getMedecin().getNommed(),
            rdv.getDateFormatee()
        );
        
        envoyerEmail(rdv.getPatient().getEmail(), sujet, contenu);
    }
}