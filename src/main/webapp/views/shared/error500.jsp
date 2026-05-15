<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Erreur serveur - RDV Medical</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', sans-serif;
            background: #f0f4f8;
            display: flex;
            align-items: center;
            justify-content: center;
            min-height: 100vh;
            color: #333;
        }
        .container {
            text-align: center;
            background: white;
            padding: 60px 80px;
            border-radius: 16px;
            box-shadow: 0 4px 24px rgba(0,0,0,0.08);
        }
        .code { font-size: 96px; font-weight: 700; color: #ef4444; line-height: 1; }
        h1 { font-size: 24px; margin: 16px 0 8px; color: #1e293b; }
        p { color: #64748b; margin-bottom: 32px; }
        a {
            display: inline-block;
            padding: 12px 28px;
            background: #3b82f6;
            color: white;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 500;
            transition: background 0.2s;
        }
        a:hover { background: #2563eb; }
    </style>
</head>
<body>
    <div class="container">
        <div class="code">500</div>
        <h1>Erreur interne du serveur</h1>
        <p>Une erreur inattendue s'est produite. Veuillez réessayer dans quelques instants.</p>
        <a href="${pageContext.request.contextPath}/">Retour à l'accueil</a>
    </div>
</body>
</html>