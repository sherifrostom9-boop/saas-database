-- ==========================================
-- Product B: Analytics & Automated Insights Schema
-- ==========================================

-- 1. جدول مقاييس وأداء مساحات العمل (Workspace Metrics)
CREATE TABLE product_b.workspace_metrics (
    metric_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id UUID NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
    metric_date DATE NOT NULL DEFAULT CURRENT_DATE,
    active_users_count INTEGER DEFAULT 0,
    completed_tasks_count INTEGER DEFAULT 0,
    ai_suggestions_used_count INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT unique_workspace_metric_date UNIQUE (workspace_id, metric_date)
);

-- 2. جدول تقارير الذكاء الاصطناعي الآلية (AI Generated Reports)
CREATE TABLE product_b.ai_reports (
    report_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id UUID NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
    project_id UUID REFERENCES core.projects(id) ON DELETE CASCADE,
    report_title VARCHAR(250) NOT NULL,
    report_content TEXT NOT NULL,
    
    -- التوافق مع معايير الاعتماد البشري للـ Core
    source_type core.source_type NOT NULL DEFAULT 'ai_generated',
    approval_status core.approval_status NOT NULL DEFAULT 'proposed',
    approved_by UUID REFERENCES core.users(id),
    approved_at TIMESTAMPTZ,
    
    generated_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    CONSTRAINT chk_report_ai_approval CHECK (
        approval_status <> 'approved' OR (approved_by IS NOT NULL AND approved_at IS NOT NULL)
    )
);