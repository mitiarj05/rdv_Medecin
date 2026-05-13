package com.rdv.util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import org.mindrot.jbcrypt.BCrypt;

import jakarta.servlet.ServletContextEvent;
import jakarta.servlet.ServletContextListener;
import jakarta.servlet.annotation.WebListener;

@WebListener
public class AppListener implements ServletContextListener {

    @Override
    public void contextInitialized(ServletContextEvent sce) {
        System.out.println("[AppListener] Démarrage de l'application RDV Medical...");
        DBConnection.init();

        // Créer le compte admin par défaut au démarrage
        creerAdminParDefaut();

        System.out.println("[AppListener] Application prête.");
    }

    private void creerAdminParDefaut() {
        // Générer le hash du mot de passe "admin123" directement dans le code
        String motDePasseAdmin = "admin123";
        String adminHash = BCrypt.hashpw(motDePasseAdmin, BCrypt.gensalt(12));

        String checkSql = "SELECT COUNT(*) FROM medecin WHERE email = 'admin@rdv.com'";
        String insertSql = "INSERT INTO medecin (idmed, nommed, specialite, taux_horaire, lieu, email, mot_de_passe) " +
                "VALUES (uuid_generate_v4(), ?, 'ADMINISTRATEUR', 1, 'Système', ?, ?)";
        //                                                          ↑ TAUX_HORAIRE = 1 (respecte CHECK > 0)

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {

            ResultSet rs = checkStmt.executeQuery();
            if (rs.next() && rs.getInt(1) == 0) {
                try (PreparedStatement insertStmt = conn.prepareStatement(insertSql)) {
                    insertStmt.setString(1, "Administrateur");
                    insertStmt.setString(2, "admin@rdv.com");
                    insertStmt.setString(3, adminHash);
                    insertStmt.executeUpdate();
                    System.out.println("========================================");
                    System.out.println("✅ Compte ADMIN créé avec succès !");
                    System.out.println("   📧 Email: admin@rdv.com");
                    System.out.println("   🔑 Mot de passe: " + motDePasseAdmin);
                    System.out.println("========================================");
                }
            } else {
                System.out.println("ℹ️ Compte ADMIN déjà existant.");
            }

        } catch (SQLException e) {
            System.err.println("❌ Erreur création admin: " + e.getMessage());
            e.printStackTrace();
        }
    }

    @Override
    public void contextDestroyed(ServletContextEvent sce) {
        System.out.println("[AppListener] Arrêt de l'application...");
        DBConnection.close();
    }
}