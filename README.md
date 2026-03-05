# nextasyapps-infra

Infrastructure as Code for **Nextasy** — managed with Terraform, Supabase CLI, and GitHub Actions.

> ⚡ The architecture diagram below is **automatically updated** on every infrastructure change via GitHub Actions.

---

## Architecture

```mermaid
graph TB
    %% ── DNS ───────────────────────────────────────────
    subgraph DNS["🌐 DNS — Route 53 (nextasy.co)"]
        R53["Hosted Zone\nZ02633611RLKX976F44TP"]
        R53 -->|"A alias\ncouplesapp.nextasy.co"| CF_APP
        R53 -->|"CNAME *.nextasy.co"| CF_WEB
    end

    %% ── CDN ───────────────────────────────────────────
    subgraph CDN["☁️ CloudFront (AWS Dev — 092042970121)"]
        CF_APP["CouplesApp CDN\nERLTLXEW7WTTN\ndlr56cmovhfn0.cloudfront.net\nSSL: ACM *.nextasy.co"]
        CF_WEB["Nextasy Web CDN\nE640UP3DK37WP\nd3heh2lnt32ajw.cloudfront.net"]
        CF_REPORTS["Reports CDN\nEYJ1QFLZNTBP\nd1ej7mofi8sf.cloudfront.net\nSSL: CloudFront default"]
    end

    %% ── S3 ────────────────────────────────────────────
    subgraph S3["🪣 S3 Buckets"]
        S3_APP["couplesapp-dev-frontend\nReact SPA — CouplesApp"]
        S3_WEB["nextasy-co-website\nNextasy corporate site\n+ branch previews"]
        S3_E2E["couplesapp-e2e-reports\nE2E nightly reports\n+ ClawBot reports"]
    end

    CF_APP --> S3_APP
    CF_WEB --> S3_WEB
    CF_REPORTS --> S3_E2E

    %% ── Supabase ──────────────────────────────────────
    subgraph SB["🟢 Supabase (Nextasy Org)"]
        SB_DEV["couplesapp-dev\nklpshxvjzsdqolkrabvb\nsignup=ON · autoconfirm=ON"]
        SB_PROD["couplesapp-prod\nzbzesuuovfpjdqggambg\nsignup=OFF · autoconfirm=OFF"]

        subgraph SB_SCHEMA["Database Schema"]
            T1["profiles"]
            T2["couples"]
            T3["invitations"]
            T4["calendar_events"]
            T5["date_ideas"]
            T6["date_ideas_feedback"]
        end

        subgraph SB_FUNCTIONS["Edge Functions"]
            EF1["generate-date-ideas\n(OpenAI GPT-4o)"]
        end

        subgraph SB_CRON["pg_cron"]
            CRON1["Job #1\n0 6 * * * UTC\n→ generate-date-ideas"]
        end

        SB_DEV --> SB_SCHEMA
        SB_DEV --> SB_FUNCTIONS
        SB_DEV --> SB_CRON
    end

    %% ── ACM ───────────────────────────────────────────
    ACM["🔒 ACM Certificate\nnextasy.co + *.nextasy.co\nARN: c5e8a312"]
    ACM --> CF_APP

    %% ── GitHub Actions ────────────────────────────────
    subgraph GHA["⚙️ GitHub Actions"]
        GHA_TF["terraform-dev.yml\nterraform plan + apply"]
        GHA_SB["supabase-deploy.yml\ndb push + functions deploy"]
        GHA_DIAG["update-diagram.yml\nAuto-update this README\non every infra change"]
    end

    GHA_TF -->|"manages"| CDN
    GHA_TF -->|"manages"| S3
    GHA_TF -->|"manages"| DNS
    GHA_SB -->|"deploys"| SB_FUNCTIONS
    GHA_SB -->|"runs migrations"| SB_SCHEMA
    GHA_DIAG -->|"creates PR"| README["📄 README.md\n(this file)"]

    %% ── Apps ──────────────────────────────────────────
    subgraph APPS["📱 Applications"]
        APP_WEB["CouplesApp Web\nhttps://couplesapp.nextasy.co"]
        APP_IOS["CouplesApp iOS\n(Capacitor native)"]
        APP_SITE["nextasy.co\nhttps://www.nextasy.co"]
    end

    APP_WEB --> CF_APP
    APP_IOS --> SB_DEV
    APP_SITE --> CF_WEB
    APP_WEB --> SB_DEV

    %% ── SES ───────────────────────────────────────────
    SES["📧 AWS SES\ncouplesapp-noreply@nextasy.co\nnextasy.co verified domain"]
    APP_WEB -->|"invitation emails"| SES

    %% ── Styles ────────────────────────────────────────
    classDef aws fill:#FF9900,stroke:#232F3E,color:#000
    classDef supabase fill:#3ECF8E,stroke:#1a7a52,color:#000
    classDef cdn fill:#8B5CF6,stroke:#6D28D9,color:#fff
    classDef s3 fill:#569A31,stroke:#2d5c12,color:#fff
    classDef app fill:#0EA5E9,stroke:#0369a1,color:#fff
    classDef gha fill:#24292E,stroke:#444,color:#fff
    classDef dns fill:#E84393,stroke:#9d1365,color:#fff

    class R53,ACM,SES aws
    class SB_DEV,SB_PROD,T1,T2,T3,T4,T5,T6,EF1,CRON1 supabase
    class CF_APP,CF_WEB,CF_REPORTS cdn
    class S3_APP,S3_WEB,S3_E2E s3
    class APP_WEB,APP_IOS,APP_SITE app
    class GHA_TF,GHA_SB,GHA_DIAG gha
```

---

## Repository Structure

```
nextasyapps-infra/
├── terraform/
│   ├── environments/
│   │   └── dev/
│   │       ├── main.tf           # CouplesApp frontend (S3 + CloudFront + Route 53)
│   │       ├── nextasy-web.tf    # Nextasy corporate site
│   │       ├── e2e-reports.tf    # E2E & reports S3 bucket
│   │       ├── supabase.tf       # Supabase dev + prod projects
│   │       ├── backend.tf        # Remote state (S3 + DynamoDB)
│   │       └── variables.tf
│   └── modules/
│       ├── s3-spa/               # Reusable S3 + CloudFront SPA module
│       └── supabase-project/     # Reusable Supabase project module
├── supabase/
│   ├── migrations/
│   │   ├── 001_initial_schema.sql
│   │   ├── 002_calendar_integration.sql
│   │   ├── 003_dating_ideas.sql
│   │   └── 004_fix_profiles_rls_recursion.sql
│   └── functions/
│       └── generate-date-ideas/  # OpenAI-powered date suggestions
└── .github/workflows/
    ├── terraform-dev.yml         # Terraform plan + apply
    ├── supabase-deploy.yml       # DB migrations + Edge Functions
    └── update-diagram.yml        # Auto-update architecture diagram
```

---

## Environments

| Environment | AWS Account | Supabase Project | Domain |
|-------------|-------------|-----------------|--------|
| **dev** | `092042970121` | `klpshxvjzsdqolkrabvb` | `couplesapp.nextasy.co` |
| **prod** | `511930354489` | `zbzesuuovfpjdqggambg` | _(pending)_ |

---

## GitHub Actions Secrets Required

| Secret | Used By |
|--------|---------|
| `AWS_ACCESS_KEY_ID` | terraform-dev, update-diagram |
| `AWS_SECRET_ACCESS_KEY` | terraform-dev, update-diagram |
| `SUPABASE_ACCESS_TOKEN` | supabase-deploy, update-diagram |
| `SUPABASE_DEV_PROJECT_REF` | supabase-deploy |
| `SUPABASE_PROD_PROJECT_REF` | supabase-deploy |
| `TF_VAR_SUPABASE_DEV_DB_PASSWORD` | terraform-dev |
| `TF_VAR_SUPABASE_PROD_DB_PASSWORD` | terraform-dev |
| `TF_VAR_SUPABASE_ORG_ID` | terraform-dev |
| `ANTHROPIC_API_KEY` | update-diagram |

---

## Deployed Resources

### CloudFront Distributions
| ID | Domain | Origin | Purpose |
|----|--------|--------|---------|
| `ERLTLXEW7WTTN` | `dlr56cmovhfn0.cloudfront.net` | `couplesapp-dev-frontend` | CouplesApp web |
| `E640UP3DK37WP` | `d3heh2lnt32ajw.cloudfront.net` | `nextasy-co-website` | Nextasy website |
| `EYJ1QFLZNTBP` | `d1ej7mofi8sf.cloudfront.net` | `couplesapp-e2e-reports` | E2E + reports |

### S3 Buckets
| Bucket | Region | Purpose |
|--------|--------|---------|
| `couplesapp-dev-frontend` | us-east-1 | CouplesApp React SPA |
| `nextasy-co-website` | us-east-1 | nextasy.co + branch previews |
| `couplesapp-e2e-reports` | us-east-1 | E2E nightly + ClawBot reports |
| `nextasyapps-terraform-state-dev` | us-east-1 | Terraform remote state |

---

*Diagram last updated: 2026-03-05 — auto-maintained by [update-diagram.yml](.github/workflows/update-diagram.yml)*
