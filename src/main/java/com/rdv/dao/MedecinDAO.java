package com.rdv.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import com.rdv.model.Medecin;
import com.rdv.util.DBConnection;

public class MedecinDAO {

    // ── CREATE ───────────────────────────────────────────────────────────────

    public boolean inserer(Medecin medecin) {
        if (emailExiste(medecin.getEmail())) {
            System.err.println("[MedecinDAO] L'email " + medecin.getEmail() + " est déjà utilisé");
            return false;
        }
        
        // 🔥 NOUVEAU : Vérifier si le téléphone existe déjà
        if (medecin.getTelephone() != null && !medecin.getTelephone().isEmpty()) {
            if (telephoneExiste(medecin.getTelephone(), null)) {
                System.err.println("[MedecinDAO] Le téléphone " + medecin.getTelephone() + " est déjà utilisé");
                return false;
            }
        }

        String sql = "INSERT INTO medecin (nommed, specialite, taux_horaire, lieu, email, telephone, mot_de_passe) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, medecin.getNommed());
            ps.setString(2, medecin.getSpecialite());
            ps.setInt(3, medecin.getTauxHoraire());
            ps.setString(4, medecin.getLieu());
            ps.setString(5, medecin.getEmail());
            ps.setString(6, medecin.getTelephone());
            ps.setString(7, medecin.getMotDePasse());

            return ps.executeUpdate() == 1;

        } catch (SQLException e) {
            System.err.println("[MedecinDAO] Erreur inserer : " + e.getMessage());
            return false;
        }
    }

    // ── VÉRIFICATION TÉLÉPHONE UNIQUE (NOUVELLE MÉTHODE) ────────────────────────
    
    /**
     * Vérifie si un numéro de téléphone existe déjà chez un médecin ou un patient
     * @param telephone Le numéro à vérifier
     * @param idMedecin L'ID du médecin actuel (null pour création, sinon pour modification)
     * @return true si le téléphone existe déjà, false sinon
     */
    public boolean telephoneExiste(String telephone, String idMedecin) {
        if (telephone == null || telephone.isEmpty()) {
            return false;
        }
        
        String sqlMedecin = "SELECT COUNT(*) FROM medecin WHERE telephone = ?";
        String sqlPatient = "SELECT COUNT(*) FROM patient WHERE telephone = ?";
        
        if (idMedecin != null && !idMedecin.isEmpty()) {
            sqlMedecin = "SELECT COUNT(*) FROM medecin WHERE telephone = ? AND idmed::text != ?";
        }
        
        try (Connection conn = DBConnection.getConnection()) {
            // Vérifier chez les médecins
            try (PreparedStatement ps = conn.prepareStatement(sqlMedecin)) {
                ps.setString(1, telephone);
                if (idMedecin != null && !idMedecin.isEmpty()) {
                    ps.setString(2, idMedecin);
                }
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        System.out.println("[MedecinDAO] Téléphone " + telephone + " trouvé chez un médecin");
                        return true;
                    }
                }
            }
            
            // Vérifier chez les patients
            try (PreparedStatement ps = conn.prepareStatement(sqlPatient)) {
                ps.setString(1, telephone);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        System.out.println("[MedecinDAO] Téléphone " + telephone + " trouvé chez un patient");
                        return true;
                    }
                }
            }
        } catch (SQLException e) {
            System.err.println("[MedecinDAO] Erreur telephoneExiste: " + e.getMessage());
        }
        return false;
    }

    // ── VÉRIFICATION EMAIL ───────────────────────────────────────────────────

    public boolean emailExiste(String email) {
        if (email == null || email.isEmpty()) return false;

        String sqlMedecin = "SELECT COUNT(*) FROM medecin WHERE email = ?";
        String sqlPatient = "SELECT COUNT(*) FROM patient WHERE email = ?";
        
        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(sqlMedecin)) {
                ps.setString(1, email);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) return true;
                }
            }
            try (PreparedStatement ps = conn.prepareStatement(sqlPatient)) {
                ps.setString(1, email);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) return true;
                }
            }
        } catch (SQLException e) {
            System.err.println("[MedecinDAO] Erreur emailExiste: " + e.getMessage());
        }
        return false;
    }

    public boolean emailExistePourAutreMedecin(String email, String idMedecin) {
        if (email == null || email.isEmpty() || idMedecin == null || idMedecin.isEmpty()) return false;

        String sqlMedecin = "SELECT COUNT(*) FROM medecin WHERE email = ? AND idmed::text != ?";
        String sqlPatient = "SELECT COUNT(*) FROM patient WHERE email = ?";
        
        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(sqlMedecin)) {
                ps.setString(1, email);
                ps.setString(2, idMedecin);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) return true;
                }
            }
            try (PreparedStatement ps = conn.prepareStatement(sqlPatient)) {
                ps.setString(1, email);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) return true;
                }
            }
        } catch (SQLException e) {
            System.err.println("[MedecinDAO] Erreur emailExistePourAutreMedecin: " + e.getMessage());
        }
        return false;
    }

    // ── READ ─────────────────────────────────────────────────────────────────

    public List<Medecin> listerTous() {
        List<Medecin> liste = new ArrayList<>();
        String sql = "SELECT idmed::text, nommed, specialite, taux_horaire, lieu, email, telephone " +
                "FROM medecin WHERE email != 'admin@rdv.com' ORDER BY nommed";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                liste.add(mapper(rs));
            }

        } catch (SQLException e) {
            System.err.println("[MedecinDAO] Erreur listerTous : " + e.getMessage());
        }
        return liste;
    }

    public List<Medecin> listerTousAvecAdmin() {
        List<Medecin> liste = new ArrayList<>();
        String sql = "SELECT idmed::text, nommed, specialite, taux_horaire, lieu, email, telephone " +
                "FROM medecin ORDER BY nommed";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                liste.add(mapper(rs));
            }

        } catch (SQLException e) {
            System.err.println("[MedecinDAO] Erreur listerTousAvecAdmin : " + e.getMessage());
        }
        return liste;
    }

    public Medecin trouverParId(String idmed) {
        if (idmed == null || idmed.isEmpty()) return null;

        try {
            UUID.fromString(idmed);
        } catch (IllegalArgumentException e) {
            System.err.println("[MedecinDAO] ID invalide: " + idmed);
            return null;
        }

        String sql = "SELECT idmed::text, nommed, specialite, taux_horaire, lieu, email, telephone " +
                "FROM medecin WHERE idmed::text = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, idmed);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapper(rs);
            }

        } catch (SQLException e) {
            System.err.println("[MedecinDAO] Erreur trouverParId : " + e.getMessage());
        }
        return null;
    }

    public Medecin trouverParEmail(String email) {
        String sql = "SELECT idmed::text, nommed, specialite, taux_horaire, lieu, email, telephone, mot_de_passe " +
                "FROM medecin WHERE email = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Medecin m = mapper(rs);
                    m.setMotDePasse(rs.getString("mot_de_passe"));
                    return m;
                }
            }

        } catch (SQLException e) {
            System.err.println("[MedecinDAO] Erreur trouverParEmail : " + e.getMessage());
        }
        return null;
    }

    // ── RECHERCHE ────────────────────────────────────────────────────────────

    public List<Medecin> rechercherParNom(String motCle) {
        List<Medecin> liste = new ArrayList<>();
        String sql = "SELECT idmed::text, nommed, specialite, taux_horaire, lieu, email, telephone " +
                "FROM medecin WHERE nommed ILIKE ? AND email != 'admin@rdv.com' ORDER BY nommed";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, "%" + motCle + "%");
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    liste.add(mapper(rs));
                }
            }

        } catch (SQLException e) {
            System.err.println("[MedecinDAO] Erreur rechercherParNom : " + e.getMessage());
        }
        return liste;
    }

    public List<Medecin> listerParSpecialite(String specialite) {
        List<Medecin> liste = new ArrayList<>();
        String sql = "SELECT idmed::text, nommed, specialite, taux_horaire, lieu, email, telephone " +
                "FROM medecin WHERE specialite = ? AND email != 'admin@rdv.com' ORDER BY nommed";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, specialite);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    liste.add(mapper(rs));
                }
            }

        } catch (SQLException e) {
            System.err.println("[MedecinDAO] Erreur listerParSpecialite : " + e.getMessage());
        }
        return liste;
    }

    public List<String> listerSpecialites() {
        List<String> liste = new ArrayList<>();
        String sql = "SELECT DISTINCT specialite FROM medecin WHERE email != 'admin@rdv.com' ORDER BY specialite";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                liste.add(rs.getString("specialite"));
            }

        } catch (SQLException e) {
            System.err.println("[MedecinDAO] Erreur listerSpecialites : " + e.getMessage());
        }
        return liste;
    }

    public List<Medecin> top5PlusConsultes() {
        List<Medecin> liste = new ArrayList<>();
        String sql = "SELECT m.idmed::text, m.nommed, m.specialite, m.taux_horaire, m.lieu, m.email, m.telephone, " +
                "COUNT(r.idrdv) AS nb_consultations " +
                "FROM medecin m " +
                "JOIN rdv r ON m.idmed = r.idmed " +
                "WHERE r.statut = 'CONFIRME' AND m.email != 'admin@rdv.com' " +
                "GROUP BY m.idmed, m.nommed, m.specialite, m.taux_horaire, m.lieu, m.email, m.telephone " +
                "ORDER BY nb_consultations DESC " +
                "LIMIT 5";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                liste.add(mapper(rs));
            }

        } catch (SQLException e) {
            System.err.println("[MedecinDAO] Erreur top5PlusConsultes : " + e.getMessage());
        }
        return liste;
    }

    // ── GESTION DES PATIENTS DU MÉDECIN ───────────────────────────────────────

    public List<PatientAvecStat> listerPatientsAvecStatistiques(String idMedecin) {
        List<PatientAvecStat> liste = new ArrayList<>();

        if (idMedecin == null || idMedecin.isEmpty()) return liste;

        System.out.println("[MedecinDAO] Recherche patients pour médecin: " + idMedecin);

        String sql = "SELECT p.idpat, p.nom_pat, p.email, p.telephone, p.datenais, " +
                "COUNT(r.idrdv) as nb_rdv, " +
                "MAX(r.date_rdv) as dernier_rdv " +
                "FROM patient p " +
                "INNER JOIN rdv r ON p.idpat = r.idpat " +
                "WHERE r.idmed::text = ? " +
                "GROUP BY p.idpat, p.nom_pat, p.email, p.telephone, p.datenais " +
                "ORDER BY dernier_rdv DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, idMedecin);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    PatientAvecStat p = new PatientAvecStat();
                    p.setIdpat(rs.getString("idpat"));
                    p.setNomPat(rs.getString("nom_pat"));
                    p.setEmail(rs.getString("email"));
                    p.setTelephone(rs.getString("telephone"));
                    p.setDatenais(rs.getString("datenais"));
                    p.setNbRendezVous(rs.getInt("nb_rdv"));

                    Timestamp ts = rs.getTimestamp("dernier_rdv");
                    if (ts != null) {
                        p.setDernierRdv(ts.toLocalDateTime().format(DateTimeFormatter.ofPattern("dd/MM/yyyy")));
                    }
                    liste.add(p);
                    System.out.println("[MedecinDAO] Patient: " + p.getNomPat());
                }
            }
        } catch (SQLException e) {
            System.err.println("[MedecinDAO] Erreur: " + e.getMessage());
            e.printStackTrace();
        }

        return liste;
    }

    public boolean retirerPatientDeMaListe(String idMedecin, String idPatient) {
        String sql = "DELETE FROM rdv WHERE idmed::text = ? AND idpat::text = ? AND date_rdv > NOW()";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, idMedecin);
            ps.setString(2, idPatient);
            int deleted = ps.executeUpdate();
            System.out.println("[MedecinDAO] RDV futurs supprimés: " + deleted);
            return true;
        } catch (SQLException e) {
            System.err.println("[MedecinDAO] Erreur: " + e.getMessage());
            return false;
        }
    }

    // ── UPDATE ───────────────────────────────────────────────────────────────

    public boolean modifier(Medecin medecin) {
        if (medecin.getIdmed() == null || medecin.getIdmed().isEmpty()) {
            System.err.println("[MedecinDAO] ID médecin invalide");
            return false;
        }

        if (emailExistePourAutreMedecin(medecin.getEmail(), medecin.getIdmed())) {
            System.err.println("[MedecinDAO] Impossible de modifier: l'email " + medecin.getEmail() + " est déjà utilisé par un autre compte");
            return false;
        }
        
        // 🔥 NOUVEAU : Vérifier si le téléphone existe déjà chez un autre médecin ou patient
        if (medecin.getTelephone() != null && !medecin.getTelephone().isEmpty()) {
            if (telephoneExiste(medecin.getTelephone(), medecin.getIdmed())) {
                System.err.println("[MedecinDAO] Impossible de modifier: le téléphone " + medecin.getTelephone() + " est déjà utilisé par un autre compte");
                return false;
            }
        }

        String sql = "UPDATE medecin SET nommed = ?, specialite = ?, taux_horaire = ?, " +
                "lieu = ?, email = ?, telephone = ? WHERE idmed::text = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, medecin.getNommed());
            ps.setString(2, medecin.getSpecialite());
            ps.setInt(3, medecin.getTauxHoraire());
            ps.setString(4, medecin.getLieu());
            ps.setString(5, medecin.getEmail());
            ps.setString(6, medecin.getTelephone());
            ps.setString(7, medecin.getIdmed());

            return ps.executeUpdate() == 1;

        } catch (SQLException e) {
            System.err.println("[MedecinDAO] Erreur modifier : " + e.getMessage());
            return false;
        }
    }

    // ── DELETE ───────────────────────────────────────────────────────────────

    public boolean supprimer(String idmed) {
        if (idmed == null || idmed.isEmpty()) return false;

        String sql = "DELETE FROM medecin WHERE idmed::text = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, idmed);
            return ps.executeUpdate() == 1;

        } catch (SQLException e) {
            System.err.println("[MedecinDAO] Erreur supprimer : " + e.getMessage());
            return false;
        }
    }

    // ── MAPPER ───────────────────────────────────────────────────────────────

    private Medecin mapper(ResultSet rs) throws SQLException {
        Medecin m = new Medecin();
        Object idObj = rs.getObject("idmed");
        if (idObj != null) {
            m.setIdmed(idObj.toString());
        }
        m.setNommed(rs.getString("nommed"));
        m.setSpecialite(rs.getString("specialite"));
        m.setTauxHoraire(rs.getInt("taux_horaire"));
        m.setLieu(rs.getString("lieu"));
        m.setEmail(rs.getString("email"));
        m.setTelephone(rs.getString("telephone"));
        return m;
    }

    // ── CLASSE INTERNE ───────────────────────────────────────────────────────

    public static class PatientAvecStat {
        private String idpat;
        private String nomPat;
        private String email;
        private String telephone;
        private String datenais;
        private int nbRendezVous;
        private String dernierRdv;

        public String getIdpat() { return idpat; }
        public void setIdpat(String idpat) { this.idpat = idpat; }
        public String getNomPat() { return nomPat; }
        public void setNomPat(String nomPat) { this.nomPat = nomPat; }
        public String getEmail() { return email; }
        public void setEmail(String email) { this.email = email; }
        public String getTelephone() { return telephone; }
        public void setTelephone(String telephone) { this.telephone = telephone; }
        public String getDatenais() { return datenais; }
        public void setDatenais(String datenais) { this.datenais = datenais; }
        public int getNbRendezVous() { return nbRendezVous; }
        public void setNbRendezVous(int nbRendezVous) { this.nbRendezVous = nbRendezVous; }
        public String getDernierRdv() { return dernierRdv; }
        public void setDernierRdv(String dernierRdv) { this.dernierRdv = dernierRdv; }
    }
}