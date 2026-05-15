package com.rdv.servlet;

import java.io.IOException;
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
        html.append("</style>");
        html.append("</head><body>");
        
        html.append("<h1>🔧 Diagnostic Email - RDV Medical</h1>");
        
        // 1. Vérifier les variables d'environnement Mailjet
        html.append("<h2>1. Variables d'environnement Mailjet</h2>");
        
        String mailjetApiKey = System.getenv("MAILJET_API_KEY");
        String mailjetSecretKey = System.getenv("MAILJET_SECRET_KEY");
        String mailUsername = System.getenv("MAIL_USERNAME");
        
        html.append("<table>");
        html.append("<tr><th>Variable</th><th>Statut</th><th>Valeur</th></tr>");
        
        // MAILJET_API_KEY
        if (mailjetApiKey != null && !mailjetApiKey.isEmpty()) {
            html.append("<tr><td>MAILJET_API_KEY</td><td class='ok'>✅ OK</td><td>").append(mailjetApiKey.substring(0, 10)).append("...").append("</td></tr>");
        } else {
            html.append("<tr><td>MAILJET_API_KEY</td><td class='error'>❌ MANQUANTE</td><td>-</td></tr>");
        }
        
        // MAILJET_SECRET_KEY
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
                    // Construire la requête JSON pour Mailjet
                    String jsonPayload = String.format("""
                        {
                            "Messages": [
                                {
                                    "From": {
                                        "Email": "noreply@rdv-medical.com",
                                        "Name": "RDV Medical"
                                    },
                                    "To": [
                                        {
                                            "Email": "%s",
                                            "Name": "Test"
                                        }
                                    ],
                                    "Subject": "✅ Test RDV Medical - Mailjet fonctionne !",
                                    "HTMLPart": "<html><body style='font-family:Arial'>" +
                                        "<h2 style='color:#1a73e8;'>🏥 RDV Medical</h2>" +
                                        "<h3 style='color:#34a853;'>✅ Test réussi !</h3>" +
                                        "<p>Mailjet est correctement configuré sur Render.</p>" +
                                        "<p>Date du test : %s</p>" +
                                        "<hr>" +
                                        "<p style='color:#999;font-size:12px;'>RDV Medical - Plateforme de rendez-vous médicaux</p>" +
                                        "</body></html>"
                                    }
                                }
                            ]
                        }
                        """, 
                        testEmail,
                        new java.util.Date().toString()
                    );
                    
                    // Connexion à l'API Mailjet
                    URL url = new URL("https://api.mailjet.com/v3.1/send");
                    HttpURLConnection conn = (HttpURLConnection) url.openConnection();
                    conn.setRequestMethod("POST");
                    conn.setRequestProperty("Content-Type", "application/json");
                    
                    String auth = mailjetApiKey + ":" + mailjetSecretKey;
                    String encodedAuth = Base64.getEncoder().encodeToString(auth.getBytes(StandardCharsets.UTF_8));
                    conn.setRequestProperty("Authorization", "Basic " + encodedAuth);
                    conn.setDoOutput(true);
                    
                    // Envoyer la requête
                    try (OutputStream os = conn.getOutputStream()) {
                        byte[] input = jsonPayload.getBytes(StandardCharsets.UTF_8);
                        os.write(input, 0, input.length);
                    }
                    
                    int responseCode = conn.getResponseCode();
                    
                    html.append("<table>");
                    html.append("<tr><th>Étape</th><th>Résultat</th></tr>");
                    html.append("<tr><td>Connexion à Mailjet</td><td>✅ Connecté</td></tr>");
                    html.append("<tr><td>Envoi de l'email</td>");
                    
                    if (responseCode == 200 || responseCode == 201) {
                        html.append("<td class='ok'>✅ Succès ! Email envoyé à ").append(testEmail).append("</td></tr>");
                        html.append("<tr><td>Code réponse</td><td>").append(responseCode).append("</td></tr>");
                    } else {
                        html.append("<td class='error'>❌ Échec ! Code: ").append(responseCode).append("</td></tr>");
                    }
                    html.append("</table>");
                    
                    if (responseCode == 200 || responseCode == 201) {
                        html.append("<div class='ok'>✅ Vérifiez votre boîte mail (pensez à regarder les spams !)</div>");
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
        html.append("<li>✅ Utilisez Mailjet (pas Gmail) sur Render</li>");
        html.append("<li>📧 Vérifiez vos spams si vous ne recevez pas les emails</li>");
        html.append("<li>🔑 Les clés API doivent être correctes et sans espaces</li>");
        html.append("</ul>");
        html.append("</div>");
        
        html.append("<hr>");
        html.append("<a href='/' style='color:#1a73e8;'>← Retour à l'accueil</a>");
        html.append("</body></html>");
        
        resp.getWriter().write(html.toString());
    }
}