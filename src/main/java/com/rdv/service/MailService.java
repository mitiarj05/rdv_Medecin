package com.rdv.service;

import java.io.IOException;
import java.io.InputStream;
import java.util.Properties;

import com.rdv.model.Rdv;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

public class MailService {

    private Properties mailProps;
    private String     username;
    private String     password;
    private String     from;

    public MailService() {
        chargerConfig();
    }

    private void chargerConfig() {
        try {
            // 1. PRIORITÉ AUX VARIABLES D'ENVIRONNEMENT (Render)
            String envUsername = System.getenv("MAIL_USERNAME");
            String envPassword = System.getenv("MAIL_PASSWORD");

            // 2. SI PAS DE VARIABLES D'ENV, on lit mail.properties
            if (envUsername != null && envPassword != null && !envUsername.isEmpty() && !envPassword.isEmpty()) {
                System.out.println("[MailService] ✅ Utilisation des variables d'environnement");
                username = envUsername;
                password = envPassword;
                from = envUsername;

                // Paramètres SMTP par défaut pour Gmail
                mailProps = new Properties();
                mailProps.put("mail.smtp.host", "smtp.gmail.com");
                mailProps.put("mail.smtp.port", "587");
                mailProps.put("mail.smtp.auth", "true");
                mailProps.put("mail.smtp.starttls.enable", "true");
                mailProps.put("mail.smtp.ssl.protocols", "TLSv1.2");
                mailProps.put("mail.smtp.connectiontimeout", "5000");
                mailProps.put("mail.smtp.timeout", "5000");
                mailProps.put("mail.smtp.writetimeout", "5000");

            } else {
                System.out.println("[MailService] 📁 Variables d'environnement non trouvées, lecture de mail.properties...");

                Properties props = new Properties();
                InputStream input = getClass()
                        .getClassLoader()
                        .getResourceAsStream("mail.properties");

                if (input == null) {
                    System.err.println("[MailService] ❌ mail.properties introuvable ! Le service email ne fonctionnera pas.");
                    return;
                }
                props.load(input);

                username = props.getProperty("mail.username");
                password = props.getProperty("mail.password");
                from     = props.getProperty("mail.from");

                mailProps = new Properties();
                mailProps.put("mail.smtp.host",            props.getProperty("mail.host"));
                mailProps.put("mail.smtp.port",            props.getProperty("mail.port"));
                mailProps.put("mail.smtp.auth",            "true");
                mailProps.put("mail.smtp.starttls.enable", props.getProperty("mail.starttls"));
            }

            System.out.println("[MailService] ✅ Configuration mail chargée pour : " + username);

        } catch (IOException e) {
            System.err.println("[MailService] ❌ Erreur lecture configuration mail : " + e.getMessage());
            e.printStackTrace();
        }
    }

    private void envoyerEmail(String destinataire, String sujet, String contenu) {
        if (destinataire == null || destinataire.trim().isEmpty()) {
            System.err.println("[MailService] ❌ Erreur : destinataire vide ou null !");
            return;
        }

        if (username == null || password == null) {
            System.err.println("[MailService] ❌ Configuration mail non initialisée. Email non envoyé à " + destinataire);
            return;
        }

        Session session = Session.getInstance(mailProps, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username, password);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(from));
            message.setRecipients(Message.RecipientType.TO,
                    InternetAddress.parse(destinataire));
            message.setSubject(sujet);
            message.setContent(contenu, "text/html; charset=utf-8");

            Transport.send(message);
            System.out.println("[MailService] ✅ Email envoyé à : " + destinataire);

        } catch (MessagingException e) {
            System.err.println("[MailService] ❌ Erreur envoi email vers " + destinataire + " : " + e.getMessage());
        }
    }

    public void envoyerConfirmation(Rdv rdv) {
        // Vérification que rdv n'est pas null
        if (rdv == null) {
            System.err.println("[MailService] ❌ Erreur: rdv est null");
            return;
        }

        System.out.println("=== 📧 DEBUG MAIL CONFIRMATION ===");
        System.out.println("Patient nom: " + (rdv.getPatient() != null ? rdv.getPatient().getNomPat() : "null"));
        System.out.println("Patient email: " + (rdv.getPatient() != null ? rdv.getPatient().getEmail() : "null"));
        System.out.println("Medecin nom: " + (rdv.getMedecin() != null ? rdv.getMedecin().getNommed() : "null"));
        System.out.println("Medecin email: " + (rdv.getMedecin() != null ? rdv.getMedecin().getEmail() : "null"));
        System.out.println("=================================");

        String sujet = "Confirmation de votre rendez-vous médical";

        String contenu = "<html><body style='font-family: Arial, sans-serif;'>" +
                "<h2 style='color: #2E86AB;'>Confirmation de rendez-vous</h2>" +
                "<p>Bonjour <strong>" + rdv.getPatient().getNomPat() + "</strong>,</p>" +
                "<p>Votre rendez-vous a été confirmé avec les informations suivantes :</p>" +
                "<table style='border-collapse: collapse; width: 100%;'>" +
                "<tr><td style='padding: 8px; border: 1px solid #ddd;'><strong>Médecin</strong></td>" +
                "<td style='padding: 8px; border: 1px solid #ddd;'>Dr. " + rdv.getMedecin().getNommed() + "NonNullNode\n" +
                "<tr><td style='padding: 8px; border: 1px solid #ddd;'><strong>Spécialité</strong></td>" +
                "<td style='padding: 8px; border: 1px solid #ddd;'>" + rdv.getMedecin().getSpecialite() + "NonNullNode\n" +
                "<tr><td style='padding: 8px; border: 1px solid #ddd;'><strong>Date et heure</strong></td>" +
                "<td style='padding: 8px; border: 1px solid #ddd;'>" + rdv.getDateFormatee() + "NonNullNode\n" +
                "<tr><td style='padding: 8px; border: 1px solid #ddd;'><strong>Lieu</strong></td>" +
                "<td style='padding: 8px; border: 1px solid #ddd;'>" + rdv.getMedecin().getLieu() + "NonNullNode\n" +
                "</table>" +
                "<p style='color: #666;'>Merci de vous présenter 10 minutes avant l'heure du rendez-vous.</p>" +
                "<p>Cordialement,<br><strong>RDV Medical</strong></p>" +
                "</body></html>";

        String emailPatient = rdv.getPatient() != null ? rdv.getPatient().getEmail() : null;
        if (emailPatient != null && !emailPatient.isEmpty()) {
            envoyerEmail(emailPatient, sujet, contenu);
        } else {
            System.err.println("[MailService] ❌ Impossible d'envoyer au patient : email null ou vide");
        }

        String sujetMedecin = "Nouveau rendez-vous - " + rdv.getPatient().getNomPat();
        String contenuMedecin = "<html><body style='font-family: Arial, sans-serif;'>" +
                "<h2 style='color: #2E86AB;'>Nouveau rendez-vous</h2>" +
                "<p>Bonjour Dr. <strong>" + rdv.getMedecin().getNommed() + "</strong>,</p>" +
                "<p>Un nouveau rendez-vous a été enregistré :</p>" +
                "<table style='border-collapse: collapse; width: 100%;'>" +
                "<tr><td style='padding: 8px; border: 1px solid #ddd;'><strong>Patient</strong></td>" +
                "<td style='padding: 8px; border: 1px solid #ddd;'>" + rdv.getPatient().getNomPat() + "NonNullNode\n" +
                "<tr><td style='padding: 8px; border: 1px solid #ddd;'><strong>Date et heure</strong></td>" +
                "<td style='padding: 8px; border: 1px solid #ddd;'>" + rdv.getDateFormatee() + "NonNullNode\n" +
                "</table>" +
                "<p>Cordialement,<br><strong>RDV Medical</strong></p>" +
                "</body></html>";

        String emailMedecin = rdv.getMedecin() != null ? rdv.getMedecin().getEmail() : null;
        if (emailMedecin != null && !emailMedecin.isEmpty()) {
            envoyerEmail(emailMedecin, sujetMedecin, contenuMedecin);
        } else {
            System.err.println("[MailService] ❌ Impossible d'envoyer au médecin : email null ou vide");
        }
    }

    public void envoyerAnnulation(Rdv rdv) {
        // Vérification que rdv n'est pas null
        if (rdv == null) {
            System.err.println("[MailService] ❌ Erreur: rdv est null");
            return;
        }

        System.out.println("=== 📧 DEBUG MAIL ANNULATION ===");
        System.out.println("Patient nom: " + (rdv.getPatient() != null ? rdv.getPatient().getNomPat() : "null"));
        System.out.println("Patient email: " + (rdv.getPatient() != null ? rdv.getPatient().getEmail() : "null"));
        System.out.println("Medecin nom: " + (rdv.getMedecin() != null ? rdv.getMedecin().getNommed() : "null"));
        System.out.println("Medecin email: " + (rdv.getMedecin() != null ? rdv.getMedecin().getEmail() : "null"));
        System.out.println("=================================");

        String sujet = "Annulation de votre rendez-vous médical";

        String contenu = "<html><body style='font-family: Arial, sans-serif;'>" +
                "<h2 style='color: #E74C3C;'>Annulation de rendez-vous</h2>" +
                "<p>Bonjour <strong>" + rdv.getPatient().getNomPat() + "</strong>,</p>" +
                "<p>Votre rendez-vous suivant a été annulé :</p>" +
                "<table style='border-collapse: collapse; width: 100%;'>" +
                "<tr><td style='padding: 8px; border: 1px solid #ddd;'><strong>Médecin</strong></td>" +
                "<td style='padding: 8px; border: 1px solid #ddd;'>Dr. " + rdv.getMedecin().getNommed() + "NonNullNode\n" +
                "<tr><td style='padding: 8px; border: 1px solid #ddd;'><strong>Date et heure</strong></td>" +
                "<td style='padding: 8px; border: 1px solid #ddd;'>" + rdv.getDateFormatee() + "NonNullNode\n" +
                "</table>" +
                "<p>Vous pouvez prendre un nouveau rendez-vous sur notre plateforme.</p>" +
                "<p>Cordialement,<br><strong>RDV Medical</strong></p>" +
                "</body></html>";

        String emailPatient = rdv.getPatient() != null ? rdv.getPatient().getEmail() : null;
        if (emailPatient != null && !emailPatient.isEmpty()) {
            envoyerEmail(emailPatient, sujet, contenu);
        } else {
            System.err.println("[MailService] ❌ Impossible d'envoyer l'annulation au patient : email null ou vide");
        }

        String sujetMedecin = "Annulation RDV - " + rdv.getPatient().getNomPat();
        String emailMedecin = rdv.getMedecin() != null ? rdv.getMedecin().getEmail() : null;
        if (emailMedecin != null && !emailMedecin.isEmpty()) {
            envoyerEmail(emailMedecin, sujetMedecin, contenu);
        } else {
            System.err.println("[MailService] ❌ Impossible d'envoyer l'annulation au médecin : email null ou vide");
        }
    }
}