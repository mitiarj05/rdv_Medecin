package com.rdv.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

import com.rdv.model.Avis;
import com.rdv.model.Medecin;
import com.rdv.model.Patient;
import com.rdv.util.DBConnection;

public class AvisDAO {

    // Créer un avis
    public boolean inserer(Avis avis) {
        String sql = "INSERT INTO avis (id_avis, id_patient, id_medecin, note, commentaire, date_avis) " +
                     "VALUES (uuid_generate_v4(), ?::uuid, ?::uuid, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, avis.getIdPatient());
            ps.setString(2, avis.getIdMedecin());
            ps.setInt(3, avis.getNote());
            ps.setString(4, avis.getCommentaire());
            ps.setTimestamp(5, Timestamp.valueOf(avis.getDateAvis()));
            
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            System.err.println("[AvisDAO] Erreur inserer: " + e.getMessage());
            return false;
        }
    }
    
    // Vérifier si un patient a déjà noté un médecin
    public boolean aDejaNote(String idPatient, String idMedecin) {
        String sql = "SELECT COUNT(*) FROM avis WHERE id_patient::text = ? AND id_medecin::text = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, idPatient);
            ps.setString(2, idMedecin);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            System.err.println("[AvisDAO] Erreur aDejaNote: " + e.getMessage());
        }
        return false;
    }
    
    // Récupérer l'avis d'un patient sur un médecin
    public Avis trouverParPatientEtMedecin(String idPatient, String idMedecin) {
        String sql = "SELECT * FROM avis WHERE id_patient::text = ? AND id_medecin::text = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, idPatient);
            ps.setString(2, idMedecin);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return mapper(rs);
            }
        } catch (SQLException e) {
            System.err.println("[AvisDAO] Erreur trouverParPatientEtMedecin: " + e.getMessage());
        }
        return null;
    }
    
    // Récupérer tous les avis d'un médecin
    public List<Avis> listerParMedecin(String idMedecin) {
        List<Avis> liste = new ArrayList<>();
        String sql = "SELECT a.*, p.nom_pat, p.email, p.telephone " +
                     "FROM avis a " +
                     "JOIN patient p ON a.id_patient = p.idpat " +
                     "WHERE a.id_medecin::text = ? " +
                     "ORDER BY a.date_avis DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, idMedecin);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Avis avis = mapper(rs);
                
                Patient p = new Patient();
                p.setIdpat(rs.getString("id_patient"));
                p.setNomPat(rs.getString("nom_pat"));
                p.setEmail(rs.getString("email"));
                p.setTelephone(rs.getString("telephone"));
                avis.setPatient(p);
                
                liste.add(avis);
            }
        } catch (SQLException e) {
            System.err.println("[AvisDAO] Erreur listerParMedecin: " + e.getMessage());
        }
        return liste;
    }
    
    // Récupérer les avis d'un patient
    public List<Avis> listerParPatient(String idPatient) {
        List<Avis> liste = new ArrayList<>();
        String sql = "SELECT a.*, m.nommed, m.specialite, m.lieu " +
                     "FROM avis a " +
                     "JOIN medecin m ON a.id_medecin = m.idmed " +
                     "WHERE a.id_patient::text = ? " +
                     "ORDER BY a.date_avis DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, idPatient);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Avis avis = mapper(rs);
                
                Medecin m = new Medecin();
                m.setIdmed(rs.getString("id_medecin"));
                m.setNommed(rs.getString("nommed"));
                m.setSpecialite(rs.getString("specialite"));
                m.setLieu(rs.getString("lieu"));
                avis.setMedecin(m);
                
                liste.add(avis);
            }
        } catch (SQLException e) {
            System.err.println("[AvisDAO] Erreur listerParPatient: " + e.getMessage());
        }
        return liste;
    }
    
    // Mettre à jour un avis
    public boolean modifier(Avis avis) {
        String sql = "UPDATE avis SET note = ?, commentaire = ? WHERE id_avis::text = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setInt(1, avis.getNote());
            ps.setString(2, avis.getCommentaire());
            ps.setString(3, avis.getIdAvis());
            
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            System.err.println("[AvisDAO] Erreur modifier: " + e.getMessage());
            return false;
        }
    }
    
    // Répondre à un avis (médecin)
    public boolean repondre(String idAvis, String reponse) {
        String sql = "UPDATE avis SET reponse_medecin = ?, date_reponse = ? WHERE id_avis::text = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, reponse);
            ps.setTimestamp(2, Timestamp.valueOf(java.time.LocalDateTime.now()));
            ps.setString(3, idAvis);
            
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            System.err.println("[AvisDAO] Erreur repondre: " + e.getMessage());
            return false;
        }
    }
    
    // Supprimer un avis
    public boolean supprimer(String idAvis) {
        String sql = "DELETE FROM avis WHERE id_avis::text = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, idAvis);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            System.err.println("[AvisDAO] Erreur supprimer: " + e.getMessage());
            return false;
        }
    }
    
    // Calculer la note moyenne d'un médecin
    public double getNoteMoyenne(String idMedecin) {
        String sql = "SELECT AVG(note) as moyenne FROM avis WHERE id_medecin::text = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, idMedecin);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getDouble("moyenne");
            }
        } catch (SQLException e) {
            System.err.println("[AvisDAO] Erreur getNoteMoyenne: " + e.getMessage());
        }
        return 0;
    }
    
    // Compter le nombre d'avis pour un médecin
    public int countByMedecin(String idMedecin) {
        String sql = "SELECT COUNT(*) FROM avis WHERE id_medecin::text = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, idMedecin);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("[AvisDAO] Erreur countByMedecin: " + e.getMessage());
        }
        return 0;
    }
    
    private Avis mapper(ResultSet rs) throws SQLException {
        Avis a = new Avis();
        a.setIdAvis(rs.getString("id_avis"));
        a.setIdPatient(rs.getString("id_patient"));
        a.setIdMedecin(rs.getString("id_medecin"));
        a.setNote(rs.getInt("note"));
        a.setCommentaire(rs.getString("commentaire"));
        
        Timestamp tsDate = rs.getTimestamp("date_avis");
        if (tsDate != null) a.setDateAvis(tsDate.toLocalDateTime());
        
        a.setReponseMedecin(rs.getString("reponse_medecin"));
        
        Timestamp tsReponse = rs.getTimestamp("date_reponse");
        if (tsReponse != null) a.setDateReponse(tsReponse.toLocalDateTime());
        
        return a;
    }
}