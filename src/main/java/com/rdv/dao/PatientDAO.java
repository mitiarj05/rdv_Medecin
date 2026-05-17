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

        String sql = "INSERT INTO patient (nom_pat, datenais, email, telephone, mot_de_passe, langue, latitude, longitude, adresse) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, patient.getNomPat());
            ps.setDate(2, Date.valueOf(patient.getDatenais()));
            ps.setString(3, patient.getEmail());
            ps.setString(4, patient.getTelephone());
            ps.setString(5, patient.getMotDePasse());
            ps.setString(6, patient.getLangue() != null ? patient.getLangue() : "fr");

            if (patient.getLatitude() != null) {
                ps.setDouble(7, patient.getLatitude());
            } else {
                ps.setNull(7, java.sql.Types.DOUBLE);
            }

            if (patient.getLongitude() != null) {
                ps.setDouble(8, patient.getLongitude());
            } else {
                ps.setNull(8, java.sql.Types.DOUBLE);
            }

            ps.setString(9, patient.getAdresse());

            return ps.executeUpdate() == 1;

        } catch (SQLException e) {
            System.err.println("[PatientDAO] Erreur inserer : " + e.getMessage());
            return false;
        }
    }

    // ── VÉRIFICATION TÉLÉPHONE UNIQUE ────────────────────────────────────────

    public boolean telephoneExiste(String telephone, String idPatient) {
        if (telephone == null || telephone.isEmpty()) {
            return false;
        }

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
        String sql = "SELECT idpat, nom_pat, datenais, email, telephone, langue, latitude, longitude, adresse FROM patient ORDER BY nom_pat";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                liste.add(mapperComplet(rs));
            }

        } catch (SQLException e) {
            System.err.println("[PatientDAO] Erreur listerTous : " + e.getMessage());
        }
        return liste;
    }

    public Patient trouverParId(String idpat) {
        String sql = "SELECT idpat, nom_pat, datenais, email, telephone, langue, latitude, longitude, adresse FROM patient WHERE idpat::text = ?";

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
                    return mapperComplet(rs);
                }
            }

        } catch (SQLException e) {
            System.err.println("[PatientDAO] Erreur trouverParId : " + e.getMessage());
        }
        return null;
    }

    public Patient trouverParEmail(String email) {
        String sql = "SELECT idpat, nom_pat, datenais, email, telephone, mot_de_passe, langue, latitude, longitude, adresse FROM patient WHERE email = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Patient p = mapperComplet(rs);
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
        String sql = "UPDATE patient SET nom_pat = ?, datenais = ?, email = ?, telephone = ?, langue = ?, latitude = ?, longitude = ?, adresse = ? WHERE idpat::text = ?";

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
            ps.setString(5, patient.getLangue() != null ? patient.getLangue() : "fr");

            if (patient.getLatitude() != null) {
                ps.setDouble(6, patient.getLatitude());
            } else {
                ps.setNull(6, java.sql.Types.DOUBLE);
            }

            if (patient.getLongitude() != null) {
                ps.setDouble(7, patient.getLongitude());
            } else {
                ps.setNull(7, java.sql.Types.DOUBLE);
            }

            ps.setString(8, patient.getAdresse());
            ps.setString(9, patient.getIdpat());

            return ps.executeUpdate() == 1;

        } catch (SQLException e) {
            System.err.println("[PatientDAO] Erreur modifier : " + e.getMessage());
            return false;
        }
    }

    // ── NOUVELLES MÉTHODES POUR GÉOLOCALISATION ──────────────────────────────

    public boolean mettreAJourCoordonnees(String idPatient, Double latitude, Double longitude, String adresse) {
        String sql = "UPDATE patient SET latitude = ?, longitude = ?, adresse = ? WHERE idpat::text = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            if (latitude != null) {
                ps.setDouble(1, latitude);
            } else {
                ps.setNull(1, java.sql.Types.DOUBLE);
            }

            if (longitude != null) {
                ps.setDouble(2, longitude);
            } else {
                ps.setNull(2, java.sql.Types.DOUBLE);
            }

            ps.setString(3, adresse);
            ps.setString(4, idPatient);

            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            System.err.println("[PatientDAO] Erreur mettreAJourCoordonnees: " + e.getMessage());
            return false;
        }
    }

    public List<Patient> getPatientsAvecCoordonneesPourMedecin(String idMedecin) {
        List<Patient> liste = new ArrayList<>();
        String sql = "SELECT DISTINCT p.idpat, p.nom_pat, p.email, p.telephone, p.datenais, " +
                "p.latitude, p.longitude, p.adresse, p.langue " +
                "FROM patient p " +
                "INNER JOIN rdv r ON p.idpat = r.idpat " +
                "WHERE r.idmed::text = ? AND p.latitude IS NOT NULL AND p.longitude IS NOT NULL " +
                "ORDER BY p.nom_pat";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, idMedecin);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                liste.add(mapperComplet(rs));
            }
        } catch (SQLException e) {
            System.err.println("[PatientDAO] Erreur getPatientsAvecCoordonneesPourMedecin: " + e.getMessage());
        }
        return liste;
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

    private Patient mapperComplet(ResultSet rs) throws SQLException {
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
        p.setLangue(rs.getString("langue"));

        Object latObj = rs.getObject("latitude");
        if (latObj != null) {
            p.setLatitude(rs.getDouble("latitude"));
        }

        Object lonObj = rs.getObject("longitude");
        if (lonObj != null) {
            p.setLongitude(rs.getDouble("longitude"));
        }

        p.setAdresse(rs.getString("adresse"));

        return p;
    }

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
        p.setLangue(rs.getString("langue"));
        p.setAdresse(rs.getString("adresse"));

        return p;
    }
}