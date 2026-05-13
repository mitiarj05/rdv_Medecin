package com.rdv.dao;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import com.rdv.model.Patient;
import com.rdv.util.DBConnection;

public class PatientDAO {

    // ── CREATE ───────────────────────────────────────────────────────────────

    public boolean inserer(Patient patient) {
        // Vérifier si l'email existe déjà (chez patient ou médecin)
        if (emailExiste(patient.getEmail())) {
            System.err.println("[PatientDAO] L'email " + patient.getEmail() + " est déjà utilisé par un autre compte");
            return false;
        }

        String sql = "INSERT INTO patient (nom_pat, datenais, email, mot_de_passe) VALUES (?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, patient.getNomPat());
            ps.setDate(2, Date.valueOf(patient.getDatenais()));
            ps.setString(3, patient.getEmail());
            ps.setString(4, patient.getMotDePasse());

            return ps.executeUpdate() == 1;

        } catch (SQLException e) {
            System.err.println("[PatientDAO] Erreur inserer : " + e.getMessage());
            return false;
        }
    }

    // ── VÉRIFICATION EMAIL ───────────────────────────────────────────────────

    /**
     * Vérifie si un email existe déjà chez les patients ou les médecins
     * @param email L'email à vérifier
     * @return true si l'email existe déjà, false sinon
     */
    public boolean emailExiste(String email) {
        if (email == null || email.isEmpty()) {
            return false;
        }

        // Vérifier dans la table patient
        String sqlPatient = "SELECT COUNT(*) FROM patient WHERE email = ?";
        // Vérifier dans la table medecin
        String sqlMedecin = "SELECT COUNT(*) FROM medecin WHERE email = ?";
        
        try (Connection conn = DBConnection.getConnection()) {
            // Vérifier chez les patients
            try (PreparedStatement ps = conn.prepareStatement(sqlPatient)) {
                ps.setString(1, email);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        System.out.println("[PatientDAO] Email " + email + " trouvé chez un patient");
                        return true;
                    }
                }
            }
            
            // Vérifier chez les médecins
            try (PreparedStatement ps = conn.prepareStatement(sqlMedecin)) {
                ps.setString(1, email);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        System.out.println("[PatientDAO] Email " + email + " trouvé chez un médecin");
                        return true;
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("[PatientDAO] Erreur lors de la vérification de l'email : " + e.getMessage());
        }
        return false;
    }

    /**
     * Vérifie si un email appartient à un autre patient (pour la modification)
     * @param email L'email à vérifier
     * @param idPatient L'ID du patient actuel (à exclure de la vérification)
     * @return true si l'email existe chez un autre patient ou chez un médecin, false sinon
     */
    public boolean emailExistePourAutrePatient(String email, String idPatient) {
        if (email == null || email.isEmpty() || idPatient == null || idPatient.isEmpty()) {
            return false;
        }

        // Vérifier dans la table patient (en excluant le patient actuel)
        String sqlPatient = "SELECT COUNT(*) FROM patient WHERE email = ? AND idpat::text != ?";
        // Vérifier dans la table medecin
        String sqlMedecin = "SELECT COUNT(*) FROM medecin WHERE email = ?";
        
        try (Connection conn = DBConnection.getConnection()) {
            // Vérifier chez les autres patients
            try (PreparedStatement ps = conn.prepareStatement(sqlPatient)) {
                ps.setString(1, email);
                ps.setString(2, idPatient);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        System.out.println("[PatientDAO] Email " + email + " trouvé chez un autre patient");
                        return true;
                    }
                }
            }
            
            // Vérifier chez les médecins
            try (PreparedStatement ps = conn.prepareStatement(sqlMedecin)) {
                ps.setString(1, email);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        System.out.println("[PatientDAO] Email " + email + " trouvé chez un médecin");
                        return true;
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("[PatientDAO] Erreur lors de la vérification de l'email : " + e.getMessage());
        }
        return false;
    }

    // ── READ ─────────────────────────────────────────────────────────────────

    public List<Patient> listerTous() {
        List<Patient> liste = new ArrayList<>();
        String sql = "SELECT idpat, nom_pat, datenais, email FROM patient ORDER BY nom_pat";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                liste.add(mapper(rs));
            }

        } catch (SQLException e) {
            System.err.println("[PatientDAO] Erreur listerTous : " + e.getMessage());
        }
        return liste;
    }

    public Patient trouverParId(String idpat) {
        String sql = "SELECT idpat, nom_pat, datenais, email FROM patient WHERE idpat::text = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            try {
                UUID.fromString(idpat);
            } catch (IllegalArgumentException e) {
                return null;
            }

            ps.setString(1, idpat);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapper(rs);
                }
            }

        } catch (SQLException e) {
            System.err.println("[PatientDAO] Erreur trouverParId : " + e.getMessage());
        }
        return null;
    }

    public Patient trouverParEmail(String email) {
        String sql = "SELECT idpat, nom_pat, datenais, email, mot_de_passe FROM patient WHERE email = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Patient p = mapper(rs);
                    p.setMotDePasse(rs.getString("mot_de_passe"));
                    return p;
                }
            }

        } catch (SQLException e) {
            System.err.println("[PatientDAO] Erreur trouverParEmail : " + e.getMessage());
        }
        return null;
    }

    // ── UPDATE ───────────────────────────────────────────────────────────────

    public boolean modifier(Patient patient) {
        String sql = "UPDATE patient SET nom_pat = ?, datenais = ?, email = ? WHERE idpat::text = ?";

        try {
            UUID.fromString(patient.getIdpat());
        } catch (IllegalArgumentException e) {
            System.err.println("[PatientDAO] ID patient invalide");
            return false;
        }

        // Vérifier si l'email existe déjà chez un autre patient ou chez un médecin
        if (emailExistePourAutrePatient(patient.getEmail(), patient.getIdpat())) {
            System.err.println("[PatientDAO] Impossible de modifier: l'email " + patient.getEmail() + " est déjà utilisé par un autre compte");
            return false;
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, patient.getNomPat());
            ps.setDate(2, Date.valueOf(patient.getDatenais()));
            ps.setString(3, patient.getEmail());
            ps.setString(4, patient.getIdpat());

            return ps.executeUpdate() == 1;

        } catch (SQLException e) {
            System.err.println("[PatientDAO] Erreur modifier : " + e.getMessage());
            return false;
        }
    }

    // ── DELETE ───────────────────────────────────────────────────────────────

    public boolean supprimer(String idpat) {
        String sql = "DELETE FROM patient WHERE idpat::text = ?";

        try {
            UUID.fromString(idpat);
        } catch (IllegalArgumentException e) {
            return false;
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, idpat);
            return ps.executeUpdate() == 1;

        } catch (SQLException e) {
            System.err.println("[PatientDAO] Erreur supprimer : " + e.getMessage());
            return false;
        }
    }

    // ── MAPPER ───────────────────────────────────────────────────────────────

    private Patient mapper(ResultSet rs) throws SQLException {
        Patient p = new Patient();

        Object idObj = rs.getObject("idpat");
        if (idObj != null) {
            p.setIdpat(idObj.toString());
        }

        p.setNomPat(rs.getString("nom_pat"));

        Date sqlDate = rs.getDate("datenais");
        if (sqlDate != null) {
            p.setDatenais(sqlDate.toLocalDate());
        }

        p.setEmail(rs.getString("email"));
        return p;
    }
}