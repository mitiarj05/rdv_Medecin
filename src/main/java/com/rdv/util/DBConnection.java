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

    private DBConnection() {}

    /**
     * Convertit une URL PostgreSQL native (format Render) en URL JDBC.
     * Ex: postgres://user:pass@host:5432/db -> jdbc:postgresql://host:5432/db
     */
    private static String convertToJdbcUrl(String dbUrl) {
        if (dbUrl == null) return null;

        // Déjà au format JDBC, rien à faire
        if (dbUrl.startsWith("jdbc:")) {
            return dbUrl;
        }

        // Format Render : postgres://user:password@host:port/dbname
        // ou postgresql://user:password@host:port/dbname
        if (dbUrl.startsWith("postgres://") || dbUrl.startsWith("postgresql://")) {
            // Remplacer le préfixe par jdbc:postgresql://
            String jdbc = dbUrl
                    .replace("postgres://", "jdbc:postgresql://")
                    .replace("postgresql://", "jdbc:postgresql://");

            // Render ajoute parfois ?sslmode=require en query string, on le garde
            // mais HikariCP a besoin du sslmode en propriété séparée si SSL requis
            if (!jdbc.contains("sslmode")) {
                jdbc = jdbc + (jdbc.contains("?") ? "&" : "?") + "sslmode=require";
            }

            System.out.println("[DBConnection] URL convertie en JDBC : " + jdbc.replaceAll(":[^@/]+@", ":***@"));
            return jdbc;
        }

        return dbUrl;
    }

    /**
     * Extrait le username depuis une URL postgres://user:pass@host/db
     */
    private static String extractUsernameFromUrl(String dbUrl) {
        try {
            // postgres://USER:pass@host:port/db
            String withoutPrefix = dbUrl.replace("postgres://", "").replace("postgresql://", "");
            String userInfo = withoutPrefix.split("@")[0]; // USER:pass
            return userInfo.split(":")[0]; // USER
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Extrait le password depuis une URL postgres://user:pass@host/db
     */
    private static String extractPasswordFromUrl(String dbUrl) {
        try {
            String withoutPrefix = dbUrl.replace("postgres://", "").replace("postgresql://", "");
            String userInfo = withoutPrefix.split("@")[0]; // user:PASS
            return userInfo.split(":")[1]; // PASS
        } catch (Exception e) {
            return null;
        }
    }

    /**
     * Initialise le pool de connexions.
     * Priorité aux variables d'environnement (Render), puis fichier db.properties.
     */
    public static void init() {
        if (initialized) {
            System.out.println("[DBConnection] Pool déjà initialisé.");
            return;
        }

        try {
            HikariConfig config = new HikariConfig();

            // Variables d'environnement Render
            String dbUrl      = System.getenv("DB_URL");
            String dbUsername = System.getenv("DB_USERNAME");
            String dbPassword = System.getenv("DB_PASSWORD");

            System.out.println("[DBConnection] DB_URL     : " + (dbUrl      != null ? "✓ trouvé" : "✗ absent"));
            System.out.println("[DBConnection] DB_USERNAME: " + (dbUsername != null ? "✓ trouvé" : "✗ absent"));
            System.out.println("[DBConnection] DB_PASSWORD: " + (dbPassword != null ? "✓ trouvé" : "✗ absent"));

            if (dbUrl != null) {
                // Render fournit parfois seulement DB_URL avec user/pass intégrés
                // On extrait user/pass depuis l'URL si les variables séparées sont absentes
                if (dbUsername == null) {
                    dbUsername = extractUsernameFromUrl(dbUrl);
                    System.out.println("[DBConnection] Username extrait depuis DB_URL: " + dbUsername);
                }
                if (dbPassword == null) {
                    dbPassword = extractPasswordFromUrl(dbUrl);
                    System.out.println("[DBConnection] Password extrait depuis DB_URL: [masqué]");
                }

                // Convertir en JDBC si nécessaire
                String jdbcUrl = convertToJdbcUrl(dbUrl);
                config.setJdbcUrl(jdbcUrl);
                config.setUsername(dbUsername);
                config.setPassword(dbPassword);
                System.out.println("[DBConnection] ✅ Configuration depuis les variables d'environnement Render");

            } else {
                // Fallback local : fichier db.properties
                System.out.println("[DBConnection] Lecture de db.properties (mode développement)...");
                Properties props = new Properties();
                InputStream input = DBConnection.class
                        .getClassLoader()
                        .getResourceAsStream("db.properties");

                if (input == null) {
                    throw new RuntimeException("db.properties introuvable et DB_URL non défini !");
                }
                props.load(input);

                config.setJdbcUrl(props.getProperty("db.url"));
                config.setUsername(props.getProperty("db.username"));
                config.setPassword(props.getProperty("db.password"));
                System.out.println("[DBConnection] ✅ Configuration depuis db.properties");
            }

            // Paramètres du pool
            config.setMaximumPoolSize(5);   // Free tier Render : limité à 5 connexions max
            config.setMinimumIdle(1);
            config.setConnectionTimeout(30000);
            config.setIdleTimeout(600000);
            config.setMaxLifetime(1800000);
            config.setPoolName("RdvMedicalPool");
            config.setDriverClassName("org.postgresql.Driver");

            // Test de connexion au démarrage
            config.setConnectionTestQuery("SELECT 1");

            dataSource = new HikariDataSource(config);
            initialized = true;
            System.out.println("[DBConnection] ✅ Pool PostgreSQL initialisé avec succès.");

        } catch (IOException e) {
            throw new RuntimeException("Erreur lecture db.properties : " + e.getMessage(), e);
        }
    }

    /**
     * Retourne une connexion depuis le pool.
     */
    public static Connection getConnection() throws SQLException {
        if (dataSource == null || !initialized) {
            System.err.println("[DBConnection] Pool non initialisé, tentative d'initialisation...");
            init();
        }

        if (dataSource == null) {
            throw new SQLException("Le pool de connexions n'a pas pu être initialisé.");
        }

        return dataSource.getConnection();
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
     * Vérifie si le pool est fonctionnel.
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