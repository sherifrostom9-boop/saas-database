-- ==========================================
-- 1. Core Tables & Schema Setup (Verified Reference)
-- ==========================================

CREATE TABLE core.workspaces (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    name text NOT NULL,
    product_code text NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE core.users (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    email text NOT NULL UNIQUE,
    password_hash text NOT NULL,
    first_name text,
    last_name text,
    avatar_url text,
    account_status text NOT NULL DEFAULT 'active' CHECK (account_status IN ('active', 'suspended', 'pending')),
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE core.roles (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    role_name text NOT NULL UNIQUE
);

CREATE TABLE core.workspace_members (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id uuid NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES core.users(id) ON DELETE CASCADE,
    role_id uuid NOT NULL REFERENCES core.roles(id),
    joined_at timestamptz NOT NULL DEFAULT now(),
    CONSTRAINT unique_workspace_user UNIQUE (workspace_id, user_id)
);

CREATE TABLE core.clients (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id uuid NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
    name text NOT NULL,
    contact_email text,
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE core.projects (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id uuid NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
    client_id uuid NOT NULL REFERENCES core.clients(id) ON DELETE CASCADE,
    manager_id uuid REFERENCES core.users(id),
    name text NOT NULL,
    status text NOT NULL DEFAULT 'planned' CHECK (status IN ('planned', 'active', 'on_hold', 'completed', 'cancelled')),
    created_at timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE core.phases (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id uuid NOT NULL REFERENCES core.projects(id) ON DELETE CASCADE,
    name text NOT NULL,
    order_index integer NOT NULL DEFAULT 1
);

CREATE TABLE core.tasks (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id uuid NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
    phase_id uuid NOT NULL REFERENCES core.phases(id) ON DELETE CASCADE,
    assigned_to uuid REFERENCES core.users(id),
    title text NOT NULL,
    status text NOT NULL DEFAULT 'todo' CHECK (status IN ('todo', 'in_progress', 'review', 'done')),
    source_type core.source_type NOT NULL DEFAULT 'manual',
    approval_status core.approval_status NOT NULL DEFAULT 'approved',
    approved_by uuid REFERENCES core.users(id),
    approved_at timestamptz,
    CONSTRAINT check_task_ai_approval CHECK (
        approval_status <> 'approved' OR (approved_by IS NOT NULL AND approved_at IS NOT NULL) OR source_type = 'manual'
    )
);

CREATE TABLE core.meetings (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    workspace_id uuid NOT NULL REFERENCES core.workspaces(id) ON DELETE CASCADE,
    title text NOT NULL,
    scheduled_at timestamptz NOT NULL,
    duration_minutes integer NOT NULL DEFAULT 30
);

CREATE TABLE core.meeting_summaries (
    id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
    meeting_id uuid NOT NULL REFERENCES core.meetings(id) ON DELETE CASCADE,
    summary_text text NOT NULL,
    source_type core.source_type NOT NULL DEFAULT 'ai_generated',
    approval_status core.approval_status NOT NULL DEFAULT 'proposed',
    approved_by uuid REFERENCES core.users(id),
    approved_at timestamptz,
    CONSTRAINT check_summary_ai_approval CHECK (
        approval_status <> 'approved' OR (approved_by IS NOT NULL AND approved_at IS NOT NULL)
    )
);

-- Derived Computed View
CREATE VIEW core.project_progress AS
SELECT
    p.id AS project_id,
    COALESCE(ROUND(100.0 * COUNT(t.id) FILTER (WHERE t.status = 'done') / NULLIF(COUNT(t.id), 0), 1), 0) AS progress_pct
FROM core.projects p
LEFT JOIN core.phases ph ON ph.project_id = p.id
LEFT JOIN core.tasks t ON t.phase_id = ph.id AND t.approval_status = 'approved'
GROUP BY p.id;