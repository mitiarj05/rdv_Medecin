package com.rdv.util;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Properties;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

/**
 * Gestionnaire de connexion à PostgreSQL via HikariCP (pool de connexions).
 * Utilise le pattern Singleton : une seule instance du pool pour toute l'appli.
 */
public class DBConnection {

    private static HikariDataSource dataSource;
    private static boolean initialized = false;

    // Constructeur privé : on ne peut pas instancier cette classe
    private DBConnection() {}

    /**
     * Initialise le pool de connexions au démarrage de l'application.
     * Priorité aux variables d'environnement (Render), puis fichier db.properties.
     */
    public static void init() {
        if (initialized) {
            System.out.println("[DBConnection] Pool déjà initialisé.");
            return;
        }

        try {
            HikariConfig config = new HikariConfig();
            
            // 🔥 PRIORITÉ AUX VARIABLES D'ENVIRONNEMENT (Render)
            String dbUrl = System.getenv("DB_URL");
            String dbUsername = System.getenv("DB_USERNAME");
            String dbPassword = System.getenv("DB_PASSWORD");
            
            System.out.println("[DBConnection] DB_URL from env: " + (dbUrl != null ? "✓ trouvé" : "✗ non trouvé"));
            System.out.println("[DBConnection] DB_USERNAME from env: " + (dbUsername != null ? "✓ trouvé" : "✗ non trouvé"));
            
            if (dbUrl != null && dbUsername != null && dbPassword != null) {
                config.setJdbcUrl(dbUrl);
                config.setUsername(dbUsername);
                config.setPassword(dbPassword);
                System.out.println("[DBConnection] ✅ Utilisation des variables d'environnement Render");
            } else {
                // Fallback sur db.properties pour le développement local
                System.out.println("[DBConnection] Variables d'env non trouvées, lecture de db.properties...");
                Properties props = new Properties();
                InputStream input = DBConnection.class
                        .getClassLoader()
                        .getResourceAsStream("db.properties");

                if (input == null) {
                    throw new RuntimeException("Fichier db.properties introuvable et variables d'environnement non définies !");
                }
                props.load(input);
                
                config.setJdbcUrl(props.getProperty("db.url"));
                config.setUsername(props.getProperty("db.username"));
                config.setPassword(props.getProperty("db.password"));
                System.out.println("[DBConnection] Utilisation du fichier db.properties (mode développement)");
            }

            // Paramètres du pool
            config.setMaximumPoolSize(10);
            config.setMinimumIdle(2);
            config.setConnectionTimeout(30000);
            config.setIdleTimeout(600000);
            config.setMaxLifetime(1800000);
            config.setPoolName("RdvMedicalPool");
            config.setDriverClassName("org.postgresql.Driver");

            // Paramètres supplémentaires pour PostgreSQL
            config.addDataSourceProperty("prepareThreshold", "0");
            config.addDataSourceProperty("preparedStatementCacheQueries", "0");
            config.addDataSourceProperty("preparedStatementCacheSizeMiB", "0");

            dataSource = new HikariDataSource(config);
            initialized = true;
            System.out.println("[DBConnection] ✅ Pool PostgreSQL initialisé avec succès.");

        } catch (IOException e) {
            throw new RuntimeException("Erreur lecture db.properties : " + e.getMessage(), e);
        }
    }

    /**
     * Retourne une connexion depuis le pool.
     * À utiliser dans un try-with-resources pour la refermer automatiquement.
     */
    public static Connection getConnection() throws SQLException {
        if (dataSource == null || !initialized) {
            System.err.println("[DBConnection] Pool non initialisé, tentative d'initialisation...");
            init();
        }

        if (dataSource == null) {
            throw new SQLException("Le pool de connexions n'a pas pu être initialisé.");
        }

        try {
            Connection conn = dataSource.getConnection();
            System.out.println("[DBConnection] Connexion PostgreSQL obtenue avec succès.");
            return conn;
        } catch (SQLException e) {
            System.err.println("[DBConnection] Erreur lors de l'obtention de la connexion : " + e.getMessage());
            throw e;
        }
    }

    /**
     * Ferme le pool proprement à l'arrêt de l'application.
     */
    public static void close() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
            initialized = false;
            System.out.println("[DBConnection] Pool PostgreSQL fermé.");
        }
    }

    /**
     * Vérifie si le pool est initialisé et fonctionnel
     */
    public static boolean testConnection() {
        try (Connection conn = getConnection()) {
            return conn != null && !conn.isClosed();
        } catch (SQLException e) {
            System.err.println("[DBConnection] Test de connexion échoué : " + e.getMessage());
            return false;
        }
    }
}
