-- ==========================================
-- Product A: Client Requests & Proposals Schema
-- ==========================================

-- 1. جدول طلبات العملاء (Client Requests)
CREATE TABLE product_a.client_requests (
    request_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id UUID NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
    created_by_user_id UUID NOT NULL REFERENCES core.users(id),
    title VARCHAR(200) NOT NULL,
    brief TEXT,
    marketing_goals TEXT,
    target_audience TEXT,
    budget_min DECIMAL(12,2),
    budget_max DECIMAL(12,2),
    status VARCHAR(30) DEFAULT 'draft' CHECK (status IN ('draft', 'submitted', 'in_review', 'approved', 'rejected')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- 2. جدول عروض الأسعار وال استراتيجيات (Proposals)
CREATE TABLE product_a.proposals (
    proposal_proposal_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id UUID NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
    request_id UUID NOT NULL REFERENCES product_a.client_requests(request_id) ON DELETE CASCADE,
    title VARCHAR(200) NOT NULL,
    strategy_summary TEXT,
    total_price DECIMAL(14,2) NOT NULL,
    currency_code VARCHAR(10) DEFAULT 'USD',
    
    -- الاعتماد البشري (Human-in-the-Loop) متوافق مع معايير الـ Core
    approval_status core.approval_status NOT NULL DEFAULT 'proposed',
    approved_by UUID REFERENCES core.users(id),
    approved_at TIMESTAMPTZ,
    
    submitted_at TIMESTAMPTZ NOT NULL DEFAULT now(),

    -- قيد يمنع الاعتماد بدون مستخدم بشري وتاريخ
    CONSTRAINT chk_proposal_ai_approval CHECK (
        approval_status <> 'approved' OR (approved_by IS NOT NULL AND approved_at IS NOT NULL)
    )
);

-- 3. جدول عناصر ومحتوى العرض (Proposal Items)
CREATE TABLE product_a.proposal_items (
    item_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    proposal_id UUID NOT NULL REFERENCES product_a.proposals(proposal_proposal_id) ON DELETE CASCADE,
    service_title VARCHAR(150) NOT NULL,
    description TEXT,
    unit_price DECIMAL(12,2) NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    subtotal DECIMAL(14,2) NOT NULL
);