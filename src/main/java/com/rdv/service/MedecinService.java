package com.rdv.service;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import com.rdv.dao.MedecinDAO;
import com.rdv.model.Medecin;
import com.rdv.util.DBConnection;
import com.rdv.util.PasswordUtil;

public class MedecinService {

    private final MedecinDAO medecinDAO = new MedecinDAO();

    // ── Inscription ───────────────────────────────────────────────────────────

    public String inscrire(String nom, String specialite, String tauxStr,
                           String lieu, String email, String telephone, 
                           String bio, String diplomes, String experience, String photoProfile,
                           String adresse, Double latitude, Double longitude,
                           String motDePasse) {

        if (nom == null || nom.trim().isEmpty())
            return "Le nom est obligatoire.";
        if (specialite == null || specialite.trim().isEmpty())
            return "La spécialité est obligatoire.";
        if (lieu == null || lieu.trim().isEmpty())
            return "Le lieu est obligatoire.";
        if (email == null || !email.contains("@"))
            return "Email invalide.";
        if (motDePasse == null || motDePasse.length() < 6)
            return "Le mot de passe doit contenir au moins 6 caractères.";

        int taux;
        try {
            taux = Integer.parseInt(tauxStr);
            if (taux <= 0) return "Le taux horaire doit être positif.";
        } catch (NumberFormatException e) {
            return "Le taux horaire doit être un nombre entier.";
        }

        if (medecinDAO.trouverParEmail(email) != null)
            return "Cet email est déjà utilisé.";

        Medecin medecin = new Medecin();
        medecin.setNommed(nom.trim());
        medecin.setSpecialite(specialite.trim());
        medecin.setTauxHoraire(taux);
        medecin.setLieu(lieu.trim());
        medecin.setEmail(email.trim().toLowerCase());
        medecin.setTelephone(telephone);
        medecin.setBio(bio != null ? bio.trim() : null);
        medecin.setDiplomes(diplomes != null ? diplomes.trim() : null);
        medecin.setExperience(experience != null ? experience.trim() : null);
        medecin.setPhotoProfile(photoProfile);
        medecin.setAdresse(adresse != null ? adresse.trim() : null);
        medecin.setLatitude(latitude);
        medecin.setLongitude(longitude);
        medecin.setMotDePasse(PasswordUtil.hasher(motDePasse));

        boolean ok = medecinDAO.inserer(medecin);
        return ok ? null : "Erreur lors de l'inscription.";
    }

    // Version simplifiée pour l'inscription sans coordonnées
    public String inscrire(String nom, String specialite, String tauxStr,
                           String lieu, String email, String telephone, 
                           String bio, String diplomes, String experience, String photoProfile,
                           String motDePasse) {
        return inscrire(nom, specialite, tauxStr, lieu, email, telephone, 
                        bio, diplomes, experience, photoProfile, null, null, null, motDePasse);
    }

    // ── Connexion ─────────────────────────────────────────────────────────────

    public Medecin connecter(String email, String motDePasse) {
        if (email == null || motDePasse == null) return null;

        Medecin medecin = medecinDAO.trouverParEmail(email.trim().toLowerCase());
        if (medecin == null) return null;

        if (!PasswordUtil.verifier(motDePasse, medecin.getMotDePasse()))
            return null;

        medecin.setMotDePasse(null);
        return medecin;
    }

    // ── CRUD ─────────────────────────────────────────────────────────────────

    public List<Medecin> listerTous() {
        return medecinDAO.listerTous();
    }

    public List<Medecin> listerTousAvecAdmin() {
        return medecinDAO.listerTousAvecAdmin();
    }

    public Medecin trouverParId(String idmed) {
        return medecinDAO.trouverParId(idmed);
    }

    public Medecin trouverParEmail(String email) {
        if (email == null || email.isEmpty()) return null;
        return medecinDAO.trouverParEmail(email.trim().toLowerCase());
    }

    public List<Medecin> rechercherParNom(String motCle) {
        if (motCle == null || motCle.trim().isEmpty())
            return medecinDAO.listerTous();
        return medecinDAO.rechercherParNom(motCle.trim());
    }

    public List<Medecin> listerParSpecialite(String specialite) {
        return medecinDAO.listerParSpecialite(specialite);
    }

    public List<String> listerSpecialites() {
        return medecinDAO.listerSpecialites();
    }

    public List<Medecin> top5PlusConsultes() {
        return medecinDAO.top5PlusConsultes();
    }

    // ── NOUVELLES MÉTHODES POUR LA CARTE ──────────────────────────────────────

    public List<Medecin> listerAvecCoordonnees() {
        return medecinDAO.listerAvecCoordonnees();
    }

    public List<Medecin> trouverPlusProches(double lat, double lon, int limit) {
        return medecinDAO.trouverPlusProches(lat, lon, limit);
    }

    // ── GESTION DES PATIENTS DU MÉDECIN ───────────────────────────────────────

    public List<MedecinDAO.PatientAvecStat> listerPatientsAvecStats(String idMedecin) {
        if (idMedecin == null || idMedecin.isEmpty()) {
            System.out.println("[MedecinService] ID médecin null ou vide");
            return new ArrayList<>();
        }
        return medecinDAO.listerPatientsAvecStatistiques(idMedecin);
    }

    public boolean retirerPatientDeMaListe(String idMedecin, String idPatient) {
        if (idMedecin == null || idPatient == null) {
            return false;
        }
        return medecinDAO.retirerPatientDeMaListe(idMedecin, idPatient);
    }

    // ── MODIFICATION ─────────────────────────────────────────────────────────

    public String modifier(String idmed, String nom, String specialite,
                           String tauxStr, String lieu, String email, String telephone,
                           String bio, String diplomes, String experience, String photoProfile,
                           String adresse, Double latitude, Double longitude) {
        if (nom == null || nom.trim().isEmpty())
            return "Le nom est obligatoire.";
        if (email == null || !email.contains("@"))
            return "Email invalide.";

        int taux;
        try {
            taux = Integer.parseInt(tauxStr);
        } catch (NumberFormatException e) {
            return "Le taux horaire doit être un nombre entier.";
        }

        Medecin medecin = new Medecin();
        medecin.setIdmed(idmed);
        medecin.setNommed(nom.trim());
        medecin.setSpecialite(specialite.trim());
        medecin.setTauxHoraire(taux);
        medecin.setLieu(lieu.trim());
        medecin.setEmail(email.trim().toLowerCase());
        medecin.setTelephone(telephone);
        medecin.setBio(bio != null ? bio.trim() : null);
        medecin.setDiplomes(diplomes != null ? diplomes.trim() : null);
        medecin.setExperience(experience != null ? experience.trim() : null);
        medecin.setPhotoProfile(photoProfile);
        medecin.setAdresse(adresse != null ? adresse.trim() : null);
        medecin.setLatitude(latitude);
        medecin.setLongitude(longitude);

        boolean ok = medecinDAO.modifier(medecin);
        return ok ? null : "Erreur lors de la modification.";
    }

    // Version simplifiée pour la modification sans coordonnées (garder les existantes)
    public String modifier(String idmed, String nom, String specialite,
                           String tauxStr, String lieu, String email, String telephone,
                           String bio, String diplomes, String experience, String photoProfile) {
        Medecin existing = trouverParId(idmed);
        Double lat = existing != null ? existing.getLatitude() : null;
        Double lon = existing != null ? existing.getLongitude() : null;
        String adresse = existing != null ? existing.getAdresse() : null;
        return modifier(idmed, nom, specialite, tauxStr, lieu, email, telephone,
                        bio, diplomes, experience, photoProfile, adresse, lat, lon);
    }

    public boolean supprimer(String idmed) {
        return medecinDAO.supprimer(idmed);
    }

    public boolean modifierMotDePasse(Medecin medecin) {
        if (medecin == null || medecin.getIdmed() == null) return false;

        String sql = "UPDATE medecin SET mot_de_passe = ? WHERE idmed::text = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, medecin.getMotDePasse());
            ps.setString(2, medecin.getIdmed());
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            System.err.println("[MedecinService] Erreur: " + e.getMessage());
            return false;
        }
    }
}