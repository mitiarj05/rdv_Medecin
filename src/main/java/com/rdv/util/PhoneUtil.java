package com.rdv.util;

/**
 * Utilitaire pour la normalisation des numéros de téléphone
 * Convertit tous les formats en format international (+261...)
 */
public class PhoneUtil {

    /**
     * Normalise un numéro de téléphone au format international (+261...)
     * Exemples:
     * - 0328725411 -> +261328725411
     * - +261328725411 -> +261328725411
     * - 328725411 -> +261328725411
     * - 0330000000 -> +261330000000
     * 
     * @param phone Numéro à normaliser
     * @return Numéro normalisé au format +261XXXXXXXXX, ou null si invalide
     */
    public static String normaliserTelephone(String phone) {
        if (phone == null || phone.trim().isEmpty()) {
            return null;
        }
        
        // Supprimer les espaces, tirets et points
        String cleaned = phone.trim().replaceAll("[\\s\\-\\.]", "");
        
        // Si déjà au format international +261...
        if (cleaned.startsWith("+261")) {
            // Vérifier la longueur (après +261, 9 chiffres)
            if (cleaned.length() == 13) {
                return cleaned;
            }
            return null;
        }
        
        // Si commence par 0 (format local malgache)
        if (cleaned.startsWith("0") && cleaned.length() == 10) {
            // Remplacer le 0 par +261
            return "+261" + cleaned.substring(1);
        }
        
        // Si commence par 3 (sans le 0)
        if (cleaned.startsWith("3") && cleaned.length() == 9) {
            return "+261" + cleaned;
        }
        
        // Format invalide
        return null;
    }
    
    /**
     * Compare deux numéros de téléphone en ignorant le format
     * @param phone1 Premier numéro
     * @param phone2 Deuxième numéro
     * @return true si les numéros sont équivalents, false sinon
     */
    public static boolean sontEgaux(String phone1, String phone2) {
        String normalized1 = normaliserTelephone(phone1);
        String normalized2 = normaliserTelephone(phone2);
        
        if (normalized1 == null || normalized2 == null) {
            return false;
        }
        
        return normalized1.equals(normalized2);
    }
}