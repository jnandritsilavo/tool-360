-- ============================================
-- Gestionnaire de Feedbacks 360°
-- Script de création de base de données SQL Server
-- ============================================

-- Création de la base de données
CREATE DATABASE feedback360
GO

USE feedback360
GO

-- ============================================
-- TABLES DE RÉFÉRENCE
-- ============================================

-- Table des rôles utilisateurs
CREATE TABLE roles (
    role_id INT IDENTITY(1,1) PRIMARY KEY,
    role_name NVARCHAR(50) NOT NULL UNIQUE,
    description NVARCHAR(MAX),
    created_at DATETIME2 DEFAULT GETDATE()
);

CREATE INDEX idx_role_name ON roles(role_name);
GO

-- Table des départements
CREATE TABLE departments (
    department_id INT IDENTITY(1,1) PRIMARY KEY,
    department_name NVARCHAR(100) NOT NULL,
    description NVARCHAR(MAX),
    manager_id INT,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
);

CREATE INDEX idx_dept_name ON departments(department_name);
GO

-- Table des domaines de compétences
CREATE TABLE competency_domains (
    domain_id INT IDENTITY(1,1) PRIMARY KEY,
    domain_name NVARCHAR(100) NOT NULL,
    description NVARCHAR(MAX),
    display_order INT DEFAULT 0,
    is_active BIT DEFAULT 1,
    created_at DATETIME2 DEFAULT GETDATE()
);

CREATE INDEX idx_domain_name ON competency_domains(domain_name);
CREATE INDEX idx_display_order ON competency_domains(display_order);
GO

-- Table des compétences
CREATE TABLE competencies (
    competency_id INT IDENTITY(1,1) PRIMARY KEY,
    domain_id INT NOT NULL,
    competency_name NVARCHAR(150) NOT NULL,
    description NVARCHAR(MAX),
    evaluation_scale_type NVARCHAR(20) DEFAULT 'numeric_5' CHECK (evaluation_scale_type IN ('numeric_5', 'numeric_10', 'qualitative')),
    is_active BIT DEFAULT 1,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT fk_competency_domain FOREIGN KEY (domain_id) 
        REFERENCES competency_domains(domain_id) ON DELETE CASCADE
);

CREATE INDEX idx_comp_domain ON competencies(domain_id);
CREATE INDEX idx_competency_name ON competencies(competency_name);
GO

-- ============================================
-- TABLES UTILISATEURS
-- ============================================

-- Table des utilisateurs
CREATE TABLE users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    email NVARCHAR(255) NOT NULL UNIQUE,
    password_hash NVARCHAR(255) NOT NULL,
    first_name NVARCHAR(100) NOT NULL,
    last_name NVARCHAR(100) NOT NULL,
    department_id INT,
    job_title NVARCHAR(150),
    hire_date DATE,
    is_active BIT DEFAULT 1,
    last_login DATETIME2,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT fk_user_department FOREIGN KEY (department_id) 
        REFERENCES departments(department_id) ON DELETE SET NULL
);

CREATE INDEX idx_email ON users(email);
CREATE INDEX idx_name ON users(last_name, first_name);
CREATE INDEX idx_user_department ON users(department_id);
GO

-- Table d'association utilisateurs-rôles (many-to-many)
CREATE TABLE user_roles (
    user_role_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    role_id INT NOT NULL,
    assigned_at DATETIME2 DEFAULT GETDATE(),
    assigned_by INT,
    CONSTRAINT fk_userrole_user FOREIGN KEY (user_id) 
        REFERENCES users(user_id) ON DELETE CASCADE,
    CONSTRAINT fk_userrole_role FOREIGN KEY (role_id) 
        REFERENCES roles(role_id) ON DELETE CASCADE,
    CONSTRAINT fk_userrole_assigner FOREIGN KEY (assigned_by) 
        REFERENCES users(user_id),
    CONSTRAINT unique_user_role UNIQUE (user_id, role_id)
);

CREATE INDEX idx_userrole_user ON user_roles(user_id);
CREATE INDEX idx_userrole_role ON user_roles(role_id);
GO

-- ============================================
-- TABLES CAMPAGNES
-- ============================================

-- Table des statuts de campagnes
CREATE TABLE campaign_statuses (
    status_id INT IDENTITY(1,1) PRIMARY KEY,
    status_name NVARCHAR(50) NOT NULL UNIQUE,
    description NVARCHAR(MAX)
);

CREATE INDEX idx_status_name ON campaign_statuses(status_name);
GO

-- Table des campagnes d'évaluation
CREATE TABLE campaigns (
    campaign_id INT IDENTITY(1,1) PRIMARY KEY,
    campaign_name NVARCHAR(200) NOT NULL,
    description NVARCHAR(MAX),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    status_id INT NOT NULL,
    min_respondents_threshold INT DEFAULT 3,
    created_by INT NOT NULL,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT fk_campaign_status FOREIGN KEY (status_id) 
        REFERENCES campaign_statuses(status_id),
    CONSTRAINT fk_campaign_creator FOREIGN KEY (created_by) 
        REFERENCES users(user_id)
);

CREATE INDEX idx_campaign_name ON campaigns(campaign_name);
CREATE INDEX idx_campaign_dates ON campaigns(start_date, end_date);
CREATE INDEX idx_campaign_status ON campaigns(status_id);
CREATE INDEX idx_campaign_creator ON campaigns(created_by);
GO

-- Table des catégories de répondants
CREATE TABLE respondent_categories (
    category_id INT IDENTITY(1,1) PRIMARY KEY,
    category_name NVARCHAR(50) NOT NULL UNIQUE,
    description NVARCHAR(MAX),
    display_order INT DEFAULT 0
);

CREATE INDEX idx_category_name ON respondent_categories(category_name);
GO

-- Table des participants évalués dans une campagne
CREATE TABLE campaign_participants (
    participant_id INT IDENTITY(1,1) PRIMARY KEY,
    campaign_id INT NOT NULL,
    user_id INT NOT NULL,
    notification_sent BIT DEFAULT 0,
    notification_sent_at DATETIME2,
    report_generated BIT DEFAULT 0,
    report_generated_at DATETIME2,
    report_viewed BIT DEFAULT 0,
    report_viewed_at DATETIME2,
    created_at DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT fk_participant_campaign FOREIGN KEY (campaign_id) 
        REFERENCES campaigns(campaign_id) ON DELETE CASCADE,
    CONSTRAINT fk_participant_user FOREIGN KEY (user_id) 
        REFERENCES users(user_id),
    CONSTRAINT unique_campaign_participant UNIQUE (campaign_id, user_id)
);

CREATE INDEX idx_participant_campaign ON campaign_participants(campaign_id);
CREATE INDEX idx_participant_user ON campaign_participants(user_id);
GO

-- Table des compétences associées à une campagne
CREATE TABLE campaign_competencies (
    campaign_competency_id INT IDENTITY(1,1) PRIMARY KEY,
    campaign_id INT NOT NULL,
    competency_id INT NOT NULL,
    is_mandatory BIT DEFAULT 1,
    weight DECIMAL(5,2) DEFAULT 1.00,
    created_at DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT fk_campcomp_campaign FOREIGN KEY (campaign_id) 
        REFERENCES campaigns(campaign_id) ON DELETE CASCADE,
    CONSTRAINT fk_campcomp_competency FOREIGN KEY (competency_id) 
        REFERENCES competencies(competency_id),
    CONSTRAINT unique_campaign_competency UNIQUE (campaign_id, competency_id)
);

CREATE INDEX idx_campcomp_campaign ON campaign_competencies(campaign_id);
CREATE INDEX idx_campcomp_competency ON campaign_competencies(competency_id);
GO

-- ============================================
-- TABLES FEEDBACKS
-- ============================================

-- Table des invitations à donner un feedback
CREATE TABLE feedback_invitations (
    invitation_id INT IDENTITY(1,1) PRIMARY KEY,
    campaign_id INT NOT NULL,
    participant_id INT NOT NULL,
    respondent_id INT NOT NULL,
    category_id INT NOT NULL,
    invitation_token NVARCHAR(255) NOT NULL UNIQUE,
    invited_at DATETIME2 DEFAULT GETDATE(),
    reminded_at DATETIME2,
    reminder_count INT DEFAULT 0,
    completed BIT DEFAULT 0,
    completed_at DATETIME2,
    CONSTRAINT fk_invitation_campaign FOREIGN KEY (campaign_id) 
        REFERENCES campaigns(campaign_id) ON DELETE CASCADE,
    CONSTRAINT fk_invitation_participant FOREIGN KEY (participant_id) 
        REFERENCES campaign_participants(participant_id),
    CONSTRAINT fk_invitation_respondent FOREIGN KEY (respondent_id) 
        REFERENCES users(user_id),
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
GO

-- Table des réponses aux évaluations de compétences
CREATE TABLE competency_responses (
    response_id INT IDENTITY(1,1) PRIMARY KEY,
    invitation_id INT NOT NULL,
    competency_id INT NOT NULL,
    score DECIMAL(5,2),
    qualitative_value NVARCHAR(50),
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT fk_response_invitation FOREIGN KEY (invitation_id) 
        REFERENCES feedback_invitations(invitation_id) ON DELETE CASCADE,
    CONSTRAINT fk_response_competency FOREIGN KEY (competency_id) 
        REFERENCES competencies(competency_id)
);

CREATE INDEX idx_response_invitation ON competency_responses(invitation_id);
CREATE INDEX idx_response_competency ON competency_responses(competency_id);
GO

-- Table des commentaires qualitatifs
CREATE TABLE qualitative_comments (
    comment_id INT IDENTITY(1,1) PRIMARY KEY,
    invitation_id INT NOT NULL,
    question_text NVARCHAR(MAX) NOT NULL,
    comment_text NVARCHAR(MAX),
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT fk_comment_invitation FOREIGN KEY (invitation_id) 
        REFERENCES feedback_invitations(invitation_id) ON DELETE CASCADE
);

CREATE INDEX idx_comment_invitation ON qualitative_comments(invitation_id);
GO

-- ============================================
-- TABLES AGRÉGATION ET RAPPORTS
-- ============================================

-- Table des résultats agrégés par compétence et catégorie
CREATE TABLE aggregated_results (
    aggregated_id INT IDENTITY(1,1) PRIMARY KEY,
    participant_id INT NOT NULL,
    competency_id INT NOT NULL,
    category_id INT NOT NULL,
    response_count INT NOT NULL,
    average_score DECIMAL(5,2),
    median_score DECIMAL(5,2),
    std_deviation DECIMAL(5,2),
    min_score DECIMAL(5,2),
    max_score DECIMAL(5,2),
    is_displayable BIT DEFAULT 0,
    calculated_at DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT fk_aggregated_participant FOREIGN KEY (participant_id) 
        REFERENCES campaign_participants(participant_id) ON DELETE CASCADE,
    CONSTRAINT fk_aggregated_competency FOREIGN KEY (competency_id) 
        REFERENCES competencies(competency_id),
    CONSTRAINT fk_aggregated_category FOREIGN KEY (category_id) 
        REFERENCES respondent_categories(category_id),
    CONSTRAINT unique_aggregation UNIQUE (participant_id, competency_id, category_id)
);

CREATE INDEX idx_aggregated_participant ON aggregated_results(participant_id);
CREATE INDEX idx_aggregated_competency ON aggregated_results(competency_id);
CREATE INDEX idx_aggregated_category ON aggregated_results(category_id);
CREATE INDEX idx_aggregated_displayable ON aggregated_results(is_displayable);
GO

-- Table des rapports générés
CREATE TABLE generated_reports (
    report_id INT IDENTITY(1,1) PRIMARY KEY,
    participant_id INT NOT NULL,
    report_file_path NVARCHAR(500),
    report_format NVARCHAR(20) DEFAULT 'PDF' CHECK (report_format IN ('PDF', 'HTML', 'DOCX')),
    total_respondents INT,
    completion_rate DECIMAL(5,2),
    generated_at DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT fk_report_participant FOREIGN KEY (participant_id) 
        REFERENCES campaign_participants(participant_id) ON DELETE CASCADE
);

CREATE INDEX idx_report_participant ON generated_reports(participant_id);
CREATE INDEX idx_report_generated ON generated_reports(generated_at);
GO

-- ============================================
-- TABLES SYSTÈME
-- ============================================

-- Table des notifications
CREATE TABLE notifications (
    notification_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    notification_type NVARCHAR(50) NOT NULL,
    title NVARCHAR(200) NOT NULL,
    message NVARCHAR(MAX),
    is_read BIT DEFAULT 0,
    read_at DATETIME2,
    related_entity_type NVARCHAR(50),
    related_entity_id INT,
    created_at DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT fk_notification_user FOREIGN KEY (user_id) 
        REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE INDEX idx_notification_user ON notifications(user_id);
CREATE INDEX idx_notification_read ON notifications(is_read);
CREATE INDEX idx_notification_type ON notifications(notification_type);
CREATE INDEX idx_notification_created ON notifications(created_at);
GO

-- Table des logs d'audit
CREATE TABLE audit_logs (
    log_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT,
    action_type NVARCHAR(100) NOT NULL,
    entity_type NVARCHAR(50),
    entity_id INT,
    old_values NVARCHAR(MAX),
    new_values NVARCHAR(MAX),
    ip_address NVARCHAR(45),
    user_agent NVARCHAR(MAX),
    created_at DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT fk_audit_user FOREIGN KEY (user_id) 
        REFERENCES users(user_id) ON DELETE SET NULL
);

CREATE INDEX idx_audit_user ON audit_logs(user_id);
CREATE INDEX idx_audit_action ON audit_logs(action_type);
CREATE INDEX idx_audit_entity ON audit_logs(entity_type, entity_id);
CREATE INDEX idx_audit_created ON audit_logs(created_at);
GO

-- ============================================
-- CONTRAINTE RÉFÉRENTIELLE DIFFÉRÉE
-- ============================================

-- Ajout de la contrainte de manager pour departments
ALTER TABLE departments
ADD CONSTRAINT fk_department_manager
FOREIGN KEY (manager_id) REFERENCES users(user_id) ON DELETE SET NULL;
GO

-- ============================================
-- TRIGGERS POUR UPDATED_AT
-- ============================================

-- Trigger pour departments
CREATE TRIGGER trg_update_departments
ON departments
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE departments
    SET updated_at = GETDATE()
    FROM departments d
    INNER JOIN inserted i ON d.department_id = i.department_id;
END;
GO

-- Trigger pour competencies
CREATE TRIGGER trg_update_competencies
ON competencies
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE competencies
    SET updated_at = GETDATE()
    FROM competencies c
    INNER JOIN inserted i ON c.competency_id = i.competency_id;
END;
GO

-- Trigger pour users
CREATE TRIGGER trg_update_users
ON users
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE users
    SET updated_at = GETDATE()
    FROM users u
    INNER JOIN inserted i ON u.user_id = i.user_id;
END;
GO

-- Trigger pour campaigns
CREATE TRIGGER trg_update_campaigns
ON campaigns
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE campaigns
    SET updated_at = GETDATE()
    FROM campaigns c
    INNER JOIN inserted i ON c.campaign_id = i.campaign_id;
END;
GO

-- Trigger pour competency_responses
CREATE TRIGGER trg_update_competency_responses
ON competency_responses
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE competency_responses
    SET updated_at = GETDATE()
    FROM competency_responses cr
    INNER JOIN inserted i ON cr.response_id = i.response_id;
END;
GO

-- Trigger pour qualitative_comments
CREATE TRIGGER trg_update_qualitative_comments
ON qualitative_comments
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE qualitative_comments
    SET updated_at = GETDATE()
    FROM qualitative_comments qc
    INNER JOIN inserted i ON qc.comment_id = i.comment_id;
END;
GO

-- ============================================
-- DONNÉES INITIALES
-- ============================================

-- Insertion des rôles par défaut
INSERT INTO roles (role_name, description) VALUES
('Admin', 'Administrateur système avec tous les privilèges'),
('HR_Manager', 'Responsable RH - Gestion des campagnes'),
('Manager', 'Manager - Peut évaluer ses collaborateurs'),
('Employee', 'Employé - Peut donner et recevoir des feedbacks');
GO

-- Insertion des statuts de campagnes
INSERT INTO campaign_statuses (status_name, description) VALUES
('Draft', 'Campagne en cours de création'),
('Active', 'Campagne active - collecte en cours'),
('Closed', 'Campagne terminée - collecte fermée'),
('Archived', 'Campagne archivée');
GO

-- Insertion des catégories de répondants
INSERT INTO respondent_categories (category_name, description, display_order) VALUES
('Manager', 'Responsable hiérarchique direct', 1),
('Peer', 'Collègue de même niveau', 2),
('Subordinate', 'Collaborateur sous la responsabilité de l''évalué', 3),
('Internal_Client', 'Client interne - autre département', 4),
('Self', 'Auto-évaluation', 5);
GO

-- Insertion des domaines de compétences
INSERT INTO competency_domains (domain_name, description, display_order) VALUES
('Leadership', 'Capacités de direction et d''influence', 1),
('Communication', 'Communication orale et écrite', 2),
('Technical_Skills', 'Compétences techniques métier', 3),
('Collaboration', 'Travail d''équipe et coopération', 4),
('Problem_Solving', 'Résolution de problèmes et innovation', 5),
('Time_Management', 'Organisation et gestion du temps', 6);
GO

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
GO

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
    COUNT(DISTINCT CASE WHEN fi.completed = 1 THEN fi.invitation_id END) as completed_responses,
    CAST(
        ROUND(
            CAST(COUNT(DISTINCT CASE WHEN fi.completed = 1 THEN fi.invitation_id END) AS FLOAT) / 
            NULLIF(COUNT(DISTINCT fi.invitation_id), 0) * 100, 2
        ) AS DECIMAL(5,2)
    ) as completion_rate
FROM campaigns c
LEFT JOIN campaign_statuses cs ON c.status_id = cs.status_id
LEFT JOIN campaign_participants cp ON c.campaign_id = cp.campaign_id
LEFT JOIN feedback_invitations fi ON cp.participant_id = fi.participant_id
GROUP BY c.campaign_id, c.campaign_name, c.start_date, c.end_date, cs.status_name;
GO

-- ============================================
-- FIN DU SCRIPT
-- ============================================
