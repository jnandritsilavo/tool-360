# 360° Feedback Manager 🎯

[![Database](https://img.shields.io/badge/Database-MySQL%20%7C%20PostgreSQL%20%7C%20SQL%20Server-blue)](https://github.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Status](https://img.shields.io/badge/Status-Concept-orange)](https://github.com)

> Plateforme complète de gestion d'évaluations 360° - Collecte, anonymisation et restitution de feedbacks multi-sources pour le développement professionnel.

## 📋 Table des matières

- [Vue d'ensemble](#vue-densemble)
- [Contexte du projet](#contexte-du-projet)
- [Fonctionnalités principales](#fonctionnalités-principales)
- [Architecture de la base de données](#architecture-de-la-base-de-données)
- [Installation](#installation)
- [Structure de la base de données](#structure-de-la-base-de-données)
- [Cas d'usage](#cas-dusage)
- [Roadmap](#roadmap)
- [Contribution](#contribution)
- [Licence](#licence)

## 🎯 Vue d'ensemble

Le **360° Feedback Manager** est une solution conçue pour digitaliser et automatiser le processus d'évaluation multi-sources (360°) dans les organisations. Il permet de collecter des feedbacks anonymes provenant de différentes catégories de répondants (managers, pairs, collaborateurs, clients internes) et de générer des rapports d'analyse personnalisés.

### Problématique

Les organisations font face à plusieurs défis lors de la mise en place d'évaluations 360° :
- **Complexité administrative** : Gestion manuelle chronophage (15-20h par campagne pour 50 collaborateurs)
- **Anonymat difficile à garantir** : Crainte des répondants d'être identifiés
- **Synthèse des données** : Difficulté à agréger et analyser les feedbacks de manière exploitable
- **Suivi et relances** : Absence d'automatisation des rappels

### Solution

Cette plateforme propose :
- ✅ **Automatisation complète** du workflow d'évaluation
- ✅ **Anonymisation algorithmique** garantie par agrégation avec seuils configurables
- ✅ **Tableaux de bord temps réel** pour le suivi des campagnes
- ✅ **Rapports personnalisés** avec analyses statistiques et visualisations
- ✅ **Notifications automatiques** et système de relances intelligent

## 🚀 Fonctionnalités principales

### 🔐 Gestion des utilisateurs et permissions
- Système multi-rôles (Admin RH, Manager, Employé)
- Authentification sécurisée avec hashage des mots de passe
- Gestion granulaire des permissions par rôle
- Profils utilisateurs enrichis (département, fonction, ancienneté)

### 📊 Configuration des campagnes
- Création de campagnes avec périodes définies
- Sélection des collaborateurs évalués et des répondants
- Configuration du référentiel de compétences à évaluer
- Paramétrage des seuils d'anonymat (par défaut : minimum 3 répondants)

### 📚 Référentiel de compétences
- Bibliothèque de compétences organisée par domaines :
  - Leadership (vision stratégique, prise de décision)
  - Communication (orale, écoute active)
  - Compétences techniques
  - Collaboration (travail d'équipe, transversalité)
  - Résolution de problèmes (analyse, créativité)
  - Gestion du temps (organisation, priorisation)
- Échelles d'évaluation configurables (1-5, 1-10, qualitative)
- Possibilité de créer des compétences personnalisées

### 📝 Collecte des feedbacks
- Interface de questionnaire intuitive et responsive
- Questions fermées (échelles de notation) et ouvertes (commentaires)
- Sauvegarde automatique des réponses en cours
- Indicateur de progression
- Système de relances automatiques pour les non-répondants

### 🔒 Anonymisation et agrégation
- Anonymisation par catégorie de répondants :
  - Manager (hiérarchique direct)
  - Peer (collègue de même niveau)
  - Subordinate (collaborateur)
  - Internal Client (autre département)
  - Self (auto-évaluation)
- Règles de seuil : affichage uniquement si ≥ 3 réponses par catégorie
- Agrégation statistique : moyennes, médianes, écarts-types
- Masquage intelligent des données insuffisantes

### 📈 Restitution et rapports
- Tableau de bord personnalisé pour chaque évalué
- Visualisations graphiques par compétence et par catégorie
- Comparaison avec moyennes organisationnelles (benchmarking)
- Synthèse des commentaires qualitatifs anonymisés
- Export PDF des rapports

### 🔔 Notifications et communications
- Notifications par email (invitation, relance, disponibilité du rapport)
- Notifications in-app pour les actions importantes
- Templates d'emails personnalisables
- Historique complet des communications

### 📊 Administration et suivi
- Dashboard administrateur avec KPIs temps réel :
  - Taux de participation global
  - Nombre de réponses par catégorie
  - Progression par participant
- Gestion des relances ciblées
- Historique et archivage des campagnes
- Statistiques d'utilisation

## 🗄️ Architecture de la base de données

### Schéma conceptuel

La base de données est structurée autour de 5 modules principaux :

```
┌─────────────────────┐
│  RÉFÉRENTIEL        │
│  - Rôles            │
│  - Départements     │
│  - Compétences      │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐      ┌─────────────────────┐
│  UTILISATEURS       │◄─────┤  CAMPAGNES          │
│  - Users            │      │  - Campaigns        │
│  - User_Roles       │      │  - Participants     │
└──────────┬──────────┘      └──────────┬──────────┘
           │                             │
           ▼                             ▼
┌─────────────────────┐      ┌─────────────────────┐
│  FEEDBACKS          │      │  AGRÉGATION         │
│  - Invitations      │─────►│  - Résultats        │
│  - Réponses         │      │  - Rapports         │
│  - Commentaires     │      └─────────────────────┘
└─────────────────────┘
```

### Tables principales

- **20+ tables interconnectées** avec intégrité référentielle complète
- **Clés primaires** auto-incrémentées sur toutes les tables
- **Clés étrangères** avec contraintes ON DELETE CASCADE/SET NULL
- **Index optimisés** sur les colonnes fréquemment interrogées
- **Contraintes d'unicité** pour garantir la cohérence des données

### Diagramme complet

Consultez le fichier [database_diagram.md](database_diagram.md) pour le diagramme Entity-Relationship détaillé.

## 💾 Installation

### Prérequis

- MySQL 8.0+ / PostgreSQL 13+ / SQL Server 2019+
- Client SQL (MySQL Workbench, pgAdmin, SSMS)
- (Optionnel) Docker pour environnement isolé

### Étapes d'installation

#### 1. Clone du repository

```bash
git clone https://github.com/votre-username/feedback360.git
cd feedback360
```

#### 2. Choix de la base de données

Trois scripts SQL sont fournis selon votre SGBD :

**Pour MySQL :**
```bash
mysql -u root -p < feedback360_mysql.sql
```

**Pour PostgreSQL :**
```bash
psql -U postgres -d postgres -f feedback360_postgresql.sql
```

**Pour SQL Server :**
```bash
sqlcmd -S localhost -U sa -P YourPassword -i feedback360_sqlserver.sql
```

#### 3. Vérification de l'installation

Connectez-vous à votre base de données et vérifiez la création des tables :

```sql
-- MySQL / PostgreSQL
SELECT COUNT(*) FROM information_schema.tables 
WHERE table_schema = 'feedback360';

-- SQL Server
SELECT COUNT(*) FROM sys.tables;
```

Vous devriez avoir **20 tables** créées.

#### 4. Données de démo (optionnel)

Les scripts incluent des données initiales :
- 4 rôles utilisateurs
- 4 statuts de campagnes
- 5 catégories de répondants
- 6 domaines de compétences
- 11 compétences exemples

## 📊 Structure de la base de données

### Module Référentiel
- `roles` : Rôles utilisateurs (Admin, HR_Manager, Manager, Employee)
- `departments` : Départements organisationnels
- `competency_domains` : Domaines de compétences
- `competencies` : Bibliothèque de compétences

### Module Utilisateurs
- `users` : Comptes utilisateurs
- `user_roles` : Association utilisateurs-rôles (many-to-many)

### Module Campagnes
- `campaign_statuses` : Statuts (Draft, Active, Closed, Archived)
- `campaigns` : Campagnes d'évaluation
- `campaign_participants` : Collaborateurs évalués
- `campaign_competencies` : Compétences évaluées dans la campagne
- `respondent_categories` : Catégories de répondants

### Module Feedbacks
- `feedback_invitations` : Invitations à donner un feedback
- `competency_responses` : Réponses quantitatives (scores)
- `qualitative_comments` : Commentaires qualitatifs

### Module Agrégation
- `aggregated_results` : Résultats agrégés par compétence et catégorie
- `generated_reports` : Rapports PDF générés

### Module Système
- `notifications` : Système de notifications
- `audit_logs` : Logs d'audit pour traçabilité

## 💼 Cas d'usage

### Scénario 1 : Lancement d'une campagne annuelle

1. **RH Admin** crée une campagne "Évaluation annuelle 2024"
2. Configure les dates (1er mars - 31 mars)
3. Sélectionne 50 collaborateurs à évaluer
4. Choisit 8 compétences parmi le référentiel
5. Le système génère automatiquement 250 invitations (5 répondants × 50 évalués)
6. Envoi automatique des emails d'invitation
7. Relances J+7 et J+14 pour les non-répondants

### Scénario 2 : Feedback pour un manager

**Participant** : Jean Dupont (Manager Commercial)

**Répondants invités :**
- 1 Manager (son N+1)
- 3 Peers (autres managers)
- 4 Subordinates (son équipe)
- 1 Self-evaluation

**Résultats** :
- 8/9 réponses (89% de taux de participation)
- Rapport généré avec :
  - Scores moyens par compétence
  - Comparaison self vs. autres
  - Écart entre perception manager et équipe
  - Commentaires anonymisés par catégorie
  - Plan de développement suggéré

### Scénario 3 : Gestion de l'anonymat

**Situation** : Une collaboratrice n'a qu'**2 pairs** dans son département.

**Protection activée** :
- Le système détecte que le seuil minimum (3) n'est pas atteint
- Les scores de la catégorie "Peer" ne sont **pas affichés** dans le rapport
- Message affiché : *"Données insuffisantes pour garantir l'anonymat"*
- Les autres catégories (Manager, Subordinates) restent visibles

## 🛣️ Roadmap

### Phase 1 - MVP ✅ (Actuel)
- [x] Architecture de base de données complète
- [x] Scripts SQL multi-SGBD
- [x] Documentation technique

### Phase 2 - Backend (En cours)
- [ ] API REST (Node.js/Express ou Python/FastAPI)
- [ ] Authentification JWT
- [ ] Endpoints CRUD pour toutes les entités
- [ ] Algorithme d'agrégation et anonymisation
- [ ] Système de notifications email

### Phase 3 - Frontend
- [ ] Interface admin (React/Vue.js)
- [ ] Dashboard RH
- [ ] Interface de réponse aux questionnaires
- [ ] Visualisations des rapports (Chart.js/D3.js)
- [ ] Application mobile (React Native)

### Phase 4 - Fonctionnalités avancées
- [ ] Machine Learning pour recommandations
- [ ] Export Excel/CSV des données agrégées
- [ ] Intégration HRIS (Workday, SAP SuccessFactors)
- [ ] Module de gestion des plans de développement
- [ ] Analytics avancées (tendances, prédictions)

### Phase 5 - Optimisations
- [ ] Cache Redis pour performances
- [ ] CDN pour fichiers statiques
- [ ] Tests automatisés (Jest, Pytest)
- [ ] CI/CD (GitHub Actions)
- [ ] Monitoring (Prometheus, Grafana)

## 🤝 Contribution

Les contributions sont les bienvenues ! Pour contribuer :

1. Forkez le projet
2. Créez une branche feature (`git checkout -b feature/AmazingFeature`)
3. Committez vos changements (`git commit -m 'Add some AmazingFeature'`)
4. Pushez vers la branche (`git push origin feature/AmazingFeature`)
5. Ouvrez une Pull Request

### Guidelines

- Respectez la structure de la base de données existante
- Documentez tout nouveau champ ou table
- Testez vos scripts SQL sur les 3 SGBD
- Mettez à jour le diagramme ER si modification du schéma

## 📄 Licence

Ce projet est sous licence MIT. Voir le fichier [LICENSE](LICENSE) pour plus de détails.

## 📧 Contact

**Nom du projet** : 360° Feedback Manager

**Votre Nom** - [@votretwitter](https://twitter.com/votretwitter) - votre.email@example.com

**Lien du projet** : [https://github.com/votre-username/feedback360](https://github.com/votre-username/feedback360)

---

## 🌟 Remerciements

- Inspiré par les meilleures pratiques RH en matière d'évaluation 360°
- Conçu pour répondre aux besoins réels des départements RH
- Architecture scalable pensée pour la croissance

---

<p align="center">
  Fait avec ❤️ pour améliorer le développement des talents en entreprise
</p>
