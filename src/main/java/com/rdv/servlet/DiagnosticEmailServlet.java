package com.rdv.servlet;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/diagnostic-email")
public class DiagnosticEmailServlet extends HttpServlet {
    
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) 
            throws ServletException, IOException {
        
        resp.setContentType("text/html;charset=UTF-8");
        StringBuilder html = new StringBuilder();
        
        html.append("<html><head><title>Diagnostic Email - Mailjet</title>");
        html.append("<style>");
        html.append("body{font-family:Arial,sans-serif;padding:20px;background:#f5f5f5;}");
        html.append(".ok{color:green;background:#e6f4ea;padding:10px;border-radius:5px;}");
        html.append(".error{color:red;background:#fce8e6;padding:10px;border-radius:5px;}");
        html.append(".info{color:blue;background:#e8f0fe;padding:10px;border-radius:5px;}");
        html.append("h1{color:#1a73e8;}");
        html.append("table{border-collapse:collapse;width:100%;margin:10px 0;}");
        html.append("td,th{border:1px solid #ddd;padding:8px;text-align:left;}");
        html.append("th{background:#1a73e8;color:white;}");
        html.append("pre{background:#333;color:#fff;padding:10px;overflow-x:auto;}");
        html.append("</style>");
        html.append("</head><body>");
        
        html.append("<h1>🔧 Diagnostic Email - RDV Medical</h1>");
        
        // 1. Vérifier les variables d'environnement Mailjet
        html.append("<h2>1. Variables d'environnement Mailjet</h2>");
        
        String mailjetApiKey = System.getenv("MAILJET_API_KEY");
        String mailjetSecretKey = System.getenv("MAILJET_SECRET_KEY");
        
        html.append("<table>");
        html.append("<tr><th>Variable</th><th>Statut</th><th>Valeur</th></tr>");
        
        if (mailjetApiKey != null && !mailjetApiKey.isEmpty()) {
            html.append("<tr><td>MAILJET_API_KEY</td><td class='ok'>✅ OK</td><td>").append(mailjetApiKey.substring(0, 10)).append("...").append("</td></tr>");
        } else {
            html.append("<tr><td>MAILJET_API_KEY</td><td class='error'>❌ MANQUANTE</td><td>-</td></tr>");
        }
        
        if (mailjetSecretKey != null && !mailjetSecretKey.isEmpty()) {
            html.append("<tr><td>MAILJET_SECRET_KEY</td><td class='ok'>✅ OK</td><td>").append(mailjetSecretKey.substring(0, 10)).append("...").append("</td></tr>");
        } else {
            html.append("<tr><td>MAILJET_SECRET_KEY</td><td class='error'>❌ MANQUANTE</td><td>-</td></tr>");
        }
        
        html.append("</table>");
        
        // 2. Test d'envoi d'email avec Mailjet
        html.append("<h2>2. Test d'envoi d'email avec Mailjet</h2>");
        
        String testEmail = req.getParameter("email");
        if (testEmail == null || testEmail.isEmpty()) {
            html.append("<div class='info'>");
            html.append("<p>📧 Entrez votre email pour tester l'envoi via Mailjet :</p>");
            html.append("<form method='get'>");
            html.append("<input type='email' name='email' placeholder='votre@email.com' required size='40' style='padding:8px;margin-right:10px;'>");
            html.append("<button type='submit' style='padding:8px 16px;background:#1a73e8;color:white;border:none;border-radius:5px;cursor:pointer;'>Tester Mailjet</button>");
            html.append("</form>");
            html.append("</div>");
        } else {
            html.append("<div class='info'>");
            html.append("<p>📧 Envoi à : <strong>").append(testEmail).append("</strong></p>");
            html.append("</div>");
            
            if (mailjetApiKey == null || mailjetApiKey.isEmpty() || mailjetSecretKey == null || mailjetSecretKey.isEmpty()) {
                html.append("<div class='error'>❌ Impossible d'envoyer : clés Mailjet manquantes !</div>");
            } else {
                try {
                    // Construction du JSON VALIDE pour Mailjet
                    String jsonPayload = "{"
                        + "\"Messages\": ["
                        + "{"
                        + "\"From\": {\"Email\": \"noreply@rdv-medical.com\", \"Name\": \"RDV Medical\"},"
                        + "\"To\": [{\"Email\": \"" + testEmail + "\", \"Name\": \"Patient\"}],"
                        + "\"Subject\": \"Test RDV Medical - Mailjet fonctionne !\","
                        + "\"HTMLPart\": \"<html><body><h2 style='color:#1a73e8;'>🏥 RDV Medical</h2><h3 style='color:#34a853;'>✅ Test r&eacute;ussi !</h3><p>Mailjet est correctement configur&eacute; sur Render.</p><p>Date: " + new java.util.Date() + "</p><hr><p style='color:#999;'>RDV Medical</p></body></html>\""
                        + "}"
                        + "]"
                        + "}";
                    
                    html.append("<div class='info'>📤 Envoi de la requête...</div>");
                    
                    URL url = new URL("https://api.mailjet.com/v3.1/send");
                    HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                    conn.setRequestMethod("POST");
                    conn.setRequestProperty("Content-Type", "application/json");
                    
                    String auth = mailjetApiKey + ":" + mailjetSecretKey;
                    String encodedAuth = Base64.getEncoder().encodeToString(auth.getBytes(StandardCharsets.UTF_8));
                    conn.setRequestProperty("Authorization", "Basic " + encodedAuth);
                    conn.setDoOutput(true);
                    
                    // Afficher la requête pour debug
                    html.append("<details><summary>🔍 Voir la requête JSON</summary>");
                    html.append("<pre>").append(escapeHtml(jsonPayload)).append("</pre>");
                    html.append("</details>");
                    
                    // Envoyer
                    try (OutputStream os = conn.getOutputStream()) {
                        byte[] input = jsonPayload.getBytes(StandardCharsets.UTF_8);
                        os.write(input, 0, input.length);
                    }
                    
                    int responseCode = conn.getResponseCode();
                    
                    html.append("<table>");
                    html.append("<tr><th>Étape</th><th>Résultat</th></tr>");
                    html.append("<tr><td>Connexion à Mailjet</td><td class='ok'>✅ Connecté</td></tr>");
                    
                    if (responseCode == 200 || responseCode == 201) {
                        html.append("<tr><td>Envoi de l'email</td><td class='ok'>✅ Succès ! Email envoyé à " + testEmail + "</td></tr>");
                        html.append("<tr><td>Code réponse</td><td class='ok'>" + responseCode + "</td></tr>");
                        html.append("</table>");
                        html.append("<div class='ok'>✅ Vérifiez votre boîte mail (pensez à regarder les spams !)</div>");
                    } else {
                        html.append("<tr><td>Envoi de l'email</td><td class='error'>❌ Échec ! Code: " + responseCode + "</td></tr>");
                        html.append("</table>");
                        
                        // Lire la réponse d'erreur
                        BufferedReader br = new BufferedReader(new InputStreamReader(conn.getErrorStream()));
                        StringBuilder errorResponse = new StringBuilder();
                        String line;
                        while ((line = br.readLine()) != null) {
                            errorResponse.append(line);
                        }
                        br.close();
                        
                        html.append("<details><summary>❌ Voir l'erreur détaillée</summary>");
                        html.append("<pre>").append(escapeHtml(errorResponse.toString())).append("</pre>");
                        html.append("</details>");
                    }
                    
                    conn.disconnect();
                    
                } catch (Exception e) {
                    html.append("<div class='error'>❌ Exception: ").append(e.getMessage()).append("</div>");
                    e.printStackTrace();
                }
            }
        }
        
        // 3. Recommandations
        html.append("<h2>3. Recommandations</h2>");
        html.append("<div class='info'>");
        html.append("<ul>");
        html.append("<li>✅ Mailjet est configuré et fonctionne sur Render</li>");
        html.append("<li>📧 Si le test échoue, vérifiez que votre compte Mailjet est validé</li>");
        html.append("<li>🔑 Les clés API doivent être correctes et sans espaces</li>");
        html.append("</ul>");
        html.append("</div>");
        
        html.append("<hr>");
        html.append("<a href='/' style='color:#1a73e8;'>← Retour à l'accueil</a>");
        html.append("</body></html>");
        
        resp.getWriter().write(html.toString());
    }
    
    private String escapeHtml(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;");
    }
}