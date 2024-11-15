# ASRC-Checkpoint-2
# Réponses aux questions - Configuration réseau du client

## Q.1.1 Pourquoi le ping avec les adresses IP des machines ne fonctionnent pas ?
### Problème :
Le ping entre les machines ne fonctionne pas car les adresses IP des machines sont dans des sous-réseaux différents :
- **Client** : `172.16.100.50/24`
- **Serveur** : `172.16.10.10/24`

Les adresses sont dans des sous-réseaux distincts, ce qui empêche la communication directe.

### Solution :

1. J'ai modifié la configuration du client pour utiliser l'adresse IP `172.16.10.50/24`, afin qu'elle soit dans le même sous-réseau que celle du serveur.
2. J'ai effectué un **ping** vers l'adresse `172.16.10.10` pour tester la connexion.

### Résultat :
Le **ping** a fonctionné avec succès après avoir modifié l'adresse IP du client.

#### Capture d'écran du **ping fonctionnel** :

![ping fonctionnel](path/to/screenshot.png)

---

## Q.1.2 Modifie la configuration réseau du client pour qu'il soit en DHCP. 
### Problème :
Le client avait une adresse IP statique. L'objectif était de le passer en DHCP pour qu'il puisse recevoir une adresse dynamique du serveur DHCP.

### Solution :
1. J'ai modifié la configuration réseau du client pour qu'il utilise le **DHCP**.
2. J'ai vérifié la plage DHCP du serveur (`172.16.10.10`) et j'ai comparé l'adresse IP attribuée au client.

### Résultat :
Le client a récupéré l'adresse **`172.16.10.20`**, mais il n'a pas récupéré la première adresse disponible dans la plage DHCP (`172.16.10.10`).

### Pourquoi le client ne récupère-t-il pas la 1ère adresse disponible ?
- Le serveur DHCP attribue des adresses dans une **plage dynamique**. Si une adresse a déjà été attribuée précédemment, le serveur évite de la réattribuer et commence à attribuer les adresses suivantes.


#### Capture d'écran de l'adresse IP attribuée par DHCP :

![ipconfig DHCP](https://github.com/AhmedNady90/ASRC-Checkpoint-2/commit/7ca8ab572553d044fee6161665e2b99afe95650d)

---

## Q.1.3 Est-ce que ce client peut avoir l'adresse IP 172.16.10.15 en DHCP ?
### Problème :
L'objectif est de vérifier si le client peut recevoir l'adresse **`172.16.10.15`** via DHCP.

### Solution :
1. **Vérification de la plage DHCP** :
   - J'ai vérifié que l'adresse **`172.16.10.15`** était bien dans la plage DHCP du serveur (`172.16.10.10` à `172.16.10.50`).
2. **Libération et renouvellement du bail DHCP** :
   - J'ai utilisé les commandes suivantes pour libérer et renouveler le bail DHCP :
  
     ipconfig /release
     ipconfig /renew
    
3. **Réservation DHCP** :
   - Si nécessaire, j'ai réservé l'adresse **`172.16.10.15`** pour l'adresse MAC du client sur le serveur DHCP pour m'assurer qu'il l'obtienne.

### Résultat :
- Le client a pu obtenir l'adresse **`172.16.10.15`** après renouvellement du bail DHCP.
- Le résultat de la commande `ipconfig /all` montre l'adresse IP attribuée.

#### Capture d'écran du résultat de `ipconfig /all` :

![ipconfig all](path/to/screenshot3.png)

---
