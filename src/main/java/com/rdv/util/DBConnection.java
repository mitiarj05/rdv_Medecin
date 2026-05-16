package com.rdv.util;

import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.Properties;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;

/**
 * Gestionnaire de connexion à PostgreSQL via HikariCP.
 * Fonctionne sur Render (variables d'env) ET en local (valeurs par défaut)
 */
public class DBConnection {

    private static HikariDataSource dataSource;
    private static boolean initialized = false;

    // Valeurs par défaut pour le développement local
    private static final String DEFAULT_URL = "jdbc:postgresql://localhost:5432/rdv_medical";
    private static final String DEFAULT_USERNAME = "postgres";
    private static final String DEFAULT_PASSWORD = "mitiarj";

    private DBConnection() {}

    public static void init() {
        if (initialized) {
            System.out.println("[DBConnection] Pool déjà initialisé.");
            return;
        }

        try {
            HikariConfig config = new HikariConfig();

            // 1. Essayer les variables d'environnement (Render)
            String dbUrl = System.getenv("DB_URL");
            String dbUsername = System.getenv("DB_USERNAME");
            String dbPassword = System.getenv("DB_PASSWORD");

            System.out.println("[DBConnection] ===========================================");
            System.out.println("[DBConnection] 🔍 RECHERCHE CONFIGURATION BASE DE DONNÉES");
            System.out.println("[DBConnection] DB_URL      : " + (dbUrl != null ? "✅ TROUVÉE (Render)" : "❌ NON TROUVÉE"));
            System.out.println("[DBConnection] DB_USERNAME : " + (dbUsername != null ? "✅ TROUVÉ" : "❌ NON TROUVÉ"));
            System.out.println("[DBConnection] DB_PASSWORD : " + (dbPassword != null ? "✅ TROUVÉ" : "❌ NON TROUVÉ"));

            String finalUrl;
            String finalUsername;
            String finalPassword;

            if (dbUrl != null && !dbUrl.isEmpty()) {
                // ==================== MODE RENDER ====================
                System.out.println("[DBConnection] 📡 MODE RENDER - Utilisation des variables d'environnement");

                if (dbUrl.startsWith("jdbc:postgresql://")) {
                    finalUrl = dbUrl;
                    if (!finalUrl.contains("sslmode")) {
                        finalUrl += (finalUrl.contains("?") ? "&" : "?") + "sslmode=require";
                    }
                } else {
                    // Format natif Render : postgres://user:pass@host:port/db
                    String normalized = dbUrl
                            .replace("postgres://", "http://")
                            .replace("postgresql://", "http://");
                    URI uri = new URI(normalized);
                    String host = uri.getHost();
                    int port = uri.getPort() != -1 ? uri.getPort() : 5432;
                    String dbName = uri.getPath().replaceFirst("/", "");
                    String userInfo = uri.getUserInfo();
                    
                    finalUrl = "jdbc:postgresql://" + host + ":" + port + "/" + dbName + "?sslmode=require";
                    
                    if (userInfo != null && !userInfo.isEmpty()) {
                        String[] parts = userInfo.split(":", 2);
                        if (dbUsername == null) dbUsername = parts[0];
                        if (dbPassword == null && parts.length > 1) dbPassword = parts[1];
                    }
                }
                finalUsername = dbUsername;
                finalPassword = dbPassword;
                
                System.out.println("[DBConnection] 📡 URL: " + finalUrl);
                System.out.println("[DBConnection] 📡 Utilisateur: " + finalUsername);

            } else {
                // ==================== MODE LOCAL ====================
                // 2. Essayer de lire db.properties
                System.out.println("[DBConnection] 💻 MODE LOCAL - Recherche de db.properties...");
                
                Properties props = new Properties();
                InputStream input = DBConnection.class
                        .getClassLoader()
                        .getResourceAsStream("db.properties");

                if (input != null) {
                    props.load(input);
                    finalUrl = props.getProperty("db.url");
                    finalUsername = props.getProperty("db.username");
                    finalPassword = props.getProperty("db.password");
                    System.out.println("[DBConnection] ✅ db.properties trouvé !");
                } else {
                    // 3. Utiliser les valeurs par défaut
                    System.out.println("[DBConnection] ⚠️ db.properties non trouvé, utilisation des valeurs par défaut");
                    finalUrl = DEFAULT_URL;
                    finalUsername = DEFAULT_USERNAME;
                    finalPassword = DEFAULT_PASSWORD;
                }
                
                System.out.println("[DBConnection] 💻 URL: " + finalUrl);
                System.out.println("[DBConnection] 💻 Utilisateur: " + finalUsername);
            }

            config.setJdbcUrl(finalUrl);
            config.setUsername(finalUsername);
            config.setPassword(finalPassword);
            config.setDriverClassName("org.postgresql.Driver");

            // Paramètres du pool
            config.setMaximumPoolSize(5);
            config.setMinimumIdle(1);
            config.setConnectionTimeout(30000);
            config.setIdleTimeout(600000);
            config.setMaxLifetime(1800000);
            config.setPoolName("RdvMedicalPool");
            config.setConnectionTestQuery("SELECT 1");

            dataSource = new HikariDataSource(config);
            initialized = true;
            System.out.println("[DBConnection] ✅ Pool PostgreSQL initialisé avec succès !");
            System.out.println("[DBConnection] ===========================================");

        } catch (IOException e) {
            throw new RuntimeException("Erreur lecture db.properties : " + e.getMessage(), e);
        } catch (Exception e) {
            throw new RuntimeException("Erreur initialisation pool : " + e.getMessage(), e);
        }
    }

    public static Connection getConnection() throws SQLException {
        if (dataSource == null || !initialized) {
            System.err.println("[DBConnection] Pool non initialisé, tentative...");
            init();
        }
        if (dataSource == null) {
            throw new SQLException("Le pool de connexions n'a pas pu être initialisé.");
        }
        return dataSource.getConnection();
    }

    public static void close() {
        if (dataSource != null && !dataSource.isClosed()) {
            dataSource.close();
            initialized = false;
            System.out.println("[DBConnection] Pool PostgreSQL fermé.");
        }
    }

    public static boolean testConnection() {
        try (Connection conn = getConnection()) {
            return conn != null && !conn.isClosed();
        } catch (SQLException e) {
            System.err.println("[DBConnection] Test échoué : " + e.getMessage());
            return false;
        }
    }
}