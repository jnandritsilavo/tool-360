-- ============================================
-- Gestionnaire de Feedbacks 360°
-- Script de création de base de données PostgreSQL
-- ============================================

-- Création de la base de données
-- À exécuter en tant que superuser
-- CREATE DATABASE feedback360
--     WITH 
--     ENCODING = 'UTF8'
--     LC_COLLATE = 'fr_FR.UTF-8'
--     LC_CTYPE = 'fr_FR.UTF-8'
--     TEMPLATE = template0;

-- \c feedback360

-- Création du schéma
CREATE SCHEMA IF NOT EXISTS public;

-- ============================================
-- TYPES ÉNUMÉRÉS
-- ============================================

CREATE TYPE evaluation_scale AS ENUM ('numeric_5', 'numeric_10', 'qualitative');
CREATE TYPE report_format AS ENUM ('PDF', 'HTML', 'DOCX');

-- ============================================
-- TABLES DE RÉFÉRENCE
-- ============================================

-- Table des rôles utilisateurs
CREATE TABLE roles (
    role_id SERIAL PRIMARY KEY,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_role_name ON roles(role_name);

-- Table des départements
CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL,
    description TEXT,
    manager_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_dept_name ON departments(department_name);

-- Table des domaines de compétences
CREATE TABLE competency_domains (
    domain_id SERIAL PRIMARY KEY,
    domain_name VARCHAR(100) NOT NULL,
    description TEXT,
    display_order INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_domain_name ON competency_domains(domain_name);
CREATE INDEX idx_display_order ON competency_domains(display_order);

-- Table des compétences
CREATE TABLE competencies (
    competency_id SERIAL PRIMARY KEY,
    domain_id INTEGER NOT NULL,
    competency_name VARCHAR(150) NOT NULL,
    description TEXT,
    evaluation_scale_type evaluation_scale DEFAULT 'numeric_5',
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_competency_domain FOREIGN KEY (domain_id) 
        REFERENCES competency_domains(domain_id) ON DELETE CASCADE
);

CREATE INDEX idx_comp_domain ON competencies(domain_id);
CREATE INDEX idx_competency_name ON competencies(competency_name);

-- ============================================
-- TABLES UTILISATEURS
-- ============================================

-- Table des utilisateurs
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    department_id INTEGER,
    job_title VARCHAR(150),
    hire_date DATE,
    is_active BOOLEAN DEFAULT TRUE,
    last_login TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_user_department FOREIGN KEY (department_id) 
        REFERENCES departments(department_id) ON DELETE SET NULL
);

CREATE INDEX idx_email ON users(email);
CREATE INDEX idx_name ON users(last_name, first_name);
CREATE INDEX idx_user_department ON users(department_id);

-- Table d'association utilisateurs-rôles (many-to-many)
CREATE TABLE user_roles (
    user_role_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    role_id INTEGER NOT NULL,
    assigned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    assigned_by INTEGER,
    CONSTRAINT fk_userrole_user FOREIGN KEY (user_id) 
        REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_userrole_role FOREIGN KEY (role_id) 
        REFERENCES roles(role_id) ON DELETE CASCADE,
    CONSTRAINT fk_userrole_assigner FOREIGN KEY (assigned_by) 
        REFERENCES users(user_id) ON DELETE SET NULL,
    CONSTRAINT unique_user_role UNIQUE (user_id, role_id)
);

CREATE INDEX idx_userrole_user ON user_roles(user_id);
CREATE INDEX idx_userrole_role ON user_roles(role_id);

-- ============================================
-- TABLES CAMPAGNES
-- ============================================

-- Table des statuts de campagnes
CREATE TABLE campaign_statuses (
    status_id SERIAL PRIMARY KEY,
    status_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT
);

CREATE INDEX idx_status_name ON campaign_statuses(status_name);

-- Table des campagnes d'évaluation
CREATE TABLE campaigns (
    campaign_id SERIAL PRIMARY KEY,
    campaign_name VARCHAR(200) NOT NULL,
    description TEXT,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status_id INTEGER NOT NULL,
    min_respondents_threshold INTEGER DEFAULT 3,
    created_by INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_campaign_status FOREIGN KEY (status_id) 
        REFERENCES campaign_statuses(status_id),
    CONSTRAINT fk_campaign_creator FOREIGN KEY (created_by) 
        REFERENCES users(user_id)
);

CREATE INDEX idx_campaign_name ON campaigns(campaign_name);
CREATE INDEX idx_campaign_dates ON campaigns(start_date, end_date);
CREATE INDEX idx_campaign_status ON campaigns(status_id);
CREATE INDEX idx_campaign_creator ON campaigns(created_by);

-- Table des catégories de répondants
CREATE TABLE respondent_categories (
    category_id SERIAL PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    display_order INTEGER DEFAULT 0
);

CREATE INDEX idx_category_name ON respondent_categories(category_name);

-- Table des participants évalués dans une campagne
CREATE TABLE campaign_participants (
    participant_id SERIAL PRIMARY KEY,
    campaign_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    notification_sent BOOLEAN DEFAULT FALSE,
    notification_sent_at TIMESTAMP,
    report_generated BOOLEAN DEFAULT FALSE,
    report_generated_at TIMESTAMP,
    report_viewed BOOLEAN DEFAULT FALSE,
    report_viewed_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_participant_campaign FOREIGN KEY (campaign_id) 
        REFERENCES campaigns(campaign_id) ON DELETE CASCADE,
    CONSTRAINT fk_participant_user FOREIGN KEY (user_id) 
        REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT unique_campaign_participant UNIQUE (campaign_id, user_id)
);

CREATE INDEX idx_participant_campaign ON campaign_participants(campaign_id);
CREATE INDEX idx_participant_user ON campaign_participants(user_id);

-- Table des compétences associées à une campagne
CREATE TABLE campaign_competencies (
    campaign_competency_id SERIAL PRIMARY KEY,
    campaign_id INTEGER NOT NULL,
    competency_id INTEGER NOT NULL,
    is_mandatory BOOLEAN DEFAULT TRUE,
    weight NUMERIC(5,2) DEFAULT 1.00,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_campcomp_campaign FOREIGN KEY (campaign_id) 
        REFERENCES campaigns(campaign_id) ON DELETE CASCADE,
    CONSTRAINT fk_campcomp_competency FOREIGN KEY (competency_id) 
        REFERENCES competencies(competency_id) ON DELETE CASCADE,
    CONSTRAINT unique_campaign_competency UNIQUE (campaign_id, competency_id)
);

CREATE INDEX idx_campcomp_campaign ON campaign_competencies(campaign_id);
CREATE INDEX idx_campcomp_competency ON campaign_competencies(competency_id);

-- ============================================
-- TABLES FEEDBACKS
-- ============================================

-- Table des invitations à donner un feedback
CREATE TABLE feedback_invitations (
    invitation_id SERIAL PRIMARY KEY,
    campaign_id INTEGER NOT NULL,
    participant_id INTEGER NOT NULL,
    respondent_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    invitation_token VARCHAR(255) NOT NULL UNIQUE,
    invited_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reminded_at TIMESTAMP,
    reminder_count INTEGER DEFAULT 0,
    completed BOOLEAN DEFAULT FALSE,
    completed_at TIMESTAMP,
    CONSTRAINT fk_invitation_campaign FOREIGN KEY (campaign_id) 
        REFERENCES campaigns(campaign_id) ON DELETE CASCADE,
    CONSTRAINT fk_invitation_participant FOREIGN KEY (participant_id) 
        REFERENCES campaign_participants(participant_id) ON DELETE CASCADE,
    CONSTRAINT fk_invitation_respondent FOREIGN KEY (respondent_id) 
        REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_invitation_category FOREIGN KEY (category_id) 
        REFERENCES respondent_categories(category_id),
    CONSTRAINT unique_invitation UNIQUE (campaign_id, participant_id, respondent_id)
);

CREATE INDEX idx_invitation_campaign ON feedback_invitations(campaign_id);
CREATE INDEX idx_invitation_participant ON feedback_invitations(participant_id);
CREATE INDEX idx_invitation_respondent ON feedback_invitations(respondent_id);
CREATE INDEX idx_invitation_category ON feedback_invitations(category_id);
CREATE INDEX idx_invitation_token ON feedback_invitations(invitation_token);
CREATE INDEX idx_invitation_completed ON feedback_invitations(completed);

-- Table des réponses aux évaluations de compétences
CREATE TABLE competency_responses (
    response_id SERIAL PRIMARY KEY,
    invitation_id INTEGER NOT NULL,
    competency_id INTEGER NOT NULL,
    score NUMERIC(5,2),
    qualitative_value VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_response_invitation FOREIGN KEY (invitation_id) 
        REFERENCES feedback_invitations(invitation_id) ON DELETE CASCADE,
    CONSTRAINT fk_response_competency FOREIGN KEY (competency_id) 
        REFERENCES competencies(competency_id) ON DELETE CASCADE
);

CREATE INDEX idx_response_invitation ON competency_responses(invitation_id);
CREATE INDEX idx_response_competency ON competency_responses(competency_id);

-- Table des commentaires qualitatifs
CREATE TABLE qualitative_comments (
    comment_id SERIAL PRIMARY KEY,
    invitation_id INTEGER NOT NULL,
    question_text TEXT NOT NULL,
    comment_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_comment_invitation FOREIGN KEY (invitation_id) 
        REFERENCES feedback_invitations(invitation_id) ON DELETE CASCADE
);

CREATE INDEX idx_comment_invitation ON qualitative_comments(invitation_id);

-- ============================================
-- TABLES AGRÉGATION ET RAPPORTS
-- ============================================

-- Table des résultats agrégés par compétence et catégorie
CREATE TABLE aggregated_results (
    aggregated_id SERIAL PRIMARY KEY,
    participant_id INTEGER NOT NULL,
    competency_id INTEGER NOT NULL,
    category_id INTEGER NOT NULL,
    response_count INTEGER NOT NULL,
    average_score NUMERIC(5,2),
    median_score NUMERIC(5,2),
    std_deviation NUMERIC(5,2),
    min_score NUMERIC(5,2),
    max_score NUMERIC(5,2),
    is_displayable BOOLEAN DEFAULT FALSE,
    calculated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_aggregated_participant FOREIGN KEY (participant_id) 
        REFERENCES campaign_participants(participant_id) ON DELETE CASCADE,
    CONSTRAINT fk_aggregated_competency FOREIGN KEY (competency_id) 
        REFERENCES competencies(competency_id) ON DELETE CASCADE,
    CONSTRAINT fk_aggregated_category FOREIGN KEY (category_id) 
        REFERENCES respondent_categories(category_id),
    CONSTRAINT unique_aggregation UNIQUE (participant_id, competency_id, category_id)
);

CREATE INDEX idx_aggregated_participant ON aggregated_results(participant_id);
CREATE INDEX idx_aggregated_competency ON aggregated_results(competency_id);
CREATE INDEX idx_aggregated_category ON aggregated_results(category_id);
CREATE INDEX idx_aggregated_displayable ON aggregated_results(is_displayable);

-- Table des rapports générés
CREATE TABLE generated_reports (
    report_id SERIAL PRIMARY KEY,
    participant_id INTEGER NOT NULL,
    report_file_path VARCHAR(500),
    report_format report_format DEFAULT 'PDF',
    total_respondents INTEGER,
    completion_rate NUMERIC(5,2),
    generated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_report_participant FOREIGN KEY (participant_id) 
        REFERENCES campaign_participants(participant_id) ON DELETE CASCADE
);

CREATE INDEX idx_report_participant ON generated_reports(participant_id);
CREATE INDEX idx_report_generated ON generated_reports(generated_at);

-- ============================================
-- TABLES SYSTÈME
-- ============================================

-- Table des notifications
CREATE TABLE notifications (
    notification_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL,
    notification_type VARCHAR(50) NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    read_at TIMESTAMP,
    related_entity_type VARCHAR(50),
    related_entity_id INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notification_user FOREIGN KEY (user_id) 
        REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE INDEX idx_notification_user ON notifications(user_id);
CREATE INDEX idx_notification_read ON notifications(is_read);
CREATE INDEX idx_notification_type ON notifications(notification_type);
CREATE INDEX idx_notification_created ON notifications(created_at);

-- Table des logs d'audit
CREATE TABLE audit_logs (
    log_id SERIAL PRIMARY KEY,
    user_id INTEGER,
    action_type VARCHAR(100) NOT NULL,
    entity_type VARCHAR(50),
    entity_id INTEGER,
    old_values JSONB,
    new_values JSONB,
    ip_address INET,
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_user FOREIGN KEY (user_id) 
        REFERENCES users(user_id) ON DELETE SET NULL
);

CREATE INDEX idx_audit_user ON audit_logs(user_id);
CREATE INDEX idx_audit_action ON audit_logs(action_type);
CREATE INDEX idx_audit_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_created ON audit_logs(created_at);
CREATE INDEX idx_audit_values ON audit_logs USING GIN (old_values, new_values);

-- ============================================
-- CONTRAINTE RÉFÉRENTIELLE DIFFÉRÉE
-- ============================================

-- Ajout de la contrainte de manager pour departments
ALTER TABLE departments
ADD CONSTRAINT fk_department_manager
FOREIGN KEY (manager_id) REFERENCES users(user_id) ON DELETE SET NULL;

-- ============================================
-- FONCTIONS ET TRIGGERS
-- ============================================

-- Fonction pour mettre à jour automatiquement updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers pour updated_at
CREATE TRIGGER update_departments_updated_at BEFORE UPDATE ON departments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_competencies_updated_at BEFORE UPDATE ON competencies
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_campaigns_updated_at BEFORE UPDATE ON campaigns
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_competency_responses_updated_at BEFORE UPDATE ON competency_responses
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_qualitative_comments_updated_at BEFORE UPDATE ON qualitative_comments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

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
('Subordinate', 'Collaborateur sous la responsabilité de l''évalué', 3),
('Internal_Client', 'Client interne - autre département', 4),
('Self', 'Auto-évaluation', 5);

-- Insertion des domaines de compétences
INSERT INTO competency_domains (domain_name, description, display_order) VALUES
('Leadership', 'Capacités de direction et d''influence', 1),
('Communication', 'Communication orale et écrite', 2),
('Technical_Skills', 'Compétences techniques métier', 3),
('Collaboration', 'Travail d''équipe et coopération', 4),
('Problem_Solving', 'Résolution de problèmes et innovation', 5),
('Time_Management', 'Organisation et gestion du temps', 6);

-- Insertion de compétences exemples
INSERT INTO competencies (domain_id, competency_name, description, evaluation_scale_type) VALUES
(1, 'Vision stratégique', 'Capacité à définir et communiquer une vision claire', 'numeric_5'),
(1, 'Prise de décision', 'Qualité et rapidité des décisions prises', 'numeric_5'),
(2, 'Communication orale', 'Clarté et efficacité de la communication verbale', 'numeric_5'),
(2, 'Écoute active', 'Capacité à écouter et comprendre les autres', 'numeric_5'),
(3, 'Expertise technique', 'Maîtrise des compétences techniques requises', 'numeric_5'),
(4, 'Esprit d''équipe', 'Contribution positive à la dynamique d''équipe', 'numeric_5'),
(4, 'Collaboration transverse', 'Capacité à travailler avec d''autres départements', 'numeric_5'),
(5, 'Analyse de problèmes', 'Capacité à identifier et analyser les problèmes', 'numeric_5'),
(5, 'Créativité', 'Proposition de solutions innovantes', 'numeric_5'),
(6, 'Respect des délais', 'Capacité à livrer dans les temps', 'numeric_5'),
(6, 'Priorisation', 'Capacité à prioriser les tâches efficacement', 'numeric_5');

-- ============================================
-- VUES UTILES
-- ============================================

-- Vue pour les statistiques de campagne
CREATE VIEW campaign_statistics AS
SELECT 
    c.campaign_id,
    c.campaign_name,
    c.start_date,
    c.end_date,
    cs.status_name,
    COUNT(DISTINCT cp.participant_id) as total_participants,
    COUNT(DISTINCT fi.invitation_id) as total_invitations,
    COUNT(DISTINCT CASE WHEN fi.completed = TRUE THEN fi.invitation_id END) as completed_responses,
    ROUND(
        CAST(COUNT(DISTINCT CASE WHEN fi.completed = TRUE THEN fi.invitation_id END) AS NUMERIC) / 
        NULLIF(COUNT(DISTINCT fi.invitation_id), 0) * 100, 2
    ) as completion_rate
FROM campaigns c
LEFT JOIN campaign_statuses cs ON c.status_id = cs.status_id
LEFT JOIN campaign_participants cp ON c.campaign_id = cp.campaign_id
LEFT JOIN feedback_invitations fi ON cp.participant_id = fi.participant_id
GROUP BY c.campaign_id, c.campaign_name, c.start_date, c.end_date, cs.status_name;

-- ============================================
-- FIN DU SCRIPT
-- ============================================
