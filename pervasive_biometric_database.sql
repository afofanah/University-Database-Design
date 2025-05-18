
-- =============================================
-- Biometric Security Database for Pervasive Networks
-- =============================================
-- Author: A.J. Fofanah (PhD)
-- Email: a.fofanah@griffith.edu.au or dmitripeter.fofanah@gmail.com

-- =============================================
-- Enable foreign key constraints
PRAGMA foreign_keys = ON;

-- Users table stores basic information about system users
CREATE TABLE users (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    department VARCHAR(50),
    position VARCHAR(50),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    access_level INTEGER NOT NULL DEFAULT 1, -- 1: Basic, 2: Standard, 3: Admin, 4: Super Admin
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Biometric templates table - stores the actual biometric data templates
CREATE TABLE biometric_templates (
    template_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    biometric_type VARCHAR(30) NOT NULL, -- 'fingerprint', 'facial', 'iris', 'voice', 'behavioral', etc.
    template_data BLOB NOT NULL, -- encrypted biometric template data
    template_format VARCHAR(30) NOT NULL, -- format or algorithm used to create template
    quality_score FLOAT, -- quality metric of the template (0.0 to 1.0)
    enrollment_device_id INTEGER NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expiry_date TIMESTAMP, -- optional expiration date for the biometric
    revoked BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (enrollment_device_id) REFERENCES devices(device_id)
);

-- Devices table - to track all devices used for biometric capture and verification
CREATE TABLE devices (
    device_id INTEGER PRIMARY KEY AUTOINCREMENT,
    device_name VARCHAR(100) NOT NULL,
    device_type VARCHAR(50) NOT NULL, -- 'scanner', 'camera', 'microphone', etc.
    biometric_types_supported VARCHAR(100) NOT NULL, -- comma-separated list
    firmware_version VARCHAR(30),
    location_id INTEGER,
    status VARCHAR(20) NOT NULL DEFAULT 'active', -- 'active', 'maintenance', 'decommissioned'
    last_calibration_date TIMESTAMP,
    security_certification VARCHAR(50),
    FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

-- Locations table - physical locations where devices are installed
CREATE TABLE locations (
    location_id INTEGER PRIMARY KEY AUTOINCREMENT,
    location_name VARCHAR(100) NOT NULL,
    building VARCHAR(50),
    floor VARCHAR(10),
    room VARCHAR(20),
    security_zone INTEGER NOT NULL DEFAULT 1, -- 1: Low, 2: Medium, 3: High, 4: Critical
    access_requirements TEXT
);

-- Network nodes table - represents devices/servers in the pervasive network
CREATE TABLE network_nodes (
    node_id INTEGER PRIMARY KEY AUTOINCREMENT,
    node_name VARCHAR(100) NOT NULL,
    ip_address VARCHAR(45) NOT NULL, -- Supports IPv4 and IPv6
    mac_address VARCHAR(17),
    node_type VARCHAR(30) NOT NULL, -- 'server', 'router', 'access point', 'smart device', etc.
    operating_system VARCHAR(50),
    os_version VARCHAR(30),
    location_id INTEGER,
    security_level INTEGER NOT NULL DEFAULT 1, -- 1: Low, 2: Medium, 3: High, 4: Critical
    FOREIGN KEY (location_id) REFERENCES locations(location_id)
);

-- Authentication logs - records of authentication attempts
CREATE TABLE authentication_logs (
    log_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    biometric_type VARCHAR(30),
    device_id INTEGER,
    node_id INTEGER, -- The network node being accessed
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    auth_result VARCHAR(20) NOT NULL, -- 'success', 'failure_biometric', 'failure_policy', etc.
    confidence_score FLOAT, -- matching confidence (0.0 to 1.0)
    access_type VARCHAR(30) NOT NULL, -- 'physical', 'digital', 'resource', etc.
    session_id VARCHAR(64), -- For tracking complete sessions
    client_ip VARCHAR(45),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (device_id) REFERENCES devices(device_id),
    FOREIGN KEY (node_id) REFERENCES network_nodes(node_id)
);

-- Security policies table - defines authentication requirements
CREATE TABLE security_policies (
    policy_id INTEGER PRIMARY KEY AUTOINCREMENT,
    policy_name VARCHAR(100) NOT NULL,
    description TEXT,
    required_biometric_types VARCHAR(100) NOT NULL, -- comma-separated list, e.g., 'fingerprint,facial'
    min_confidence_threshold FLOAT NOT NULL DEFAULT 0.8, -- minimum acceptable match score
    multi_factor_required BOOLEAN NOT NULL DEFAULT FALSE,
    liveness_detection_required BOOLEAN NOT NULL DEFAULT FALSE,
    adaptive_auth_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    max_attempts INTEGER NOT NULL DEFAULT 3,
    lockout_duration_minutes INTEGER NOT NULL DEFAULT 15,
    applies_to_security_zones VARCHAR(20) NOT NULL, -- comma-separated list, e.g., '3,4'
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

-- Node policy mapping - links network nodes to security policies
CREATE TABLE node_policy_mapping (
    mapping_id INTEGER PRIMARY KEY AUTOINCREMENT,
    node_id INTEGER NOT NULL,
    policy_id INTEGER NOT NULL,
    priority INTEGER NOT NULL DEFAULT 1, -- for when multiple policies could apply
    FOREIGN KEY (node_id) REFERENCES network_nodes(node_id) ON DELETE CASCADE,
    FOREIGN KEY (policy_id) REFERENCES security_policies(policy_id) ON DELETE CASCADE,
    UNIQUE(node_id, policy_id)
);

-- Anomaly detection records
CREATE TABLE anomaly_records (
    anomaly_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    device_id INTEGER,
    node_id INTEGER,
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    anomaly_type VARCHAR(50) NOT NULL, -- 'multiple_failures', 'unusual_location', 'unusual_time', etc.
    risk_score FLOAT NOT NULL, -- algorithm-determined risk level (0.0 to 1.0)
    details TEXT, -- specific information about the anomaly
    resolved BOOLEAN NOT NULL DEFAULT FALSE,
    resolution_notes TEXT,
    resolution_timestamp TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (device_id) REFERENCES devices(device_id),
    FOREIGN KEY (node_id) REFERENCES network_nodes(node_id)
);

-- Biometric capture logs - raw data about capture attempts
CREATE TABLE biometric_capture_logs (
    capture_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER,
    device_id INTEGER NOT NULL,
    biometric_type VARCHAR(30) NOT NULL,
    capture_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    quality_score FLOAT, -- quality of the captured sample
    environmental_factors TEXT, -- JSON or text describing capture conditions
    capture_duration_ms INTEGER,
    capture_result VARCHAR(20) NOT NULL, -- 'success', 'failure_quality', 'failure_device', etc.
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (device_id) REFERENCES devices(device_id)
);

-- Behavioral biometrics table - for continuous authentication patterns
CREATE TABLE behavioral_biometrics (
    pattern_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    pattern_type VARCHAR(50) NOT NULL, -- 'typing_rhythm', 'gait', 'gesture', 'app_usage', etc.
    confidence_threshold FLOAT NOT NULL DEFAULT 0.75,
    pattern_data BLOB NOT NULL, -- compressed and encrypted behavior pattern data
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Continuous authentication sessions
CREATE TABLE continuous_auth_sessions (
    session_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    node_id INTEGER NOT NULL,
    start_timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    end_timestamp TIMESTAMP,
    initial_auth_method VARCHAR(50) NOT NULL, -- 'fingerprint', 'facial', 'multi-factor', etc.
    continuous_auth_types VARCHAR(100), -- comma-separated list of behavioral methods in use
    session_status VARCHAR(20) NOT NULL DEFAULT 'active', -- 'active', 'terminated', 'expired', 'suspicious'
    termination_reason VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (node_id) REFERENCES network_nodes(node_id)
);

-- Continuous authentication events within a session
CREATE TABLE continuous_auth_events (
    event_id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id INTEGER NOT NULL,
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    auth_type VARCHAR(50) NOT NULL, -- specific behavioral type checked
    confidence_score FLOAT NOT NULL,
    auth_result VARCHAR(20) NOT NULL, -- 'maintain', 'warning', 'reauthenticate', 'terminate'
    context_data TEXT, -- JSON with contextual information
    FOREIGN KEY (session_id) REFERENCES continuous_auth_sessions(session_id) ON DELETE CASCADE
);

-- Access control lists for resource authorization
CREATE TABLE access_control_lists (
    acl_id INTEGER PRIMARY KEY AUTOINCREMENT,
    resource_type VARCHAR(50) NOT NULL, -- 'file', 'database', 'service', 'physical_area', etc.
    resource_id VARCHAR(100) NOT NULL, -- identifier for the specific resource
    user_id INTEGER, -- can be NULL if role-based
    role_id INTEGER, -- can be NULL if user-based
    permission_level VARCHAR(20) NOT NULL, -- 'read', 'write', 'execute', 'full', etc.
    biometric_verification_required BOOLEAN NOT NULL DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE,
    UNIQUE(resource_type, resource_id, user_id, role_id)
);

-- Roles for role-based access control
CREATE TABLE roles (
    role_id INTEGER PRIMARY KEY AUTOINCREMENT,
    role_name VARCHAR(50) NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- User-role assignments
CREATE TABLE user_roles (
    assignment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    role_id INTEGER NOT NULL,
    assigned_by INTEGER, -- user_id of administrator who assigned the role
    assigned_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expiry_date TIMESTAMP, -- optional expiration date
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (role_id) REFERENCES roles(role_id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_by) REFERENCES users(user_id),
    UNIQUE(user_id, role_id)
);

-- Audit logs for all security-relevant actions
CREATE TABLE audit_logs (
    audit_id INTEGER PRIMARY KEY AUTOINCREMENT,
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    user_id INTEGER,
    action_type VARCHAR(50) NOT NULL, -- 'login', 'logout', 'access', 'modify', 'delete', 'admin', etc.
    target_type VARCHAR(50), -- type of resource affected
    target_id VARCHAR(100), -- identifier of the specific resource
    action_details TEXT, -- detailed description or JSON with specifics
    client_ip VARCHAR(45),
    session_id VARCHAR(64),
    success BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Admin operations log for privileged activities
CREATE TABLE admin_operations (
    operation_id INTEGER PRIMARY KEY AUTOINCREMENT,
    admin_user_id INTEGER NOT NULL,
    timestamp TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    operation_type VARCHAR(50) NOT NULL, -- 'user_create', 'policy_change', 'template_delete', etc.
    target_table VARCHAR(50), -- the table affected
    target_id INTEGER, -- the primary key in that table
    previous_state TEXT, -- JSON representation of previous data state
    new_state TEXT, -- JSON representation of new data state
    reason TEXT, -- admin's stated reason for change
    approval_id INTEGER, -- for changes requiring secondary approval
    FOREIGN KEY (admin_user_id) REFERENCES users(user_id),
    FOREIGN KEY (approval_id) REFERENCES admin_approvals(approval_id)
);

-- Admin approvals for critical changes
CREATE TABLE admin_approvals (
    approval_id INTEGER PRIMARY KEY AUTOINCREMENT,
    requested_by INTEGER NOT NULL,
    approved_by INTEGER,
    requested_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    approved_at TIMESTAMP,
    operation_type VARCHAR(50) NOT NULL,
    operation_details TEXT,
    status VARCHAR(20) NOT NULL DEFAULT 'pending', -- 'pending', 'approved', 'rejected', 'expired'
    expiry_timestamp TIMESTAMP,
    FOREIGN KEY (requested_by) REFERENCES users(user_id),
    FOREIGN KEY (approved_by) REFERENCES users(user_id)
);

-- System settings table
CREATE TABLE system_settings (
    setting_id INTEGER PRIMARY KEY AUTOINCREMENT,
    setting_name VARCHAR(100) NOT NULL UNIQUE,
    setting_value TEXT NOT NULL,
    setting_type VARCHAR(20) NOT NULL, -- 'security', 'performance', 'notification', etc.
    description TEXT,
    modified_by INTEGER,
    modified_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (modified_by) REFERENCES users(user_id)
);

-- Create indexes for frequently queried columns
CREATE INDEX idx_auth_logs_user_timestamp ON authentication_logs(user_id, timestamp);
CREATE INDEX idx_auth_logs_device_timestamp ON authentication_logs(device_id, timestamp);
CREATE INDEX idx_auth_logs_result ON authentication_logs(auth_result);
CREATE INDEX idx_biometric_templates_user_type ON biometric_templates(user_id, biometric_type);
CREATE INDEX idx_anomaly_timestamp ON anomaly_records(timestamp);
CREATE INDEX idx_continuous_auth_session ON continuous_auth_events(session_id);
CREATE INDEX idx_audit_user_action ON audit_logs(user_id, action_type);
CREATE INDEX idx_audit_timestamp ON audit_logs(timestamp);

-- Create views for common queries
CREATE VIEW view_active_sessions AS
SELECT s.session_id, u.username, u.full_name, n.node_name, s.start_timestamp, 
       s.initial_auth_method, s.continuous_auth_types, s.session_status
FROM continuous_auth_sessions s
JOIN users u ON s.user_id = u.user_id
JOIN network_nodes n ON s.node_id = n.node_id
WHERE s.end_timestamp IS NULL;

CREATE VIEW view_failed_auth_attempts AS
SELECT l.log_id, u.username, u.full_name, d.device_name, n.node_name, 
       l.timestamp, l.auth_result, l.biometric_type, l.confidence_score
FROM authentication_logs l
JOIN users u ON l.user_id = u.user_id
JOIN devices d ON l.device_id = d.device_id
JOIN network_nodes n ON l.node_id = n.node_id
WHERE l.auth_result LIKE 'failure%'
ORDER BY l.timestamp DESC;

CREATE VIEW view_user_biometrics AS
SELECT u.user_id, u.username, u.full_name, 
       GROUP_CONCAT(DISTINCT bt.biometric_type) AS enrolled_biometrics,
       COUNT(bt.template_id) AS template_count
FROM users u
LEFT JOIN biometric_templates bt ON u.user_id = bt.user_id
WHERE bt.revoked = FALSE
GROUP BY u.user_id;

-- Sample trigger to automatically update 'updated_at' timestamps
CREATE TRIGGER update_user_timestamp AFTER UPDATE ON users
BEGIN
    UPDATE users SET updated_at = CURRENT_TIMESTAMP WHERE user_id = NEW.user_id;
END;

-- Sample trigger to log template changes
CREATE TRIGGER log_template_modification AFTER UPDATE ON biometric_templates
BEGIN
    INSERT INTO audit_logs (user_id, action_type, target_type, target_id, action_details)
    VALUES ((SELECT user_id FROM sqlite_master LIMIT 1), -- This would be replaced with actual session user in real implementation
            'modify', 
            'biometric_template', 
            NEW.template_id, 
            'Template updated');
END;