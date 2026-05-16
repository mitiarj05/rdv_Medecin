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
import com.rdv.util.PhoneUtil;

public class PatientDAO {

    // ── CREATE ───────────────────────────────────────────────────────────────

    public boolean inserer(Patient patient) {
        if (emailExiste(patient.getEmail())) {
            System.err.println("[PatientDAO] L'email " + patient.getEmail() + " est déjà utilisé");
            return false;
        }
        
        // Normaliser et vérifier le téléphone
        String normalizedPhone = null;
        if (patient.getTelephone() != null && !patient.getTelephone().isEmpty()) {
            normalizedPhone = PhoneUtil.normaliserTelephone(patient.getTelephone());
            if (normalizedPhone == null) {
                System.err.println("[PatientDAO] Format de téléphone invalide: " + patient.getTelephone());
                return false;
            }
            if (telephoneExiste(normalizedPhone, null)) {
                System.err.println("[PatientDAO] Le téléphone " + patient.getTelephone() + " est déjà utilisé");
                return false;
            }
            patient.setTelephone(normalizedPhone);
        }

        String sql = "INSERT INTO patient (nom_pat, datenais, email, telephone, mot_de_passe) VALUES (?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, patient.getNomPat());
            ps.setDate(2, Date.valueOf(patient.getDatenais()));
            ps.setString(3, patient.getEmail());
            ps.setString(4, patient.getTelephone());
            ps.setString(5, patient.getMotDePasse());

            return ps.executeUpdate() == 1;

        } catch (SQLException e) {
            System.err.println("[PatientDAO] Erreur inserer : " + e.getMessage());
            return false;
        }
    }

    // ── VÉRIFICATION TÉLÉPHONE UNIQUE (avec normalisation) ────────────────────
    
    /**
     * Vérifie si un numéro de téléphone existe déjà chez un patient ou un médecin
     * Le numéro est normalisé avant vérification
     * @param telephone Le numéro à vérifier
     * @param idPatient L'ID du patient actuel (null pour création, sinon pour modification)
     * @return true si le téléphone existe déjà, false sinon
     */
    public boolean telephoneExiste(String telephone, String idPatient) {
        if (telephone == null || telephone.isEmpty()) {
            return false;
        }
        
        // Normaliser le numéro avant vérification
        String normalizedPhone = PhoneUtil.normaliserTelephone(telephone);
        if (normalizedPhone == null) {
            return false;
        }
        
        String sqlPatient = "SELECT COUNT(*) FROM patient WHERE telephone = ?";
        String sqlMedecin = "SELECT COUNT(*) FROM medecin WHERE telephone = ?";
        
        if (idPatient != null && !idPatient.isEmpty()) {
            sqlPatient = "SELECT COUNT(*) FROM patient WHERE telephone = ? AND idpat::text != ?";
        }
        
        try (Connection conn = DBConnection.getConnection()) {
            // Vérifier chez les patients
            try (PreparedStatement ps = conn.prepareStatement(sqlPatient)) {
                ps.setString(1, normalizedPhone);
                if (idPatient != null && !idPatient.isEmpty()) {
                    ps.setString(2, idPatient);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        System.out.println("[PatientDAO] Téléphone " + normalizedPhone + " trouvé chez un patient");
                        return true;
                    }
                }
            }
            
            // Vérifier chez les médecins
            try (PreparedStatement ps = conn.prepareStatement(sqlMedecin)) {
                ps.setString(1, normalizedPhone);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        System.out.println("[PatientDAO] Téléphone " + normalizedPhone + " trouvé chez un médecin");
                        return true;
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("[PatientDAO] Erreur telephoneExiste: " + e.getMessage());
        }
        return false;
    }

    // ── VÉRIFICATION EMAIL ───────────────────────────────────────────────────

    public boolean emailExiste(String email) {
        if (email == null || email.isEmpty()) return false;

        String sqlPatient = "SELECT COUNT(*) FROM patient WHERE email = ?";
        String sqlMedecin = "SELECT COUNT(*) FROM medecin WHERE email = ?";
        
        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(sqlPatient)) {
                ps.setString(1, email);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) return true;
                }
            }
            try (PreparedStatement ps = conn.prepareStatement(sqlMedecin)) {
                ps.setString(1, email);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) return true;
                }
            }
        } catch (SQLException e) {
            System.err.println("[PatientDAO] Erreur emailExiste: " + e.getMessage());
        }
        return false;
    }

    public boolean emailExistePourAutrePatient(String email, String idPatient) {
        if (email == null || email.isEmpty() || idPatient == null || idPatient.isEmpty()) return false;

        String sqlPatient = "SELECT COUNT(*) FROM patient WHERE email = ? AND idpat::text != ?";
        String sqlMedecin = "SELECT COUNT(*) FROM medecin WHERE email = ?";
        
        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(sqlPatient)) {
                ps.setString(1, email);
                ps.setString(2, idPatient);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) return true;
                }
            }
            try (PreparedStatement ps = conn.prepareStatement(sqlMedecin)) {
                ps.setString(1, email);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) return true;
                }
            }
        } catch (SQLException e) {
            System.err.println("[PatientDAO] Erreur emailExistePourAutrePatient: " + e.getMessage());
        }
        return false;
    }

    // ── READ ─────────────────────────────────────────────────────────────────

    public List<Patient> listerTous() {
        List<Patient> liste = new ArrayList<>();
        String sql = "SELECT idpat, nom_pat, datenais, email, telephone FROM patient ORDER BY nom_pat";

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
        String sql = "SELECT idpat, nom_pat, datenais, email, telephone FROM patient WHERE idpat::text = ?";

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
        String sql = "SELECT idpat, nom_pat, datenais, email, telephone, mot_de_passe FROM patient WHERE email = ?";

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
        String sql = "UPDATE patient SET nom_pat = ?, datenais = ?, email = ?, telephone = ? WHERE idpat::text = ?";

        try {
            UUID.fromString(patient.getIdpat());
        } catch (IllegalArgumentException e) {
            System.err.println("[PatientDAO] ID patient invalide");
            return false;
        }

        if (emailExistePourAutrePatient(patient.getEmail(), patient.getIdpat())) {
            System.err.println("[PatientDAO] Impossible de modifier: l'email " + patient.getEmail() + " est déjà utilisé par un autre compte");
            return false;
        }
        
        // Normaliser et vérifier le téléphone
        String normalizedPhone = null;
        if (patient.getTelephone() != null && !patient.getTelephone().isEmpty()) {
            normalizedPhone = PhoneUtil.normaliserTelephone(patient.getTelephone());
            if (normalizedPhone == null) {
                System.err.println("[PatientDAO] Format de téléphone invalide: " + patient.getTelephone());
                return false;
            }
            if (telephoneExiste(normalizedPhone, patient.getIdpat())) {
                System.err.println("[PatientDAO] Impossible de modifier: le téléphone " + patient.getTelephone() + " est déjà utilisé par un autre compte");
                return false;
            }
            patient.setTelephone(normalizedPhone);
        }

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, patient.getNomPat());
            ps.setDate(2, Date.valueOf(patient.getDatenais()));
            ps.setString(3, patient.getEmail());
            ps.setString(4, patient.getTelephone());
            ps.setString(5, patient.getIdpat());

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
        p.setTelephone(rs.getString("telephone"));
        return p;
    }
}