-- ============================================
-- Gestionnaire de Feedbacks 360°
-- Script de création de base de données MySQL
-- ============================================

-- Création de la base de données
CREATE DATABASE IF NOT EXISTS feedback360
CHARACTER SET utf8mb4
COLLATE utf8mb4_unicode_ci;

USE feedback360;

-- ============================================
-- TABLES DE RÉFÉRENCE
-- ============================================

-- Table des rôles utilisateurs
CREATE TABLE roles (
    role_id INT AUTO_INCREMENT PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_role_name (role_name)
) ENGINE=InnoDB;

-- Table des départements
CREATE TABLE departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    description TEXT,
    manager_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_dept_name (department_name)
) ENGINE=InnoDB;

-- Table des domaines de compétences
CREATE TABLE competency_domains (
    domain_id INT AUTO_INCREMENT PRIMARY KEY,
    domain_name VARCHAR(100) NOT NULL,
    description TEXT,
    display_order INT DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_domain_name (domain_name),
    INDEX idx_display_order (display_order)
) ENGINE=InnoDB;

-- Table des compétences
CREATE TABLE competencies (
    competency_id INT AUTO_INCREMENT PRIMARY KEY,
    domain_id INT NOT NULL,
    competency_name VARCHAR(150) NOT NULL,
    description TEXT,
    evaluation_scale_type ENUM('numeric_5', 'numeric_10', 'qualitative') DEFAULT 'numeric_5',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (domain_id) REFERENCES competency_domains(domain_id) ON DELETE CASCADE,
    INDEX idx_domain (domain_id),
    INDEX idx_competency_name (competency_name)
) ENGINE=InnoDB;

-- ============================================
-- TABLES UTILISATEURS
-- ============================================

-- Table des utilisateurs
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    department_id INT,
    job_title VARCHAR(150),
    hire_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (department_id) REFERENCES departments(department_id) ON DELETE SET NULL,
    INDEX idx_email (email),
    INDEX idx_name (last_name, first_name),
    INDEX idx_department (department_id)
) ENGINE=InnoDB;

-- Table d'association utilisateurs-rôles (many-to-many)
CREATE TABLE user_roles (
    user_role_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    role_id INT NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    assigned_by INT,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_by) REFERENCES users(user_id) ON DELETE SET NULL,
    UNIQUE KEY unique_user_role (user_id, role_id),
    INDEX idx_user (user_id),
    INDEX idx_role (role_id)
) ENGINE=InnoDB;

-- ============================================
-- TABLES CAMPAGNES
-- ============================================

-- Table des statuts de campagnes
CREATE TABLE campaign_statuses (
    status_id INT AUTO_INCREMENT PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    INDEX idx_status_name (status_name)
) ENGINE=InnoDB;

-- Table des campagnes d'évaluation
CREATE TABLE campaigns (
    campaign_id INT AUTO_INCREMENT PRIMARY KEY,
    campaign_name VARCHAR(200) NOT NULL,
    description TEXT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status_id INT NOT NULL,
    min_respondents_threshold INT DEFAULT 3,
    created_by INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (status_id) REFERENCES campaign_statuses(status_id),
    FOREIGN KEY (created_by) REFERENCES users(user_id),
    INDEX idx_campaign_name (campaign_name),
    INDEX idx_dates (start_date, end_date),
    INDEX idx_status (status_id),
    INDEX idx_created_by (created_by)
) ENGINE=InnoDB;

-- Table des catégories de répondants
CREATE TABLE respondent_categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    display_order INT DEFAULT 0,
    INDEX idx_category_name (category_name)
) ENGINE=InnoDB;

-- Table des participants évalués dans une campagne
CREATE TABLE campaign_participants (
    participant_id INT AUTO_INCREMENT PRIMARY KEY,
    campaign_id INT NOT NULL,
    user_id INT NOT NULL,
    notification_sent BOOLEAN DEFAULT FALSE,
    notification_sent_at TIMESTAMP NULL,
    report_generated BOOLEAN DEFAULT FALSE,
    report_generated_at TIMESTAMP NULL,
    report_viewed BOOLEAN DEFAULT FALSE,
    report_viewed_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    UNIQUE KEY unique_campaign_participant (campaign_id, user_id),
    INDEX idx_campaign (campaign_id),
    INDEX idx_user (user_id)
) ENGINE=InnoDB;

-- Table des compétences associées à une campagne
CREATE TABLE campaign_competencies (
    campaign_competency_id INT AUTO_INCREMENT PRIMARY KEY,
    campaign_id INT NOT NULL,
    competency_id INT NOT NULL,
    is_mandatory BOOLEAN DEFAULT TRUE,
    weight DECIMAL(5,2) DEFAULT 1.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id) ON DELETE CASCADE,
    FOREIGN KEY (competency_id) REFERENCES competencies(competency_id) ON DELETE CASCADE,
    UNIQUE KEY unique_campaign_competency (campaign_id, competency_id),
    INDEX idx_campaign (campaign_id),
    INDEX idx_competency (competency_id)
) ENGINE=InnoDB;

-- ============================================
-- TABLES FEEDBACKS
-- ============================================

-- Table des invitations à donner un feedback
CREATE TABLE feedback_invitations (
    invitation_id INT AUTO_INCREMENT PRIMARY KEY,
    campaign_id INT NOT NULL,
    participant_id INT NOT NULL,
    respondent_id INT NOT NULL,
    category_id INT NOT NULL,
    invitation_token VARCHAR(255) NOT NULL UNIQUE,
    invited_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reminded_at TIMESTAMP NULL,
    reminder_count INT DEFAULT 0,
    completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP NULL,
    FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id) ON DELETE CASCADE,
    FOREIGN KEY (participant_id) REFERENCES campaign_participants(participant_id) ON DELETE CASCADE,
    FOREIGN KEY (respondent_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES respondent_categories(category_id),
    UNIQUE KEY unique_invitation (campaign_id, participant_id, respondent_id),
    INDEX idx_campaign (campaign_id),
    INDEX idx_participant (participant_id),
    INDEX idx_respondent (respondent_id),
    INDEX idx_category (category_id),
    INDEX idx_token (invitation_token),
    INDEX idx_completed (completed)
) ENGINE=InnoDB;

-- Table des réponses aux évaluations de compétences
CREATE TABLE competency_responses (
    response_id INT AUTO_INCREMENT PRIMARY KEY,
    invitation_id INT NOT NULL,
    competency_id INT NOT NULL,
    score DECIMAL(5,2),
    qualitative_value VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (invitation_id) REFERENCES feedback_invitations(invitation_id) ON DELETE CASCADE,
    FOREIGN KEY (competency_id) REFERENCES competencies(competency_id) ON DELETE CASCADE,
    INDEX idx_invitation (invitation_id),
    INDEX idx_competency (competency_id)
) ENGINE=InnoDB;

-- Table des commentaires qualitatifs
CREATE TABLE qualitative_comments (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    invitation_id INT NOT NULL,
    question_text TEXT NOT NULL,
    comment_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (invitation_id) REFERENCES feedback_invitations(invitation_id) ON DELETE CASCADE,
    INDEX idx_invitation (invitation_id)
) ENGINE=InnoDB;

-- ============================================
-- TABLES AGRÉGATION ET RAPPORTS
-- ============================================

-- Table des résultats agrégés par compétence et catégorie
CREATE TABLE aggregated_results (
    aggregated_id INT AUTO_INCREMENT PRIMARY KEY,
    participant_id INT NOT NULL,
    competency_id INT NOT NULL,
    category_id INT NOT NULL,
    response_count INT NOT NULL,
    average_score DECIMAL(5,2),
    median_score DECIMAL(5,2),
    std_deviation DECIMAL(5,2),
    min_score DECIMAL(5,2),
    max_score DECIMAL(5,2),
    is_displayable BOOLEAN DEFAULT FALSE,
    calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (participant_id) REFERENCES campaign_participants(participant_id) ON DELETE CASCADE,
    FOREIGN KEY (competency_id) REFERENCES competencies(competency_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES respondent_categories(category_id),
    UNIQUE KEY unique_aggregation (participant_id, competency_id, category_id),
    INDEX idx_participant (participant_id),
    INDEX idx_competency (competency_id),
    INDEX idx_category (category_id),
    INDEX idx_displayable (is_displayable)
) ENGINE=InnoDB;

-- Table des rapports générés
CREATE TABLE generated_reports (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    participant_id INT NOT NULL,
    report_file_path VARCHAR(500),
    report_format VARCHAR(20) DEFAULT 'PDF',
    total_respondents INT,
    completion_rate DECIMAL(5,2),
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (participant_id) REFERENCES campaign_participants(participant_id) ON DELETE CASCADE,
    INDEX idx_participant (participant_id),
    INDEX idx_generated_at (generated_at)
) ENGINE=InnoDB;

-- ============================================
-- TABLES SYSTÈME
-- ============================================

-- Table des notifications
CREATE TABLE notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    notification_type VARCHAR(50) NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP NULL,
    related_entity_type VARCHAR(50),
    related_entity_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_is_read (is_read),
    INDEX idx_type (notification_type),
    INDEX idx_created (created_at)
) ENGINE=InnoDB;

-- Table des logs d'audit
CREATE TABLE audit_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action_type VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50),
    entity_id INT,
    old_values JSON,
    new_values JSON,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    INDEX idx_user (user_id),
    INDEX idx_action (action_type),
    INDEX idx_entity (entity_type, entity_id),
    INDEX idx_created (created_at)
) ENGINE=InnoDB;

-- ============================================
-- CONTRAINTE RÉFÉRENTIELLE DIFFÉRÉE
-- ============================================

-- Ajout de la contrainte de manager pour departments
ALTER TABLE departments
ADD CONSTRAINT fk_department_manager
FOREIGN KEY (manager_id) REFERENCES users(user_id) ON DELETE SET NULL;

-- ============================================
-- DONNÉES INITIALES
-- ============================================

-- Insertion des rôles par défaut
INSERT INTO roles (role_name, description) VALUES
('Admin', 'Administrateur système avec tous les privilèges'),
('HR_Manager', 'Responsable RH - Gestion des campagnes'),
('Manager', 'Manager - Peut évaluer ses collaborateurs'),
('Employee', 'Employé - Peut donner et recevoir des feedbacks');

-- Insertion des statuts de campagnes
INSERT INTO campaign_statuses (status_name, description) VALUES
('Draft', 'Campagne en cours de création'),
('Active', 'Campagne active - collecte en cours'),
('Closed', 'Campagne terminée - collecte fermée'),
('Archived', 'Campagne archivée');

-- Insertion des catégories de répondants
INSERT INTO respondent_categories (category_name, description, display_order) VALUES
('Manager', 'Responsable hiérarchique direct', 1),
('Peer', 'Collègue de même niveau', 2),
('Subordinate', 'Collaborateur sous la responsabilité de l\'évalué', 3),
('Internal_Client', 'Client interne - autre département', 4),
('Self', 'Auto-évaluation', 5);

-- Insertion des domaines de compétences
INSERT INTO competency_domains (domain_name, description, display_order) VALUES
('Leadership', 'Capacités de direction et d\'influence', 1),
('Communication', 'Communication orale et écrite', 2),
('Technical_Skills', 'Compétences techniques métier', 3),
('Collaboration', 'Travail d\'équipe et coopération', 4),
('Problem_Solving', 'Résolution de problèmes et innovation', 5),
('Time_Management', 'Organisation et gestion du temps', 6);

-- Insertion de compétences exemples
INSERT INTO competencies (domain_id, competency_name, description, evaluation_scale_type) VALUES
(1, 'Vision stratégique', 'Capacité à définir et communiquer une vision claire', 'numeric_5'),
(1, 'Prise de décision', 'Qualité et rapidité des décisions prises', 'numeric_5'),
(2, 'Communication orale', 'Clarté et efficacité de la communication verbale', 'numeric_5'),
(2, 'Écoute active', 'Capacité à écouter et comprendre les autres', 'numeric_5'),
(3, 'Expertise technique', 'Maîtrise des compétences techniques requises', 'numeric_5'),
(4, 'Esprit d\'équipe', 'Contribution positive à la dynamique d\'équipe', 'numeric_5'),
(4, 'Collaboration transverse', 'Capacité à travailler avec d\'autres départements', 'numeric_5'),
(5, 'Analyse de problèmes', 'Capacité à identifier et analyser les problèmes', 'numeric_5'),
(5, 'Créativité', 'Proposition de solutions innovantes', 'numeric_5'),
(6, 'Respect des délais', 'Capacité à livrer dans les temps', 'numeric_5'),
(6, 'Priorisation', 'Capacité à prioriser les tâches efficacement', 'numeric_5');

-- ============================================
-- FIN DU SCRIPT
-- ============================================
