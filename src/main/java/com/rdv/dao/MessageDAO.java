package com.rdv.dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import com.rdv.model.Message;
import com.rdv.util.DBConnection;

public class MessageDAO {

    // Envoyer un message avec pièce jointe
    public boolean envoyer(Message message) {
        String sql = "INSERT INTO message (id_message, id_expediteur, type_expediteur, " +
                     "id_destinataire, type_destinataire, contenu, date_envoi, piece_jointe, type_piece) " +
                     "VALUES (uuid_generate_v4(), ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, message.getIdExpediteur());
            ps.setString(2, message.getTypeExpediteur());
            ps.setString(3, message.getIdDestinataire());
            ps.setString(4, message.getTypeDestinataire());
            ps.setString(5, message.getContenu());
            ps.setTimestamp(6, Timestamp.valueOf(message.getDateEnvoi()));
            ps.setString(7, message.getPieceJointe());
            ps.setString(8, message.getTypePiece());
            
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            System.err.println("[MessageDAO] Erreur envoyer: " + e.getMessage());
            return false;
        }
    }
    
    // Récupérer la conversation entre deux personnes
    public List<Message> getConversation(String idUser1, String typeUser1, 
                                         String idUser2, String typeUser2) {
        List<Message> liste = new ArrayList<>();
        String sql = "SELECT * FROM message WHERE " +
                     "((id_expediteur = ? AND type_expediteur = ? AND id_destinataire = ? AND type_destinataire = ?) OR " +
                     "(id_expediteur = ? AND type_expediteur = ? AND id_destinataire = ? AND type_destinataire = ?)) " +
                     "AND supprime_expediteur = FALSE AND supprime_destinataire = FALSE " +
                     "ORDER BY date_envoi ASC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, idUser1);
            ps.setString(2, typeUser1);
            ps.setString(3, idUser2);
            ps.setString(4, typeUser2);
            ps.setString(5, idUser2);
            ps.setString(6, typeUser2);
            ps.setString(7, idUser1);
            ps.setString(8, typeUser1);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                liste.add(mapper(rs));
            }
        } catch (SQLException e) {
            System.err.println("[MessageDAO] Erreur getConversation: " + e.getMessage());
        }
        return liste;
    }
    
    // Récupérer tous les messages d'un utilisateur
    public List<Message> getMessagesPourUtilisateur(String idUtilisateur, String typeUtilisateur) {
        List<Message> liste = new ArrayList<>();
        String sql = "SELECT m.*, " +
                     "CASE WHEN m.type_expediteur = 'patient' THEN p.nom_pat ELSE med.nommed END as nom_exp, " +
                     "CASE WHEN m.type_destinataire = 'patient' THEN p2.nom_pat ELSE med2.nommed END as nom_dest " +
                     "FROM message m " +
                     "LEFT JOIN patient p ON m.id_expediteur = p.idpat AND m.type_expediteur = 'patient' " +
                     "LEFT JOIN medecin med ON m.id_expediteur = med.idmed AND m.type_expediteur = 'medecin' " +
                     "LEFT JOIN patient p2 ON m.id_destinataire = p2.idpat AND m.type_destinataire = 'patient' " +
                     "LEFT JOIN medecin med2 ON m.id_destinataire = med2.idmed AND m.type_destinataire = 'medecin' " +
                     "WHERE (m.id_destinataire = ? AND m.type_destinataire = ? AND m.supprime_destinataire = FALSE) " +
                     "OR (m.id_expediteur = ? AND m.type_expediteur = ? AND m.supprime_expediteur = FALSE) " +
                     "ORDER BY m.date_envoi DESC";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, idUtilisateur);
            ps.setString(2, typeUtilisateur);
            ps.setString(3, idUtilisateur);
            ps.setString(4, typeUtilisateur);
            
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Message m = mapper(rs);
                m.setNomExpediteur(rs.getString("nom_exp"));
                m.setNomDestinataire(rs.getString("nom_dest"));
                liste.add(m);
            }
        } catch (SQLException e) {
            System.err.println("[MessageDAO] Erreur getMessagesPourUtilisateur: " + e.getMessage());
        }
        return liste;
    }
    
    // Marquer un message comme lu
    public boolean marquerCommeLu(String idMessage) {
        String sql = "UPDATE message SET lu = TRUE, date_lu = ? WHERE id_message::text = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setTimestamp(1, Timestamp.valueOf(java.time.LocalDateTime.now()));
            ps.setString(2, idMessage);
            
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            System.err.println("[MessageDAO] Erreur marquerCommeLu: " + e.getMessage());
            return false;
        }
    }
    
    // Compter les messages non lus
    public int countNonLus(String idUtilisateur, String typeUtilisateur) {
        String sql = "SELECT COUNT(*) FROM message " +
                     "WHERE id_destinataire = ? AND type_destinataire = ? AND lu = FALSE AND supprime_destinataire = FALSE";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            
            ps.setString(1, idUtilisateur);
            ps.setString(2, typeUtilisateur);
            ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            System.err.println("[MessageDAO] Erreur countNonLus: " + e.getMessage());
        }
        return 0;
    }
    
    // Supprimer un message (soft delete)
    public boolean supprimerMessage(String idMessage, String idUtilisateur, String typeUtilisateur) {
        String sqlCheck = "SELECT id_expediteur, type_expediteur, id_destinataire, type_destinataire FROM message WHERE id_message::text = ?";
        String sqlUpdate = "";
        
        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(sqlCheck)) {
                ps.setString(1, idMessage);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    String idExp = rs.getString("id_expediteur");
                    String typeExp = rs.getString("type_expediteur");
                    String idDest = rs.getString("id_destinataire");
                    String typeDest = rs.getString("type_destinataire");
                    
                    if (idUtilisateur.equals(idExp) && typeUtilisateur.equals(typeExp)) {
                        sqlUpdate = "UPDATE message SET supprime_expediteur = TRUE WHERE id_message::text = ?";
                    } else if (idUtilisateur.equals(idDest) && typeUtilisateur.equals(typeDest)) {
                        sqlUpdate = "UPDATE message SET supprime_destinataire = TRUE WHERE id_message::text = ?";
                    } else {
                        return false;
                    }
                }
            }
            
            try (PreparedStatement ps = conn.prepareStatement(sqlUpdate)) {
                ps.setString(1, idMessage);
                return ps.executeUpdate() == 1;
            }
        } catch (SQLException e) {
            System.err.println("[MessageDAO] Erreur supprimerMessage: " + e.getMessage());
            return false;
        }
    }
    
    // Supprimer définitivement un message (hard delete)
    public boolean supprimerDefinitivement(String idMessage) {
        String sql = "DELETE FROM message WHERE id_message::text = ?";
        
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, idMessage);
            return ps.executeUpdate() == 1;
        } catch (SQLException e) {
            System.err.println("[MessageDAO] Erreur supprimerDefinitivement: " + e.getMessage());
            return false;
        }
    }
    
    private Message mapper(ResultSet rs) throws SQLException {
        Message m = new Message();
        m.setIdMessage(rs.getString("id_message"));
        m.setIdExpediteur(rs.getString("id_expediteur"));
        m.setTypeExpediteur(rs.getString("type_expediteur"));
        m.setIdDestinataire(rs.getString("id_destinataire"));
        m.setTypeDestinataire(rs.getString("type_destinataire"));
        m.setContenu(rs.getString("contenu"));
        
        Timestamp ts = rs.getTimestamp("date_envoi");
        if (ts != null) m.setDateEnvoi(ts.toLocalDateTime());
        
        m.setLu(rs.getBoolean("lu"));
        
        Timestamp tsLu = rs.getTimestamp("date_lu");
        if (tsLu != null) m.setDateLu(tsLu.toLocalDateTime());
        
        m.setSupprimeExpediteur(rs.getBoolean("supprime_expediteur"));
        m.setSupprimeDestinataire(rs.getBoolean("supprime_destinataire"));
        
        // NOUVEAUX CHAMPS
        m.setPieceJointe(rs.getString("piece_jointe"));
        m.setTypePiece(rs.getString("type_piece"));
        
        return m;
    }
}