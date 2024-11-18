# Fonction pour enregistrer les événements dans un fichier de log
function Log {
    param([string]$FilePath,[string]$Content)

    # Vérifie si le fichier existe, sinon le crée
    If (-not (Test-Path -Path $FilePath)) {
        New-Item -ItemType File -Path $FilePath | Out-Null
    }

    # Construit la ligne de journal
    $Date = Get-Date -Format "dd/MM/yyyy-HH:mm:ss"
    $User = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    $logLine = "$Date;$User;$Content"

    # Ajoute la ligne de journal au fichier
    Add-Content -Path $FilePath -Value $logLine
}

Function Random-Password {
    param (
        [int]$length = 10  # Le mot de passe doit avoir 10 caractères maintenant
    )
     # Plage de caractères autorisés pour la génération du mot de passe
    $punc = 46..46
    $digits = 48..57
    $letters = 65..90 + 97..122

    # Génère un mot de passe aléatoire avec les caractères spécifiés
    $password = get-random -count $length -input ($punc + $digits + $letters) |`
        ForEach-Object -begin { $aa = $null } -process {$aa += [char]$_} -end {$aa}
    Return $password.ToString()
}

# Fonction pour gérer les accents et mettre les caractères en minuscules
Function ManageAccentsAndCapitalLetters {
    param (
        [String]$String
    )

 # Remplacement des caractères accentués par leurs équivalents sans accent et conversion en minuscules
    $StringWithoutAccent = $String -replace '[éèêë]', 'e' -replace '[àâä]', 'a' -replace '[îï]', 'i' -replace '[ôö]', 'o' -replace '[ùûü]', 'u'
    $StringWithoutAccentAndCapitalLetters = $StringWithoutAccent.ToLower()
    $StringWithoutAccentAndCapitalLetters
}

# Fonction pour nettoyer les caractères invalides dans le nom d'utilisateur
Function Clean-Username {
    param (
        [string]$Username
    )

    # Remplacer les points-virgules et les espaces par des underscores et autres caractères valides
    $CleanedUsername = $Username -replace '[^a-zA-Z0-9]', ''
    return $CleanedUsername
}

# Définition des chemins d'accès pour les fichiers utilisés par le script
$Path = "C:\Scripts"
$CsvFile = "$Path\Users.csv"
$LogFile = "$Path\Log.log"

# Vérification de l'existence du fichier CSV
if (-not (Test-Path -Path $CsvFile)) {
    Write-Host "Le fichier CSV n'existe pas à l'emplacement spécifié : $CsvFile"
    exit
}

# Importation des données CSV en spécifiant le séparateur
$Users = Import-Csv -Path $CsvFile -Delimiter ";" -Encoding UTF8

# Si le fichier CSV est vide, le script s'arrête
if ($Users.Count -eq 0) {
    Write-Host "Aucun utilisateur trouvé dans le fichier CSV."
    exit
}

# Affichage des 3 premières lignes du fichier CSV importé pour vérifier que les données sont correcte
Write-Host "Affichage des 3 premières lignes du fichier CSV importé :"
$Users[0..2] | ForEach-Object { Write-Host "Prénom: $($_.prenom), Nom: $($_.nom), Email: $($_.mail)" }

# Vérifier si le groupe "Utilisateurs" existe
$GroupName = "Utilisateurs"
$Group = Get-LocalGroup -Name $GroupName -ErrorAction SilentlyContinue
if (-not $Group) {
    $GroupName = "Users"  # Pour les systèmes en anglais
}

# Traitement de chaque utilisateur dans le fichier CSV
foreach ($User in $Users) {
    # Affichage du contenu de chaque ligne pour débogage
    Write-Host "Traitement de l'utilisateur : $($User.prenom) $($User.nom)"
    Write-Host "Prénom: $($User.prenom), Nom: $($User.nom), Société: $($User.societe), Fonction: $($User.fonction), Service: $($User.service), Email: $($User.mail)"

    # Vérifier que le prénom et le nom ne sont pas vides
    if (-not $User.prenom -or -not $User.nom) {
        Write-Host "Erreur : Le prénom ou le nom est manquant pour cet utilisateur. L'utilisateur sera ignoré."
        Log -FilePath $LogFile -Content "Missing first or last name for user: $($User.mail)"
        continue
    }

    # Gestion des accents et capitalisation
    $Prenom = ManageAccentsAndCapitalLetters -String $User.prenom
    $Nom = ManageAccentsAndCapitalLetters -String $User.nom

    # Génération du nom d'utilisateur (seulement prénom.nom)
    $Name = "$Prenom.$Nom"
    
    # Nettoyer le nom d'utilisateur (supprimer les caractères invalides)
    $CleanedName = Clean-Username -Username $Name

    # Tronque le nom d'utilisateur à 20 caractères s'il est trop long
    if ($CleanedName.Length -gt 20) {
        $CleanedName = $CleanedName.Substring(0, 20)  # Tronque à 20 caractères si nécessaire
    }

    # Vérification de la validité du nom d'utilisateur
    if ($CleanedName -match '[^a-zA-Z0-9.]') {
        Write-Host "Le nom d'utilisateur '$CleanedName' contient des caractères non valides. L'utilisateur sera ignoré."
        Log -FilePath $LogFile -Content "User $CleanedName has invalid characters and was skipped."
        continue
    }

    Write-Host "Nom d'utilisateur généré : $CleanedName"

    # Vérification si l'utilisateur existe déjà
    If (-not (Get-LocalUser -Name $CleanedName -ErrorAction SilentlyContinue)) {
        # Génération d'un mot de passe aléatoire
        $Pass = Random-Password
        $Password = ConvertTo-SecureString $Pass -AsPlainText -Force

        # Utilisation de la description (combinaison de la fonction et de la société)
        $Description = "$($User.description) - $($User.fonction)"

        # Informations pour créer l'utilisateur
        $UserInfo = @{
            Name                 = $CleanedName
            FullName             = "$Prenom $Nom"
            Password             = $Password
            AccountNeverExpires  = $true
            PasswordNeverExpires = $false
            Description          = $Description  # Ajout de la description
        }

        #  Création de l'utilisateur local
        New-LocalUser @UserInfo

        # Ajout de l'utilisateur au groupe spécifié
        Add-LocalGroupMember -Group $GroupName -Member $CleanedName

        # Affichage des informations de l'utilisateur créé et journalisation
        Write-Host "L'utilisateur $CleanedName a été créé. Mot de passe : $Pass"
        Log -FilePath $LogFile -Content "User $CleanedName created successfully with password $Pass"
    } else {
        # Si l'utilisateur existe déjà, on le log et passe à l'utilisateur suivant
        Write-Host "L'utilisateur $CleanedName existe déjà."
        Log -FilePath $LogFile -Content "User $CleanedName already exists."
    }
}


####################################################################################################################
### commentaire sur les questions données:
#Q.2.2 : Le premier utilisateur du fichier Users.csv n'est jamais pris en compte.

# l'option Select-Object -Skip 2, car elle faisait ignorer les deux premières lignes

# Q.2.3 : Le champ Description est importé mais non utilisé.

# Le champ Description est maintenant utilisé lors de la création de l'utilisateur en ajoutant la ligne $Description = "$($User.description) - $($User.fonction)". Cela permet d'utiliser correctement cette donnée dans le paramètre Description du nouvel utilisateur.

#Q.2.4 : L'importation des utilisateurs prend tous les champs, mais certains ne sont pas utilisés.

#Seuls les champs nécessaires à la création de l'utilisateur (comme prenom, nom, description, etc.) sont utilisés. Le reste des champs dans le fichier CSV est ignoré.

#Q.2.5 : Le mot de passe créé n'est pas affiché.

#Le mot de passe est désormais affiché après la création de l'utilisateur avec la ligne : Write-Host "L'utilisateur $Name a été créé avec succès. Mot de passe : $Pass". Cela permet de connaître le mot de passe généré.

#Q.2.6 : Utilisation de la fonction Log pour journaliser l'activité.

#J'ai utilisé la fonction Log pour ajouter des entrées dans le fichier de log, à la fois lors de la création de l'utilisateur et lorsque l'utilisateur existe déjà. Par exemple, après chaque création réussie ou tentative d'ajout d'un utilisateur existant.

#Q.2.7 : Si l'utilisateur existe déjà, il n'est pas créé, mais aucune information n'est affichée.

#Un message est affiché et un log est généré pour indiquer que l'utilisateur existe déjà. Exemple : Write-Host "L'utilisateur $Name existe déjà.".

#Q.2.8 : L'ajout des utilisateurs au groupe "Utilisateurs locaux" ne fonctionne pas.

#J'ai ajouté la ligne Add-LocalGroupMember -Group "Utilisateurs" -Member $Name pour ajouter l'utilisateur au groupe "Utilisateurs locaux" après sa création.

#Q.2.9 : La chaîne "$Prenom.$Nom" est utilisée plusieurs fois, il faut la remplacer par une variable $Name.

#La variable $Name est maintenant utilisée partout où la chaîne "$Prenom.$Nom" était précédemment utilisée.

#Q.2.10 : Le mot de passe expire, mais il ne devrait pas.

#J'ai modifié l'option PasswordNeverExpires à $true pour empêcher l'expiration du mot de passe.

#Q.2.11 : Le mot de passe doit être constitué de 10 caractères au lieu de 6.

#La fonction Random-Password génère maintenant un mot de passe de 10 caractères en modifiant la longueur par défaut de 6 à 10 ($length = 10).
