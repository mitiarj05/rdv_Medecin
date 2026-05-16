package com.rdv.service;

import java.time.LocalDateTime;
import java.time.format.DateTimeParseException;
import java.util.List;

import com.rdv.dao.RdvDAO;
import com.rdv.model.Rdv;

/**
 * Service pour la logique métier liée aux rendez-vous.
 * C'est ici que la vérification du créneau et l'envoi de mail sont combinés.
 */
public class RdvService {

    private final RdvDAO rdvDAO = new RdvDAO();
    private final MailService mailService = new MailService();
    private final NotificationService notificationService = new NotificationService(); // NOUVEAU

    // ── Prendre un RDV ────────────────────────────────────────────────────────

    /**
     * Crée un nouveau rendez-vous.
     * Vérifie d'abord si le créneau est libre, puis insère et envoie le mail.
     * Retourne null si succès, ou un message d'erreur.
     */
    public String prendreRdv(String idmed, String idpat, String dateRdvStr) {

        // Validation
        if (idmed == null || idmed.trim().isEmpty())
            return "Médecin invalide.";
        if (idpat == null || idpat.trim().isEmpty())
            return "Patient invalide.";

        LocalDateTime dateRdv;
        try {
            dateRdv = LocalDateTime.parse(dateRdvStr); // format : 2026-04-10T09:00
        } catch (DateTimeParseException e) {
            return "Format de date invalide.";
        }

        // Vérifier que la date est dans le futur
        if (dateRdv.isBefore(LocalDateTime.now()))
            return "Impossible de prendre un RDV dans le passé.";

        // Vérifier si le créneau est libre
        if (!rdvDAO.estCreneauLibre(idmed, dateRdv))
            return "Ce créneau est déjà réservé. Veuillez choisir un autre horaire.";

        // Créer et insérer le RDV
        Rdv rdv = new Rdv(idmed, idpat, dateRdv);
        boolean ok = rdvDAO.inserer(rdv);

        if (!ok) return "Erreur lors de la création du rendez-vous.";

        // Récupérer le RDV complet avec médecin et patient pour le mail
        List<Rdv> rdvPatient = rdvDAO.listerParPatient(idpat);
        if (!rdvPatient.isEmpty()) {
            Rdv nouveauRdv = rdvPatient.get(0);
            // Vérifier que le RDV correspond bien au médecin choisi
            if (nouveauRdv.getIdmed().equals(idmed)) {
                try {
                    mailService.envoyerConfirmation(nouveauRdv);
                    notificationService.notifierNouveauRendezVous(nouveauRdv); // NOUVEAU
                } catch (Exception e) {
                    System.err.println("[RdvService] Mail non envoyé : " + e.getMessage());
                }
            }
        }

        return null; // null = succès
    }

    // ── Annuler un RDV ────────────────────────────────────────────────────────

    /**
     * Annule un rendez-vous existant.
     * Met le statut à ANNULE et envoie un mail d'annulation.
     */
    public String annulerRdv(String idrdv) {
        if (idrdv == null || idrdv.trim().isEmpty())
            return "Identifiant de RDV invalide.";

        // Récupérer le RDV complet avant d'annuler (pour le mail)
        Rdv rdv = rdvDAO.trouverParId(idrdv);
        if (rdv == null)
            return "Rendez-vous introuvable.";
        if (rdv.isAnnule())
            return "Ce rendez-vous est déjà annulé.";

        // Annuler en BDD
        boolean ok = rdvDAO.annuler(idrdv);
        if (!ok) return "Erreur lors de l'annulation.";

        // Envoyer mail d'annulation
        try {
            mailService.envoyerAnnulation(rdv);
            notificationService.notifierAnnulationRendezVous(rdv); // NOUVEAU
        } catch (Exception e) {
            System.err.println("[RdvService] Mail annulation non envoyé : " + e.getMessage());
        }

        return null; // null = succès
    }

    // ── Listes ───────────────────────────────────────────────────────────────

    public List<Rdv> listerTous() {
        return rdvDAO.listerTous();
    }

    public List<Rdv> listerParPatient(String idpat) {
        return rdvDAO.listerParPatient(idpat);
    }

    public List<Rdv> listerParMedecin(String idmed) {
        return rdvDAO.listerParMedecin(idmed);
    }

    public List<LocalDateTime> listerCreneauxPris(String idmed) {
        return rdvDAO.listerCreneauxPris(idmed);
    }

    public Rdv trouverParId(String idrdv) {
        return rdvDAO.trouverParId(idrdv);
    }

    public boolean supprimer(String idrdv) {
        return rdvDAO.supprimer(idrdv);
    }

    public String modifierRdv(String idRdv, String idmed, String dateRdvStr) {

        if (idRdv == null || idRdv.trim().isEmpty())
            return "Identifiant RDV invalide.";

        LocalDateTime nouvelleDate;
        try {
            nouvelleDate = LocalDateTime.parse(dateRdvStr);
        } catch (DateTimeParseException e) {
            return "Format de date invalide.";
        }

        if (nouvelleDate.isBefore(LocalDateTime.now()))
            return "Impossible de modifier un RDV dans le passé.";

        Rdv rdvActuel = rdvDAO.trouverParId(idRdv);
        if (rdvActuel == null) return "Rendez-vous introuvable.";

        // Vérifier créneau libre seulement si la date change
        if (!rdvActuel.getDateRdv().equals(nouvelleDate)) {
            if (!rdvDAO.estCreneauLibre(idmed, nouvelleDate))
                return "Ce créneau est déjà réservé. Choisissez un autre horaire.";
        }

        // modifier() remet automatiquement statut = CONFIRME
        boolean ok = rdvDAO.modifier(idRdv, nouvelleDate);
        if (!ok) return "Erreur lors de la modification.";

        // Envoyer mail de confirmation
        // (que ce soit une modification ou une remise en confirmé)
        try {
            Rdv rdvMaj = rdvDAO.trouverParId(idRdv);
            if (rdvMaj != null) {
                mailService.envoyerConfirmation(rdvMaj);
                notificationService.notifierNouveauRendezVous(rdvMaj); // NOUVEAU
            }
        } catch (Exception e) {
            System.err.println("[RdvService] Mail non envoyé : " + e.getMessage());
        }

        return null;
    }

    // ── Heures prises par date ────────────────────────────────────────────────
    public List<String> listerHeuresPrisesParDate(String idmed, String date, String idRdvExclu) {
        return rdvDAO.listerHeuresPrisesParDate(idmed, date, idRdvExclu);
    }

    public List<String> listerHeuresPrisesParDate(String idmed, String date) {
        return rdvDAO.listerHeuresPrisesParDate(idmed, date, null);
    }

    // ── TOP 5 PATIENTS LES PLUS ACTIFS (NOUVELLE MÉTHODE) ─────────────────────
    /**
     * Récupère le top 5 des patients ayant le plus de rendez-vous confirmés
     */
    public List<Object[]> top5PlusActifs() {
        return rdvDAO.top5PlusActifs();
    }
}