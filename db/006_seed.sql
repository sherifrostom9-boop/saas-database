-- ==========================================
-- 006_seed.sql: Initial Seeding Data
-- ==========================================

-- 1. إضافة مساحة عمل افتراضية رئيسية
INSERT INTO core.workspaces (id, name, product_code) 
VALUES ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Default Enterprise Workspace', 'CORE-SAAS')
ON CONFLICT DO NOTHING;

-- 2. إضافة أدوار النظام الأساسية
INSERT INTO core.roles (id, role_name) VALUES 
('b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22', 'Administrator'),
('c2eebc99-9c0b-4ef8-bb6d-6bb9bd380c33', 'Member')
ON CONFLICT DO NOTHING;

-- 3. إضافة مستخدم مدير افتراضي
INSERT INTO core.users (id, email, password_hash, first_name, last_name, account_status)
VALUES (
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380d44',
    'admin@saas-reference.com',
    '$2b$10$encrypted_dummy_hash_for_testing',
    'System',
    'Administrator',
    'active'
)
ON CONFLICT DO NOTHING;

-- 4. ربط المستخدم بمسؤول مساحة العمل
INSERT INTO core.workspace_members (workspace_id, user_id, role_id)
VALUES (
    'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11',
    'd3eebc99-9c0b-4ef8-bb6d-6bb9bd380d44',
    'b1eebc99-9c0b-4ef8-bb6d-6bb9bd380b22'
)
ON CONFLICT DO NOTHING;