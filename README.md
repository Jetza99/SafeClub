# 🏦 SafeClub – Secure Ethereum Treasury for Student Clubs

## 📌 Description du projet

**SafeClub** est un smart contract Ethereum développé en Solidity permettant à un **club étudiant** de gérer un **trésor en ETH** de manière sécurisée et décentralisée.

Le contrat permet :

- La gestion des membres
- La création de propositions de dépenses
- Le vote des membres (pour / contre)
- L’exécution sécurisée des paiements
- L’application des bonnes pratiques de sécurité

Ce projet a été réalisé dans un cadre **pédagogique** pour appliquer les notions de **sécurité des smart contracts**.

---

## 🎯 Objectifs

- Centraliser les fonds du club dans un contrat sécurisé
- Éviter les dépenses non autorisées
- Garantir un processus de décision transparent
- Prévenir les attaques classiques (réentrance, double vote, etc.)

---

## 🧱 Fonctionnalités

### 👥 Gestion des membres

- Ajout et suppression de membres par le propriétaire
- Liste des membres consultable
- Le propriétaire est automatiquement membre

### 💰 Trésorerie ETH

- Le contrat peut recevoir de l’ETH
- Le solde est consultable publiquement
- Aucun retrait direct sans vote

### 📝 Propositions de dépenses

Chaque proposition contient :

- Montant à envoyer
- Adresse du bénéficiaire
- Description
- Date limite de vote
- Nombre de votes pour / contre
- État d’exécution

### 🗳️ Système de vote

- Seuls les membres peuvent voter
- Un seul vote par membre et par proposition
- Vote possible uniquement avant la deadline

### 🔐 Exécution sécurisée

- Une proposition est exécutée seulement si :
  - Le vote est terminé
  - Les votes POUR > CONTRE
  - Elle n’a jamais été exécutée
- Protection contre la réentrance
- Transfert ETH sécurisé

---

## 🔒 Sécurité

Les mesures de sécurité implémentées incluent :

- Contrôle d’accès (`onlyOwner`, `isMember`)
- Protection contre la réentrance (`nonReentrant`)
- Pattern Checks‑Effects‑Interactions
- Prévention du double vote
- Prévention de la double exécution
- Validation stricte des états

Une analyse statique a été réalisée avec **Slither**.  
Aucune vulnérabilité critique n’a été détectée.

---

## 🧪 Tests

Les tests ont été réalisés avec **Hardhat** et couvrent :

- Déploiement du contrat
- Dépôt d’ETH
- Création de propositions
- Vote valide / invalide
- Double vote (rejeté)
- Exécution correcte d’une proposition acceptée

### Lancer les tests :

```bash
npx hardhat test
```
