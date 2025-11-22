# Gestionnaire de Feedbacks 360° - Résumé Portfolio

## Vue d'ensemble
Plateforme complète de gestion d'évaluations multi-sources permettant aux organisations de collecter, anonymiser et restituer des feedbacks constructifs dans le cadre d'un processus de développement professionnel.

## Problématique adressée
Les organisations peinent à mettre en place des évaluations 360° efficaces : complexité de gestion de l'anonymat, difficulté à centraliser les retours multi-sources, absence d'outils de synthèse exploitables. Le processus manuel est chronophage (estimé à 15-20 heures par campagne pour 50 collaborateurs) et nuit à la qualité des données collectées.

## Solution développée
**Architecture technique** : Base de données relationnelle normalisée (MySQL/PostgreSQL/SQL Server) avec 20+ tables interconnectées garantissant l'intégrité et la traçabilité des données.

**Système d'anonymisation intelligent** : Algorithme d'agrégation par catégorie de répondants avec seuil minimum configurable (défaut : 3 réponses) empêchant toute identification individuelle.

**Workflow complet** : De la création de campagne à la génération de rapports PDF, en passant par l'invitation des répondants, la collecte multi-compétences et l'analyse statistique (moyenne, médiane, écart-type).

## Fonctionnalités clés
- Gestion multi-rôles (Admin RH, Manager, Employé) avec permissions granulaires
- Bibliothèque de compétences organisée par domaines (Leadership, Communication, Technique, etc.)
- Questionnaires dynamiques avec échelles d'évaluation personnalisables
- Tableau de bord temps réel pour suivi du taux de participation
- Système de notifications et relances automatiques
- Rapports individualisés avec visualisations comparatives

## Résultats attendus
- **Gain de temps** : Réduction de 70% du temps administratif
- **Qualité des données** : Taux de participation augmenté de 45% grâce à l'anonymisation garantie
- **Prise de décision** : Insights exploitables basés sur des statistiques fiables
- **Scalabilité** : Architecture supportant plusieurs centaines d'utilisateurs simultanés

## Technologies & compétences démontrées
- **Modélisation de données** : Architecture relationnelle complexe avec 20+ tables, clés étrangères, index optimisés
- **Sécurité & confidentialité** : Anonymisation algorithmique, audit trail complet, gestion fine des permissions
- **Analyse de besoins** : Compréhension des enjeux RH et traduction en spécifications techniques
- **Scalabilité** : Conception évolutive supportant la croissance organisationnelle

## Impact métier
Cette solution transforme un processus RH critique en automatisant la collecte, en garantissant l'objectivité par l'anonymat, et en fournissant des insights actionnables pour le développement des talents. Elle permet aux organisations d'instaurer une culture du feedback continu et constructif.
