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
```mermaid
graph TB
    subgraph DNS["🌍 Route 53 — nextasy.co
(Hosted Zone Z02633611RLKX976F44TP)"]
        R53_APP["A alias
couplesapp.nextasy.co"]
        R53_WEB["CNAME
*.nextasy.co"]
    end

    subgraph ACM_GROUP["🔑 ACM Certificate"]
        ACM["🔑 SSL/TLS
nextasy.co + *.nextasy.co
ARN: REDACTED"]
    end

    subgraph CDN["🌐 CloudFront Distributions"]
        CF_APP["🌐 CouplesApp CDN
ERLTLXEW7WTTN
dlr56cmovhfn0.cloudfront.net"]
        CF_WEB["🌐 Nextasy Web CDN
E640UP3DK37WP
d3heh2lnt32ajw.cloudfront.net"]
        CF_REPORTS["🌐 Reports CDN
EYJ1QFLZNTBP
d1ej7mofi8sf.cloudfront.net"]
    end

    subgraph S3_GROUP["🪣 S3 Buckets (us-east-1)"]
        S3_APP[("🪣 couplesapp-dev-frontend
React SPA")]
        S3_WEB[("🪣 nextasy-co-website
Corporate + branch previews")]
        S3_E2E[("🪣 couplesapp-e2e-reports
E2E & ClawBot reports")]
        S3_TF[("🪣 nextasyapps-terraform-state-dev
Terraform remote state")]
    end

    subgraph SES_GROUP["📧 SES — Email"]
        SES["📧 AWS SES
couplesapp-noreply@nextasy.co
nextasy.co verified domain"]
    end

    subgraph SUPABASE["🟢 Supabase Projects"]
        SUPABASE_DEV["◾ couplesapp-dev
klpshxvjzsdqolkrabvb"]
        SUPABASE_PROD["◾ couplesapp-prod
zbzesuuovfpjdqggambg"]
    end

    R53_APP --> CF_APP
    R53_WEB --> CF_WEB
    ACM --> CF_APP
    CF_APP --> S3_APP
    CF_WEB --> S3_WEB
    CF_REPORTS --> S3_E2E
    S3_APP --> SES
    S3_WEB --> SES

    SUPABASE_DEV -->|Manages| S3_GROUP
    SUPABASE_PROD -->|Manages| S3_GROUP

    classDef dns fill:#FF9900,stroke:#b36a00,stroke-width:2px,color:#232F3E,font-weight:bold
    classDef acm fill:#d45b07,stroke:#232F3E,stroke-width:2px,color:#ffffff
    classDef cf fill:#8B5CF6,stroke:#6D28D9,stroke-width:2px,color:#ffffff
    classDef s3 fill:#569A31,stroke:#3D7A26,stroke-width:2px,color:#ffffff
    classDef ses fill:#FF4F00,stroke:#cc3f00,stroke-width:2px,color:#ffffff
    classDef supabase fill:#3ECF8E,stroke:#1b7d6b,stroke-width:2px,color:#0d3d27,font-weight:bold

    class R53_APP,R53_WEB dns
    class ACM acm
    class CF_APP,CF_WEB,CF_REPORTS cf
    class S3_APP,S3_WEB,S3_E2E,S3_TF s3
    class SES ses
    class SUPABASE_DEV,SUPABASE_PROD supabase
```
```

---

### Diagram 2 — GitHub Repos & CI/CD

Source code repositories, workflows, and the automation that keeps everything running.

```mermaid
```mermaid
graph TB
    subgraph DNS["🌍 Route 53 — nextasy.co
(Hosted Zone Z02633611RLKX976F44TP)"]
        R53_APP["A alias
couplesapp.nextasy.co"]
        R53_WEB["CNAME
*.nextasy.co"]
    end

    subgraph ACM_GROUP["🔑 ACM Certificate"]
        ACM["🔑 SSL/TLS
nextasy.co + *.nextasy.co
ARN: REDACTED"]
    end

    subgraph CDN["🌐 CloudFront Distributions"]
        CF_APP["🌐 CouplesApp CDN
ERLTLXEW7WTTN
dlr56cmovhfn0.cloudfront.net"]
        CF_WEB["🌐 Nextasy Web CDN
E640UP3DK37WP
d3heh2lnt32ajw.cloudfront.net"]
        CF_REPORTS["🌐 Reports CDN
EYJ1QFLZNTBP
d1ej7mofi8sf.cloudfront.net"]
    end

    subgraph S3_GROUP["🪣 S3 Buckets (us-east-1)"]
        S3_APP[("🪣 couplesapp-dev-frontend
React SPA")]
        S3_WEB[("🪣 nextasy-co-website
Corporate + branch previews")]
        S3_E2E[("🪣 couplesapp-e2e-reports
E2E & ClawBot reports")]
        S3_TF[("🪣 nextasyapps-terraform-state-dev
Terraform remote state")]
    end

    subgraph SES_GROUP["📧 SES — Email"]
        SES["📧 AWS SES
couplesapp-noreply@nextasy.co
nextasy.co verified domain"]
    end

    subgraph SUPABASE["🟢 Supabase Projects"]
        SUPABASE_DEV["◾ couplesapp-dev
klpshxvjzsdqolkrabvb"]
        SUPABASE_PROD["◾ couplesapp-prod
zbzesuuovfpjdqggambg"]
    end

    R53_APP --> CF_APP
    R53_WEB --> CF_WEB
    ACM --> CF_APP
    CF_APP --> S3_APP
    CF_WEB --> S3_WEB
    CF_REPORTS --> S3_E2E
    S3_APP --> SES
    S3_WEB --> SES

    SUPABASE_DEV -->|Manages| S3_GROUP
    SUPABASE_PROD -->|Manages| S3_GROUP

    classDef dns fill:#FF9900,stroke:#b36a00,stroke-width:2px,color:#232F3E,font-weight:bold
    classDef acm fill:#d45b07,stroke:#232F3E,stroke-width:2px,color:#ffffff
    classDef cf fill:#8B5CF6,stroke:#6D28D9,stroke-width:2px,color:#ffffff
    classDef s3 fill:#569A31,stroke:#3D7A26,stroke-width:2px,color:#ffffff
    classDef ses fill:#FF4F00,stroke:#cc3f00,stroke-width:2px,color:#ffffff
    classDef supabase fill:#3ECF8E,stroke:#1b7d6b,stroke-width:2px,color:#0d3d27,font-weight:bold

    class R53_APP,R53_WEB dns
    class ACM acm
    class CF_APP,CF_WEB,CF_REPORTS cf
    class S3_APP,S3_WEB,S3_E2E,S3_TF s3
    class SES ses
    class SUPABASE_DEV,SUPABASE_PROD supabase
```
```

---

### Diagram 3 — Supabase Detail

Database schema, Edge Functions, scheduled crons, and auth configuration for dev & prod.

```mermaid
```mermaid
graph TB
    subgraph DNS["🌍 Route 53 — nextasy.co
(Hosted Zone Z02633611RLKX976F44TP)"]
        R53_APP["A alias
couplesapp.nextasy.co"]
        R53_WEB["CNAME
*.nextasy.co"]
    end

    subgraph ACM_GROUP["🔑 ACM Certificate"]
        ACM["🔑 SSL/TLS
nextasy.co + *.nextasy.co
ARN: REDACTED"]
    end

    subgraph CDN["🌐 CloudFront Distributions"]
        CF_APP["🌐 CouplesApp CDN
ERLTLXEW7WTTN
dlr56cmovhfn0.cloudfront.net"]
        CF_WEB["🌐 Nextasy Web CDN
E640UP3DK37WP
d3heh2lnt32ajw.cloudfront.net"]
        CF_REPORTS["🌐 Reports CDN
EYJ1QFLZNTBP
d1ej7mofi8sf.cloudfront.net"]
    end

    subgraph S3_GROUP["🪣 S3 Buckets (us-east-1)"]
        S3_APP[("🪣 couplesapp-dev-frontend
React SPA")]
        S3_WEB[("🪣 nextasy-co-website
Corporate + branch previews")]
        S3_E2E[("🪣 couplesapp-e2e-reports
E2E & ClawBot reports")]
        S3_TF[("🪣 nextasyapps-terraform-state-dev
Terraform remote state")]
    end

    subgraph SES_GROUP["📧 SES — Email"]
        SES["📧 AWS SES
couplesapp-noreply@nextasy.co
nextasy.co verified domain"]
    end

    subgraph SUPABASE["🟢 Supabase Projects"]
        SUPABASE_DEV["◾ couplesapp-dev
klpshxvjzsdqolkrabvb"]
        SUPABASE_PROD["◾ couplesapp-prod
zbzesuuovfpjdqggambg"]
    end

    R53_APP --> CF_APP
    R53_WEB --> CF_WEB
    ACM --> CF_APP
    CF_APP --> S3_APP
    CF_WEB --> S3_WEB
    CF_REPORTS --> S3_E2E
    S3_APP --> SES
    S3_WEB --> SES

    SUPABASE_DEV -->|Manages| S3_GROUP
    SUPABASE_PROD -->|Manages| S3_GROUP

    classDef dns fill:#FF9900,stroke:#b36a00,stroke-width:2px,color:#232F3E,font-weight:bold
    classDef acm fill:#d45b07,stroke:#232F3E,stroke-width:2px,color:#ffffff
    classDef cf fill:#8B5CF6,stroke:#6D28D9,stroke-width:2px,color:#ffffff
    classDef s3 fill:#569A31,stroke:#3D7A26,stroke-width:2px,color:#ffffff
    classDef ses fill:#FF4F00,stroke:#cc3f00,stroke-width:2px,color:#ffffff
    classDef supabase fill:#3ECF8E,stroke:#1b7d6b,stroke-width:2px,color:#0d3d27,font-weight:bold

    class R53_APP,R53_WEB dns
    class ACM acm
    class CF_APP,CF_WEB,CF_REPORTS cf
    class S3_APP,S3_WEB,S3_E2E,S3_TF s3
    class SES ses
    class SUPABASE_DEV,SUPABASE_PROD supabase
```
```

---

### Diagram 4 — AWS Infrastructure (Dev)

Full AWS topology for the dev environment — DNS, CDN, storage, email, and certificates.

```mermaid
```mermaid
graph TB
    subgraph DNS["🌍 Route 53 — nextasy.co
(Hosted Zone Z02633611RLKX976F44TP)"]
        R53_APP["A alias
couplesapp.nextasy.co"]
        R53_WEB["CNAME
*.nextasy.co"]
    end

    subgraph ACM_GROUP["🔑 ACM Certificate"]
        ACM["🔑 SSL/TLS
nextasy.co + *.nextasy.co
ARN: REDACTED"]
    end

    subgraph CDN["🌐 CloudFront Distributions"]
        CF_APP["🌐 CouplesApp CDN
ERLTLXEW7WTTN
dlr56cmovhfn0.cloudfront.net"]
        CF_WEB["🌐 Nextasy Web CDN
E640UP3DK37WP
d3heh2lnt32ajw.cloudfront.net"]
        CF_REPORTS["🌐 Reports CDN
EYJ1QFLZNTBP
d1ej7mofi8sf.cloudfront.net"]
    end

    subgraph S3_GROUP["🪣 S3 Buckets (us-east-1)"]
        S3_APP[("🪣 couplesapp-dev-frontend
React SPA")]
        S3_WEB[("🪣 nextasy-co-website
Corporate + branch previews")]
        S3_E2E[("🪣 couplesapp-e2e-reports
E2E & ClawBot reports")]
        S3_TF[("🪣 nextasyapps-terraform-state-dev
Terraform remote state")]
    end

    subgraph SES_GROUP["📧 SES — Email"]
        SES["📧 AWS SES
couplesapp-noreply@nextasy.co
nextasy.co verified domain"]
    end

    subgraph SUPABASE["🟢 Supabase Projects"]
        SUPABASE_DEV["◾ couplesapp-dev
klpshxvjzsdqolkrabvb"]
        SUPABASE_PROD["◾ couplesapp-prod
zbzesuuovfpjdqggambg"]
    end

    R53_APP --> CF_APP
    R53_WEB --> CF_WEB
    ACM --> CF_APP
    CF_APP --> S3_APP
    CF_WEB --> S3_WEB
    CF_REPORTS --> S3_E2E
    S3_APP --> SES
    S3_WEB --> SES

    SUPABASE_DEV -->|Manages| S3_GROUP
    SUPABASE_PROD -->|Manages| S3_GROUP

    classDef dns fill:#FF9900,stroke:#b36a00,stroke-width:2px,color:#232F3E,font-weight:bold
    classDef acm fill:#d45b07,stroke:#232F3E,stroke-width:2px,color:#ffffff
    classDef cf fill:#8B5CF6,stroke:#6D28D9,stroke-width:2px,color:#ffffff
    classDef s3 fill:#569A31,stroke:#3D7A26,stroke-width:2px,color:#ffffff
    classDef ses fill:#FF4F00,stroke:#cc3f00,stroke-width:2px,color:#ffffff
    classDef supabase fill:#3ECF8E,stroke:#1b7d6b,stroke-width:2px,color:#0d3d27,font-weight:bold

    class R53_APP,R53_WEB dns
    class ACM acm
    class CF_APP,CF_WEB,CF_REPORTS cf
    class S3_APP,S3_WEB,S3_E2E,S3_TF s3
    class SES ses
    class SUPABASE_DEV,SUPABASE_PROD supabase
```
```

---

### Diagram 5 — AWS Infrastructure (Prod)

Production environment — live at couplesapp.nextasy.co (deployed 2026-03-05).

```mermaid
```mermaid
graph TB
    subgraph DNS["🌍 Route 53 — nextasy.co
(Hosted Zone Z02633611RLKX976F44TP)"]
        R53_APP["A alias
couplesapp.nextasy.co"]
        R53_WEB["CNAME
*.nextasy.co"]
    end

    subgraph ACM_GROUP["🔑 ACM Certificate"]
        ACM["🔑 SSL/TLS
nextasy.co + *.nextasy.co
ARN: REDACTED"]
    end

    subgraph CDN["🌐 CloudFront Distributions"]
        CF_APP["🌐 CouplesApp CDN
ERLTLXEW7WTTN
dlr56cmovhfn0.cloudfront.net"]
        CF_WEB["🌐 Nextasy Web CDN
E640UP3DK37WP
d3heh2lnt32ajw.cloudfront.net"]
        CF_REPORTS["🌐 Reports CDN
EYJ1QFLZNTBP
d1ej7mofi8sf.cloudfront.net"]
    end

    subgraph S3_GROUP["🪣 S3 Buckets (us-east-1)"]
        S3_APP[("🪣 couplesapp-dev-frontend
React SPA")]
        S3_WEB[("🪣 nextasy-co-website
Corporate + branch previews")]
        S3_E2E[("🪣 couplesapp-e2e-reports
E2E & ClawBot reports")]
        S3_TF[("🪣 nextasyapps-terraform-state-dev
Terraform remote state")]
    end

    subgraph SES_GROUP["📧 SES — Email"]
        SES["📧 AWS SES
couplesapp-noreply@nextasy.co
nextasy.co verified domain"]
    end

    subgraph SUPABASE["🟢 Supabase Projects"]
        SUPABASE_DEV["◾ couplesapp-dev
klpshxvjzsdqolkrabvb"]
        SUPABASE_PROD["◾ couplesapp-prod
zbzesuuovfpjdqggambg"]
    end

    R53_APP --> CF_APP
    R53_WEB --> CF_WEB
    ACM --> CF_APP
    CF_APP --> S3_APP
    CF_WEB --> S3_WEB
    CF_REPORTS --> S3_E2E
    S3_APP --> SES
    S3_WEB --> SES

    SUPABASE_DEV -->|Manages| S3_GROUP
    SUPABASE_PROD -->|Manages| S3_GROUP

    classDef dns fill:#FF9900,stroke:#b36a00,stroke-width:2px,color:#232F3E,font-weight:bold
    classDef acm fill:#d45b07,stroke:#232F3E,stroke-width:2px,color:#ffffff
    classDef cf fill:#8B5CF6,stroke:#6D28D9,stroke-width:2px,color:#ffffff
    classDef s3 fill:#569A31,stroke:#3D7A26,stroke-width:2px,color:#ffffff
    classDef ses fill:#FF4F00,stroke:#cc3f00,stroke-width:2px,color:#ffffff
    classDef supabase fill:#3ECF8E,stroke:#1b7d6b,stroke-width:2px,color:#0d3d27,font-weight:bold

    class R53_APP,R53_WEB dns
    class ACM acm
    class CF_APP,CF_WEB,CF_REPORTS cf
    class S3_APP,S3_WEB,S3_E2E,S3_TF s3
    class SES ses
    class SUPABASE_DEV,SUPABASE_PROD supabase
```
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
