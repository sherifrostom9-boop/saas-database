-- ==========================================
-- 005_roles.sql: Database-level Roles & Security
-- ==========================================

-- 1. إنشاء مستخدمي التطبيقات والصلاحيات على مستوى الخادم
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'team_a_app') THEN
        CREATE ROLE team_a_app LOGIN PASSWORD 'team_a_secure_pass';
    END IF;
    
    IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'team_b_app') THEN
        CREATE ROLE team_b_app LOGIN PASSWORD 'team_b_secure_pass';
    END IF;
END $$;

-- 2. منح صلاحيات الاستخدام على النطاقات (Schemas)
GRANT USAGE ON SCHEMA core, product_a TO team_a_app;
GRANT USAGE ON SCHEMA core, product_b TO team_b_app;

-- 3. منح صلاحيات التعامل مع الجداول بداخل النطاقات
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA core TO team_a_app, team_b_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA product_a TO team_a_app;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA product_b TO team_b_app;