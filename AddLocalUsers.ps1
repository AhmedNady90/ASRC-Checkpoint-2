function Log {
    param([string]$FilePath,[string]$Content)

    # Vérifie si le fichier existe, sinon le crée
    If (-not (Test-Path -Path $FilePath))
    {
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
        [int]$length = 10
    )
    $punc = 46..46
    $digits = 48..57
    $letters = 65..90 + 97..122

    $password = get-random -count $length -input ($punc + $digits + $letters) |`
        ForEach-Object -begin { $aa = $null } -process {$aa += [char]$_} -end {$aa}
    Return $password.ToString()
}

Function ManageAccentsAndCapitalLetters {
    param (
        [String]$String
    )

    $StringWithoutAccent = $String -replace '[éèêë]', 'e' -replace '[àâä]', 'a' -replace '[îï]', 'i' -replace '[ôö]', 'o' -replace '[ùûü]', 'u'
    $StringWithoutAccentAndCapitalLetters = $StringWithoutAccent.ToLower()
    $StringWithoutAccentAndCapitalLetters
}

$Path = "C:\Scripts"
$CsvFile = "$Path\Users.csv"
$LogFile = "$Path\Log.log"

if (-not (Test-Path -Path $CsvFile)) {
    Write-Host "Le fichier CSV n'existe pas à l'emplacement spécifié : $CsvFile"
    exit
}

# Modification pour inclure le premier utilisateur du fichier CSV
$Users = Import-Csv -Path $CsvFile -Delimiter ";" -Header "prenom","nom","societe","fonction","service","description","mail","mobile","scriptPath","telephoneNumber" -Encoding UTF8

if ($Users.Count -eq 0) {
    Write-Host "Aucun utilisateur trouvé dans le fichier CSV."
    exit
}

foreach ($User in $Users)
{
    Write-Host "Traitement de l'utilisateur : $($User.prenom) $($User.nom)"

    $Prenom = ManageAccentsAndCapitalLetters -String $User.prenom
    $Nom = ManageAccentsAndCapitalLetters -String $User.nom
    $Name = "$Prenom.$Nom"

    Write-Host "Nom d'utilisateur généré : $Name"

    # Vérification si l'utilisateur existe déjà
    If (-not(Get-LocalUser -Name $Name -ErrorAction SilentlyContinue))
    {
        # Création du mot de passe
        $Pass = Random-Password -length 10
        $Password = (ConvertTo-SecureString $Pass -AsPlainText -Force)
        
        # Utilisation du champ Description dans la création de l'utilisateur
        $Description = "$($User.description) - $($User.fonction)"
        
        $UserInfo = @{
            Name                 = $Name
            FullName             = "$Prenom $Nom"
            Password             = $Password
            Description          = $Description
            AccountNeverExpires  = $true
            PasswordNeverExpires = $true  # Le mot de passe ne doit pas expirer
        }

        # Création de l'utilisateur
        New-LocalUser @UserInfo
        
        # Ajout de l'utilisateur au groupe "Utilisateurs"
        Add-LocalGroupMember -Group "Utilisateurs" -Member $Name

        Write-Host "L'utilisateur $Name a été créé avec succès. Mot de passe : $Pass"

        # Log de la création de l'utilisateur
        Log -FilePath $LogFile -Content "User $Name created successfully"
    }
    else {
        Write-Host "L'utilisateur $Name existe déjà."
        
        # Log si l'utilisateur existe déjà
        Log -FilePath $LogFile -Content "User $Name already exists."
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
