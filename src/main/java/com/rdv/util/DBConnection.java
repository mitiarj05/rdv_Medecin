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
 * Gère les URLs Render au format postgres://user:pass@host:port/db
 */
public class DBConnection {

    private static HikariDataSource dataSource;
    private static boolean initialized = false;

    private DBConnection() {}

    public static void init() {
        if (initialized) {
            System.out.println("[DBConnection] Pool déjà initialisé.");
            return;
        }

        try {
            HikariConfig config = new HikariConfig();

            String dbUrl      = System.getenv("DB_URL");
            String dbUsername = System.getenv("DB_USERNAME");
            String dbPassword = System.getenv("DB_PASSWORD");

            System.out.println("[DBConnection] DB_URL     : " + (dbUrl      != null ? "✓ trouvé" : "✗ absent"));
            System.out.println("[DBConnection] DB_USERNAME: " + (dbUsername != null ? "✓ trouvé" : "✗ absent"));
            System.out.println("[DBConnection] DB_PASSWORD: " + (dbPassword != null ? "✓ trouvé" : "✗ absent"));

            if (dbUrl != null) {
                String jdbcUrl;
                String username = dbUsername;
                String password = dbPassword;

                if (dbUrl.startsWith("jdbc:postgresql://")) {
                    // Déjà au format JDBC propre
                    jdbcUrl = dbUrl;
                    if (!jdbcUrl.contains("sslmode")) {
                        jdbcUrl += (jdbcUrl.contains("?") ? "&" : "?") + "sslmode=require";
                    }
                } else {
                    // Format natif Render : postgres://user:pass@host:port/db
                    String normalized = dbUrl
                            .replace("postgres://", "http://")
                            .replace("postgresql://", "http://");

                    URI uri = new URI(normalized);

                    String host   = uri.getHost();
                    int    port   = uri.getPort() != -1 ? uri.getPort() : 5432;
                    String dbName = uri.getPath().replaceFirst("/", "");
                    String userInfo = uri.getUserInfo(); // user:pass

                    // URL JDBC propre SANS credentials dedans
                    jdbcUrl = "jdbc:postgresql://" + host + ":" + port + "/" + dbName + "?sslmode=require";

                    // Extraire user/pass depuis l'URL si non fournis séparément
                    if (userInfo != null && !userInfo.isEmpty()) {
                        String[] parts = userInfo.split(":", 2);
                        if (username == null) username = parts[0];
                        if (password == null && parts.length > 1) password = parts[1];
                    }
                }

                System.out.println("[DBConnection] JDBC URL : " + jdbcUrl);
                System.out.println("[DBConnection] Username : " + username);

                config.setJdbcUrl(jdbcUrl);
                config.setUsername(username);
                config.setPassword(password);
                config.setDriverClassName("org.postgresql.Driver");

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
                config.setDriverClassName("org.postgresql.Driver");
                System.out.println("[DBConnection] ✅ Configuration depuis db.properties");
            }

            // Paramètres du pool (free tier Render : max 5 connexions)
            config.setMaximumPoolSize(5);
            config.setMinimumIdle(1);
            config.setConnectionTimeout(30000);
            config.setIdleTimeout(600000);
            config.setMaxLifetime(1800000);
            config.setPoolName("RdvMedicalPool");
            config.setConnectionTestQuery("SELECT 1");

            dataSource = new HikariDataSource(config);
            initialized = true;
            System.out.println("[DBConnection] ✅ Pool PostgreSQL initialisé avec succès.");

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