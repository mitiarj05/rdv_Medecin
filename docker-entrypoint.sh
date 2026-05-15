#!/bin/bash
set -e

echo "=== Démarrage de rdv-medical ==="

# Attendre que PostgreSQL soit prêt (important sur Render)
if [ -n "$DB_URL" ]; then
    echo "Attente de la base de données..."

    # Extraire host et port depuis l'URL JDBC ou connectionString
    # Render fournit une connectionString PostgreSQL native (postgres://user:pass@host:port/db)
    # On attend juste quelques secondes pour la disponibilité
    sleep 5
    echo "Base de données supposée prête."
fi

echo "Lancement de Tomcat..."
exec catalina.sh run