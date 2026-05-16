package com.rdv.util;

import java.util.Locale;
import java.util.ResourceBundle;

import jakarta.servlet.http.HttpSession;

public class LangueUtil {
    
    public static String getTexte(HttpSession session, String key) {
        String langue = "fr";
        
        if (session != null && session.getAttribute("langue") != null) {
            langue = (String) session.getAttribute("langue");
        }
        
        return getTexte(langue, key);
    }
    
    public static String getTexte(String langue, String key) {
        try {
            ResourceBundle bundle = ResourceBundle.getBundle(
                "com.rdv.i18n.messages",
                new Locale(langue)
            );
            return bundle.getString(key);
        } catch (Exception e) {
            return key;
        }
    }
}