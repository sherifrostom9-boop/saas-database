-- 1. إنشاء النطاقات (Schemas) الأساسية
CREATE SCHEMA IF NOT EXISTS core;
CREATE SCHEMA IF NOT EXISTS product_a;
CREATE SCHEMA IF NOT EXISTS product_b;

-- 2. إنشاء أنواع البيانات المخصصة (Enums) للاستخدام المشترك
CREATE TYPE core.approval_status AS ENUM ('proposed', 'approved', 'rejected');
CREATE TYPE core.source_type AS ENUM ('manual', 'ai_generated');