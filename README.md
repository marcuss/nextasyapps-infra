# nextasyapps-infra

Infrastructure as Code for **Nextasy** — managed with Terraform, Supabase CLI, and GitHub Actions.

> ⚡ The architecture diagrams below are **automatically updated** on every infrastructure change via GitHub Actions.

---

## 🗺️ Architecture Overview

Five focused diagrams — each styled to its brand — give you a complete picture of the infrastructure at every level of detail.

---

### Diagram 1 — 10,000-foot View

High-level view of how all the moving parts relate to each other.

```mermaid
graph TB
    subgraph APPS["📱 Applications"]
        APP_WEB["💗 CouplesApp Web\ncouplesapp.nextasy.co"]
        APP_IOS["📱 CouplesApp iOS\nCapacitor native"]
        APP_SITE["🌐 nextasy.co\nCorporate site"]
    end

    subgraph GH["🐙 GitHub"]
        GH_CODE["Source Code\n& Workflows"]
    end

    subgraph AWS["☁️ AWS"]
        AWS_INFRA["S3 · CloudFront\nRoute53 · SES · ACM"]
    end

    subgraph SB["🟢 Supabase"]
        SB_INFRA["Postgres · Auth\nEdge Functions · Crons"]
    end

    GH_CODE -->|"CI/CD deploys"| AWS_INFRA
    GH_CODE -->|"CI/CD deploys"| SB_INFRA
    APP_WEB --> AWS_INFRA
    APP_WEB --> SB_INFRA
    APP_IOS --> SB_INFRA
    APP_SITE --> AWS_INFRA

    classDef app fill:#f43f5e,stroke:#be123c,stroke-width:2px,color:#ffffff
    classDef github fill:#24292E,stroke:#0366D6,stroke-width:2px,color:#ffffff
    classDef awsStyle fill:#FF9900,stroke:#232F3E,stroke-width:2px,color:#232F3E,font-weight:bold
    classDef supabase fill:#3ECF8E,stroke:#1a7a52,stroke-width:2px,color:#0d3d27,font-weight:bold

    class APP_WEB,APP_IOS,APP_SITE app
    class GH_CODE github
    class AWS_INFRA awsStyle
    class SB_INFRA supabase
```

---

### Diagram 2 — GitHub Repos & CI/CD

Source code repositories, workflows, and the automation that keeps everything running.

```mermaid
graph LR
    subgraph REPOS["🐙 GitHub Repositories"]
        R_INFRA["🏗️ nextasyapps-infra\nTerraform · Supabase · GHA"]
        R_WEB["💗 couplesapp\nReact · Capacitor"]
        R_SITE["🌐 nextasy-web\nMarketing site"]
    end

    subgraph SECRETS["🔐 Repository Secrets"]
        SEC1["AWS_ACCESS_KEY_ID\nAWS_SECRET_ACCESS_KEY"]
        SEC2["SUPABASE_ACCESS_TOKEN\nSUPABASE_*_PROJECT_REF"]
        SEC3["TF_VAR_SUPABASE_*\nANTHROPIC_API_KEY"]
    end

    subgraph WORKFLOWS["⚙️ GitHub Actions Workflows"]
        WF_TF["🟠 terraform-dev.yml\nterraform plan + apply\n→ AWS infra changes"]
        WF_SB["🟢 supabase-deploy.yml\ndb push + fn deploy\n→ DB migrations & Edge Fns"]
        WF_DIAG["📄 update-diagram.yml\nauto-update README\n→ creates PR on change"]
    end

    subgraph TARGETS["🚀 Deployment Targets"]
        T_AWS["☁️ AWS\n(S3 · CF · R53 · SES)"]
        T_SB["🟢 Supabase\n(dev + prod)"]
        T_README["📄 README.md\n(this file)"]
    end

    R_INFRA --> WF_TF
    R_INFRA --> WF_SB
    R_INFRA --> WF_DIAG
    SECRETS --> WF_TF
    SECRETS --> WF_SB
    SECRETS --> WF_DIAG
    WF_TF -->|manages| T_AWS
    WF_SB -->|deploys| T_SB
    WF_DIAG -->|creates PR| T_README

    classDef repo fill:#0366D6,stroke:#044289,stroke-width:2px,color:#ffffff
    classDef secret fill:#6f42c1,stroke:#5a32a3,stroke-width:2px,color:#ffffff
    classDef workflow fill:#28A745,stroke:#1e7e34,stroke-width:2px,color:#ffffff
    classDef target fill:#444d56,stroke:#24292E,stroke-width:2px,color:#e1e4e8

    class R_INFRA,R_WEB,R_SITE repo
    class SEC1,SEC2,SEC3 secret
    class WF_TF,WF_SB,WF_DIAG workflow
    class T_AWS,T_SB,T_README target
```

---

### Diagram 3 — Supabase Detail

Database schema, Edge Functions, scheduled crons, and auth configuration for dev & prod.

```mermaid
graph TB
    subgraph AUTH["🔐 Auth Configuration"]
        DEV_AUTH["couplesapp-dev\nklpshxvjzsdqolkrabvb\nsignup=ON · autoconfirm=ON"]
        PROD_AUTH["couplesapp-prod\nzbzesuuovfpjdqggambg\nsignup=OFF · autoconfirm=OFF"]
    end

    subgraph SCHEMA["🗃️ Database Schema (PostgreSQL)"]
        T1[("🗃️ profiles")]
        T2[("🗃️ couples")]
        T3[("🗃️ invitations")]
        T4[("🗃️ calendar_events")]
        T5[("🗃️ date_ideas")]
        T6[("🗃️ date_ideas_feedback")]
        T2 -->|belongs to| T1
        T3 -->|links| T1
        T4 -->|owned by| T2
        T5 -->|owned by| T2
        T6 -->|rates| T5
    end

    subgraph FUNCTIONS["⚡ Edge Functions (Deno)"]
        EF1["⚡ generate-date-ideas\nOpenAI GPT-4o\nGenerates personalized date suggestions"]
    end

    subgraph CRONS["⏰ pg_cron Jobs"]
        CRON1["⏰ Job #1\n0 6 * * * UTC\n→ calls generate-date-ideas\nEvery day at 6 AM UTC"]
    end

    DEV_AUTH --> SCHEMA
    DEV_AUTH --> FUNCTIONS
    DEV_AUTH --> CRONS
    CRONS -->|"triggers"| EF1
    EF1 -->|"writes to"| T5

    classDef authNode fill:#3ECF8E,stroke:#1a7a52,stroke-width:2px,color:#0d3d27,font-weight:bold
    classDef table fill:#1a3a2a,stroke:#3ECF8E,stroke-width:2px,color:#3ECF8E
    classDef fn fill:#0d2d1f,stroke:#3ECF8E,stroke-width:3px,color:#3ECF8E,font-weight:bold
    classDef cron fill:#112b1f,stroke:#2da86e,stroke-width:2px,color:#2da86e

    class DEV_AUTH,PROD_AUTH authNode
    class T1,T2,T3,T4,T5,T6 table
    class EF1 fn
    class CRON1 cron
```

---

### Diagram 4 — AWS Infrastructure (Dev)

Full AWS topology for the dev environment — DNS, CDN, storage, email, and certificates.

```mermaid
graph TB
    subgraph DNS["🌍 Route 53 — nextasy.co\n(Hosted Zone Z02633611RLKX976F44TP)"]
        R53_APP["A alias\ncouplesapp.nextasy.co"]
        R53_WEB["CNAME\n*.nextasy.co"]
    end

    subgraph ACM_GROUP["🔑 ACM Certificate"]
        ACM["🔑 SSL/TLS\nnextasy.co + *.nextasy.co\nARN: REDACTED"]
    end

    subgraph CDN["🌐 CloudFront Distributions (Account AWS_ACCOUNT_ID_REDACTED)"]
        CF_APP["🌐 CouplesApp CDN\nERLTLXEW7WTTN\ndlr56cmovhfn0.cloudfront.net"]
        CF_WEB["🌐 Nextasy Web CDN\nE640UP3DK37WP\nd3heh2lnt32ajw.cloudfront.net"]
        CF_REPORTS["🌐 Reports CDN\nEYJ1QFLZNTBP\nd1ej7mofi8sf.cloudfront.net"]
    end

    subgraph S3_GROUP["🪣 S3 Buckets (us-east-1)"]
        S3_APP[("🪣 couplesapp-dev-frontend\nReact SPA")]
        S3_WEB[("🪣 nextasy-co-website\nCorporate + branch previews")]
        S3_E2E[("🪣 couplesapp-e2e-reports\nE2E & ClawBot reports")]
        S3_TF[("🪣 nextasyapps-terraform-state-dev\nTerraform remote state")]
    end

    subgraph SES_GROUP["📧 SES — Email"]
        SES["📧 AWS SES\ncouplesapp-noreply@nextasy.co\nnextasy.co verified domain"]
    end

    R53_APP --> CF_APP
    R53_WEB --> CF_WEB
    ACM --> CF_APP
    CF_APP --> S3_APP
    CF_WEB --> S3_WEB
    CF_REPORTS --> S3_E2E

    classDef dns fill:#FF9900,stroke:#b36a00,stroke-width:2px,color:#232F3E,font-weight:bold
    classDef acm fill:#d45b07,stroke:#232F3E,stroke-width:2px,color:#ffffff
    classDef cf fill:#8B5CF6,stroke:#6D28D9,stroke-width:2px,color:#ffffff
    classDef s3 fill:#3d6e37,stroke:#FF9900,stroke-width:2px,color:#ffffff
    classDef ses fill:#FF4F00,stroke:#cc3f00,stroke-width:2px,color:#ffffff

    class R53_APP,R53_WEB dns
    class ACM acm
    class CF_APP,CF_WEB,CF_REPORTS cf
    class S3_APP,S3_WEB,S3_E2E,S3_TF s3
    class SES ses
```

---

### Diagram 5 — AWS Infrastructure (Prod)

Production environment — live at couplesapp.nextasy.co (deployed 2026-03-05).

```mermaid
graph TB
    subgraph PROD_ACCOUNT["☁️ AWS Account 511930354489 — Production"]
        subgraph PROD_SB["🟡 Supabase (couplesapp-prod)"]
            PROD_AUTH["zbzesuuovfpjdqggambg\nsignup=OFF · autoconfirm=OFF\n🔒 Strict security posture"]
        end

        subgraph PROD_INFRA["🏗️ Infrastructure (Live ✅)"]
            PROD_CF["🌐 CloudFront\n✅ Provisioned"]
            PROD_S3[("🪣 S3 Buckets\n✅ Provisioned")]
            PROD_R53["🌍 Route53\n✅ Provisioned"]
            PROD_ACM["🔑 ACM Certificate\n✅ Provisioned"]
        end

        PROD_CF -.->|"serves"| PROD_S3
        PROD_R53 -.->|"routes to"| PROD_CF
        PROD_ACM -.->|"secures"| PROD_CF
    end

    classDef pending fill:#3a3a3a,stroke:#555555,stroke-width:1px,color:#888888,font-style:italic
    classDef prodReady fill:#2d4a2d,stroke:#556b55,stroke-width:2px,color:#99cc99

    class PROD_CF,PROD_S3,PROD_R53,PROD_ACM pending
    class PROD_AUTH prodReady
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
| **dev** | `AWS_ACCOUNT_ID_REDACTED` | `klpshxvjzsdqolkrabvb` | `couplesapp.nextasy.co` |
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

*Diagrams last updated: 2026-03-05 — auto-maintained by [update-diagram.yml](.github/workflows/update-diagram.yml)*
