package com.rdv.service;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.time.LocalDate;
import java.util.List;

import com.rdv.dao.PatientDAO;
import com.rdv.model.Patient;
import com.rdv.util.DBConnection;
import com.rdv.util.PasswordUtil;

/**
 * Service pour la logique métier liée aux patients.
 * Fait le lien entre les Servlets et le PatientDAO.
 */
public class PatientService {

    private final PatientDAO patientDAO = new PatientDAO();

    // ── Inscription ───────────────────────────────────────────────────────────

    /**
     * Inscrit un nouveau patient.
     * Hash le mot de passe avant de l'enregistrer.
     * Retourne null si succès, ou un message d'erreur.
     */
    public String inscrire(String nom, String dateNaisStr,
                           String email, String telephone, String motDePasse) { // MODIFIÉ

        // Validation
        if (nom == null || nom.trim().isEmpty())
            return "Le nom est obligatoire.";
        if (email == null || !email.contains("@"))
            return "Email invalide.";
        if (motDePasse == null || motDePasse.length() < 6)
            return "Le mot de passe doit contenir au moins 6 caractères.";

        // Vérifier si l'email existe déjà
        if (patientDAO.trouverParEmail(email) != null)
            return "Cet email est déjà utilisé.";

        // Créer le patient
        Patient patient = new Patient();
        patient.setNomPat(nom.trim());
        patient.setDatenais(LocalDate.parse(dateNaisStr));
        patient.setEmail(email.trim().toLowerCase());
        patient.setTelephone(telephone); // NOUVEAU
        patient.setMotDePasse(PasswordUtil.hasher(motDePasse)); // hashage bcrypt

        boolean ok = patientDAO.inserer(patient);
        return ok ? null : "Erreur lors de l'inscription. Veuillez réessayer.";
    }

    // ── Connexion ─────────────────────────────────────────────────────────────

    /**
     * Vérifie les identifiants d'un patient.
     * Retourne le patient si ok, null sinon.
     */
    public Patient connecter(String email, String motDePasse) {
        if (email == null || motDePasse == null) return null;

        Patient patient = patientDAO.trouverParEmail(email.trim().toLowerCase());
        if (patient == null) return null;

        // Vérifier le mot de passe avec bcrypt
        if (!PasswordUtil.verifier(motDePasse, patient.getMotDePasse()))
            return null;

        // Ne pas garder le hash en mémoire dans la session
        patient.setMotDePasse(null);
        return patient;
    }

    // ── CRUD ─────────────────────────────────────────────────────────────────

    public List<Patient> listerTous() {
        return patientDAO.listerTous();
    }

    public Patient trouverParId(String idpat) {
        if (idpat == null || idpat.isEmpty()) return null;
        return patientDAO.trouverParId(idpat);
    }

    /**
     * Trouve un patient par son email
     */
    public Patient trouverParEmail(String email) {
        if (email == null || email.isEmpty()) return null;
        return patientDAO.trouverParEmail(email.trim().toLowerCase());
    }

    /**
     * Modifie un patient et retourne le patient mis à jour
     */
    public Patient modifierEtRetourner(String idpat, String nom, String dateNaisStr, String email, String telephone) {
        if (nom == null || nom.trim().isEmpty()) return null;
        if (email == null || !email.contains("@")) return null;

        Patient patient = new Patient();
        patient.setIdpat(idpat);
        patient.setNomPat(nom.trim());
        patient.setDatenais(LocalDate.parse(dateNaisStr));
        patient.setEmail(email.trim().toLowerCase());
        patient.setTelephone(telephone); // NOUVEAU

        boolean ok = patientDAO.modifier(patient);
        if (!ok) return null;

        // Retourner le patient mis à jour depuis la base
        return patientDAO.trouverParId(idpat);
    }

    /**
     * Modifie un patient et retourne null si succès, un message d'erreur sinon
     */
    public String modifier(String idpat, String nom, String dateNaisStr, String email, String telephone) { // MODIFIÉ
        // Validation
        if (idpat == null || idpat.trim().isEmpty()) {
            return "ID patient manquant.";
        }
        if (nom == null || nom.trim().isEmpty()) {
            return "Le nom est obligatoire.";
        }
        if (email == null || !email.contains("@")) {
            return "Email invalide.";
        }

        // Vérifier que la date est valide
        try {
            LocalDate.parse(dateNaisStr);
        } catch (Exception e) {
            return "Date de naissance invalide.";
        }

        // Vérifier si le patient existe
        Patient patientExistant = patientDAO.trouverParId(idpat);
        if (patientExistant == null) {
            return "Patient non trouvé.";
        }

        // Vérifier si l'email est déjà utilisé par un autre patient
        Patient patientMemeEmail = patientDAO.trouverParEmail(email.trim().toLowerCase());
        if (patientMemeEmail != null && !patientMemeEmail.getIdpat().equals(idpat)) {
            return "Cet email est déjà utilisé par un autre patient.";
        }

        // Créer l'objet patient avec les nouvelles données
        Patient patient = new Patient();
        patient.setIdpat(idpat);
        patient.setNomPat(nom.trim());
        patient.setDatenais(LocalDate.parse(dateNaisStr));
        patient.setEmail(email.trim().toLowerCase());
        patient.setTelephone(telephone); // NOUVEAU

        System.out.println("[PatientService] Modification patient - ID: " + idpat +
                ", Nom: " + nom + ", Email: " + email + ", Telephone: " + telephone);

        boolean ok = patientDAO.modifier(patient);

        if (!ok) {
            System.err.println("[PatientService] Échec de la modification en base de données");
            return "Erreur lors de la modification en base de données.";
        }

        System.out.println("[PatientService] Modification réussie");
        return null; // Succès
    }

    public boolean supprimer(String idpat) {
        if (idpat == null || idpat.isEmpty()) return false;
        return patientDAO.supprimer(idpat);
    }

    /**
     * Modifie le mot de passe d'un patient
     */
    public boolean modifierMotDePasse(Patient patient) {
        if (patient == null || patient.getIdpat() == null) return false;

        String sql = "UPDATE patient SET mot_de_passe = ? WHERE idpat = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, patient.getMotDePasse());
            ps.setString(2, patient.getIdpat());
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            System.err.println("[PatientService] Erreur modifierMotDePasse : " + e.getMessage());
            return false;
        }
    }

    // Mettre à jour les coordonnées du patient
    public boolean mettreAJourCoordonnees(String idPatient, Double latitude, Double longitude, String adresse) {
        return patientDAO.mettreAJourCoordonnees(idPatient, latitude, longitude, adresse);
    }

    // Récupérer les patients avec coordonnées pour un médecin
    public List<Patient> getPatientsAvecCoordonneesPourMedecin(String idMedecin) {
        return patientDAO.getPatientsAvecCoordonneesPourMedecin(idMedecin);
    }
}