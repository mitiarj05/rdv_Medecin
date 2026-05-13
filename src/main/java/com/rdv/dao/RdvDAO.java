package com.rdv.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import com.rdv.model.Medecin;
import com.rdv.model.Patient;
import com.rdv.model.Rdv;
import com.rdv.util.DBConnection;

public class RdvDAO {

    public boolean inserer(Rdv rdv) {
        String sql = "INSERT INTO rdv (idmed, idpat, date_rdv, statut) VALUES (?::uuid, ?::uuid, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, rdv.getIdmed());
            ps.setString(2, rdv.getIdpat());
            ps.setTimestamp(3, Timestamp.valueOf(rdv.getDateRdv()));
            ps.setString(4, Rdv.STATUT_CONFIRME);

            return ps.executeUpdate() == 1;

        } catch (SQLException e) {
            if (e.getSQLState().equals("23505")) {
                System.err.println("[RdvDAO] Créneau déjà réservé !");
            } else {
                System.err.println("[RdvDAO] Erreur inserer : " + e.getMessage());
            }
            return false;
        }
    }

    public List<Rdv> listerTous() {
        List<Rdv> liste = new ArrayList<>();
        String sql = "SELECT r.idrdv::text, r.idmed::text, r.idpat::text, r.date_rdv, r.statut, " +
                "m.nommed, m.specialite, m.lieu, m.email as email_medecin, " +
                "p.nom_pat, p.email as email_patient " +
                "FROM rdv r " +
                "JOIN medecin m ON r.idmed = m.idmed " +
                "JOIN patient p ON r.idpat = p.idpat " +
                "ORDER BY r.date_rdv DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                liste.add(mapperAvecJointure(rs));
            }

        } catch (SQLException e) {
            System.err.println("[RdvDAO] Erreur listerTous : " + e.getMessage());
            e.printStackTrace();
        }
        return liste;
    }

    public Rdv trouverParId(String idrdv) {
        String sql = "SELECT r.idrdv::text, r.idmed::text, r.idpat::text, r.date_rdv, r.statut, " +
                "m.nommed, m.specialite, m.lieu, m.email as email_medecin, " +
                "p.nom_pat, p.email as email_patient " +
                "FROM rdv r " +
                "JOIN medecin m ON r.idmed = m.idmed " +
                "JOIN patient p ON r.idpat = p.idpat " +
                "WHERE r.idrdv::text = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, idrdv);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return mapperAvecJointure(rs);
            }

        } catch (SQLException e) {
            System.err.println("[RdvDAO] Erreur trouverParId : " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    public List<Rdv> listerParPatient(String idpat) {
        List<Rdv> liste = new ArrayList<>();
        String sql = "SELECT r.idrdv::text, r.idmed::text, r.idpat::text, r.date_rdv, r.statut, " +
                "m.nommed, m.specialite, m.lieu, m.email as email_medecin, " +
                "p.nom_pat, p.email as email_patient " +
                "FROM rdv r " +
                "JOIN medecin m ON r.idmed = m.idmed " +
                "JOIN patient p ON r.idpat = p.idpat " +
                "WHERE r.idpat::text = ? " +
                "ORDER BY r.date_rdv DESC";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, idpat);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) liste.add(mapperAvecJointure(rs));
            }

        } catch (SQLException e) {
            System.err.println("[RdvDAO] Erreur listerParPatient : " + e.getMessage());
            e.printStackTrace();
        }
        return liste;
    }

    public List<Rdv> listerParMedecin(String idmed) {
        List<Rdv> liste = new ArrayList<>();
        String sql = "SELECT r.idrdv::text, r.idmed::text, r.idpat::text, r.date_rdv, r.statut, " +
                "m.nommed, m.specialite, m.lieu, m.taux_horaire, m.email as email_medecin, " +
                "p.nom_pat, p.email as email_patient " +
                "FROM rdv r " +
                "JOIN medecin m ON r.idmed = m.idmed " +
                "JOIN patient p ON r.idpat = p.idpat " +
                "WHERE r.idmed::text = ? " +
                "ORDER BY r.date_rdv DESC";

        System.out.println("[RdvDAO] listerParMedecin - ID: " + idmed);

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, idmed);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Rdv rdv = mapperAvecJointure(rs);
                    liste.add(rdv);
                    System.out.println("[RdvDAO] RDV trouvé: " + rdv.getDateRdv() + " - Patient: " +
                            (rdv.getPatient() != null ? rdv.getPatient().getNomPat() : "NULL"));
                }
            }

        } catch (SQLException e) {
            System.err.println("[RdvDAO] Erreur listerParMedecin : " + e.getMessage());
            e.printStackTrace();
        }
        System.out.println("[RdvDAO] Total RDV trouvés: " + liste.size());
        return liste;
    }

    public List<LocalDateTime> listerCreneauxPris(String idmed) {
        List<LocalDateTime> creneaux = new ArrayList<>();
        String sql = "SELECT date_rdv FROM rdv " +
                "WHERE idmed::text = ? AND statut = 'CONFIRME' AND date_rdv >= NOW() " +
                "ORDER BY date_rdv";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, idmed);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    creneaux.add(rs.getTimestamp("date_rdv").toLocalDateTime());
                }
            }

        } catch (SQLException e) {
            System.err.println("[RdvDAO] Erreur listerCreneauxPris : " + e.getMessage());
        }
        return creneaux;
    }

    public boolean estCreneauLibre(String idmed, LocalDateTime dateRdv) {
        String sql = "SELECT COUNT(*) FROM rdv " +
                "WHERE idmed::text = ? AND date_rdv = ? AND statut = 'CONFIRME'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, idmed);
            ps.setTimestamp(2, Timestamp.valueOf(dateRdv));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) == 0;
                }
            }

        } catch (SQLException e) {
            System.err.println("[RdvDAO] Erreur estCreneauLibre : " + e.getMessage());
        }
        return false;
    }

    public boolean annuler(String idrdv) {
        String sql = "UPDATE rdv SET statut = 'ANNULE' WHERE idrdv::text = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, idrdv);
            return ps.executeUpdate() == 1;

        } catch (SQLException e) {
            System.err.println("[RdvDAO] Erreur annuler : " + e.getMessage());
            return false;
        }
    }

    public boolean supprimer(String idrdv) {
        String sql = "DELETE FROM rdv WHERE idrdv::text = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, idrdv);
            return ps.executeUpdate() == 1;

        } catch (SQLException e) {
            System.err.println("[RdvDAO] Erreur supprimer : " + e.getMessage());
            return false;
        }
    }

    private Rdv mapperAvecJointure(ResultSet rs) throws SQLException {
        Rdv rdv = new Rdv();
        rdv.setIdrdv(rs.getString("idrdv"));
        rdv.setIdmed(rs.getString("idmed"));
        rdv.setIdpat(rs.getString("idpat"));

        Timestamp ts = rs.getTimestamp("date_rdv");
        if (ts != null) {
            rdv.setDateRdv(ts.toLocalDateTime());
        }
        rdv.setStatut(rs.getString("statut"));

        Medecin m = new Medecin();
        m.setIdmed(rs.getString("idmed"));
        m.setNommed(rs.getString("nommed"));
        m.setSpecialite(rs.getString("specialite"));
        m.setLieu(rs.getString("lieu"));
        m.setEmail(rs.getString("email_medecin"));
        rdv.setMedecin(m);

        Patient p = new Patient();
        p.setIdpat(rs.getString("idpat"));
        p.setNomPat(rs.getString("nom_pat"));
        p.setEmail(rs.getString("email_patient"));
        rdv.setPatient(p);

        return rdv;
    }

    public boolean modifier(String idrdv, LocalDateTime nouvelleDate) {
        String sql = "UPDATE rdv SET date_rdv = ?, statut = 'CONFIRME' WHERE idrdv::text = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setTimestamp(1, Timestamp.valueOf(nouvelleDate));
            ps.setString(2, idrdv);
            return ps.executeUpdate() == 1;

        } catch (SQLException e) {
            if (e.getSQLState().equals("23505")) {
                System.err.println("[RdvDAO] Créneau déjà réservé !");
            } else {
                System.err.println("[RdvDAO] Erreur modifier : " + e.getMessage());
            }
            return false;
        }
    }

    public List<String> listerHeuresPrisesParDate(String idmed, String date, String idRdvExclu) {
        List<String> heures = new ArrayList<>();
        String sql = "SELECT TO_CHAR(date_rdv, 'HH24:MI') as heure " +
                "FROM rdv " +
                "WHERE idmed::text = ? " +
                "AND DATE(date_rdv) = ? " +
                "AND statut = 'CONFIRME' " +
                (idRdvExclu != null ? "AND idrdv::text != ?" : "");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, idmed);
            ps.setDate(2, java.sql.Date.valueOf(date));
            if (idRdvExclu != null) ps.setString(3, idRdvExclu);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    heures.add(rs.getString("heure"));
                }
            }

        } catch (SQLException e) {
            System.err.println("[RdvDAO] Erreur listerHeuresPrisesParDate : " + e.getMessage());
        }
        return heures;
    }

    // ── TOP 5 PATIENTS LES PLUS ACTIFS (NOUVELLE MÉTHODE) ─────────────────────
    /**
     * Récupère le top 5 des patients ayant le plus de rendez-vous confirmés
     * Retourne une liste d'Object[] contenant : [idpat, nom_pat, email, nb_rdv]
     */
    public List<Object[]> top5PlusActifs() {
        List<Object[]> liste = new ArrayList<>();
        String sql = "SELECT p.idpat, p.nom_pat, p.email, COUNT(r.idrdv) as nb_rdv " +
                "FROM patient p " +
                "INNER JOIN rdv r ON p.idpat = r.idpat " +
                "WHERE r.statut = 'CONFIRME' " +
                "GROUP BY p.idpat, p.nom_pat, p.email " +
                "ORDER BY nb_rdv DESC " +
                "LIMIT 5";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Object[] patient = new Object[4];
                patient[0] = rs.getString("idpat");
                patient[1] = rs.getString("nom_pat");
                patient[2] = rs.getString("email");
                patient[3] = rs.getInt("nb_rdv");
                liste.add(patient);
            }

        } catch (SQLException e) {
            System.err.println("[RdvDAO] Erreur top5PlusActifs : " + e.getMessage());
            e.printStackTrace();
        }
        return liste;
    }
}