package com.rdv.util;

/**
 * Utilitaire pour la normalisation des numéros de téléphone
 */
public class PhoneUtil {

    public static String normaliserTelephone(String phone) {
        if (phone == null || phone.trim().isEmpty()) {
            return null;
        }
        
        String cleaned = phone.trim().replaceAll("[\\s\\-\\.]", "");
        
        if (cleaned.startsWith("+261")) {
            if (cleaned.length() == 13) {
                return cleaned;
            }
            return null;
        }
        
        if (cleaned.startsWith("0") && cleaned.length() == 10) {
            return "+261" + cleaned.substring(1);
        }
        
        if (cleaned.startsWith("3") && cleaned.length() == 9) {
            return "+261" + cleaned;
        }
        
        return null;
    }
    
    public static boolean sontEgaux(String phone1, String phone2) {
        String n1 = normaliserTelephone(phone1);
        String n2 = normaliserTelephone(phone2);
        if (n1 == null || n2 == null) return false;
        return n1.equals(n2);
    }
}