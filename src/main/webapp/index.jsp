<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>RDV Medical</title>
    <style>
        body { font-family: Arial, sans-serif; text-align: center; padding: 50px; }
        .btn { display: inline-block; padding: 10px 20px; margin: 10px; background: #1a73e8; color: white; text-decoration: none; border-radius: 5px; }
        .btn:hover { background: #0d47a1; }
    </style>
</head>
<body>
    <h1>🏥 RDV Medical</h1>
    <p>Système de gestion de rendez-vous médicaux</p>
    
    <a href="${pageContext.request.contextPath}/views/shared/login.jsp" class="btn">🔐 Connexion</a>
    <a href="${pageContext.request.contextPath}/views/shared/register.jsp" class="btn">📝 Inscription</a>
    
    <hr>
    <p style="color: #666; font-size: 12px;">Application déployée avec succès sur Render !</p>
</body>
</html>