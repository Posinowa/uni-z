#!/usr/bin/env python3
"""Create closed setup issues, milestones, and assign issues on GitHub."""

import json
import re
import subprocess
import time
from pathlib import Path

REPO = "Posinowa/uni-z"
MARKDOWN = Path(__file__).resolve().parents[2] / "UNIZ_MOBILE_GITHUB_ISSUES.md"

MILESTONES_TEMPLATE = [
    ("M0 — Setup & Governance", "Proje kurulumu, CI, dokümantasyon", "m0"),
    ("M1 — Theme, Routing & Shared UI", "Tema, shared componentler, routing", list(range(1, 7))),
    ("M2 — Firebase Foundation", "Firebase paketleri, init, Firestore base", list(range(7, 11))),
    ("M3 — Auth", "Login, register, AuthProvider", list(range(11, 22))),
    ("M4 — Profile & Onboarding", "Profil tamamlama, Firestore users", list(range(22, 32))),
    ("M5 — Home Navigation", "Bottom navigation shell", [32]),
    ("M6 — Feed & Posts", "Post oluşturma, beğeni", list(range(33, 43))),
    ("M7 — Reports", "Raporlama sistemi", list(range(43, 46))),
    ("M8 — Courses & Materials", "Dersler, materyaller", list(range(46, 58))),
    ("M9 — Events", "Etkinlikler", list(range(58, 65))),
    ("M10 — Notifications", "FCM, token kaydı", list(range(65, 68))),
    ("M11 — Banned User Controls", "Ban kontrolü", list(range(68, 70))),
    ("M12 — Final MVP Polish", "Empty state, error handling, README", list(range(70, 74))),
]


def run(cmd: list[str], check: bool = True) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, capture_output=True, text=True, check=check)


def parse_setup_issues(content: str) -> list[dict]:
    pattern = re.compile(
        r"^## Issue (\d+) — (.+?)\n\n\*\*Labels:\*\* (.+?)\n\n(.*?)(?=\n---\n|\n# |\Z)",
        re.MULTILINE | re.DOTALL,
    )
    issues = []
    for match in pattern.finditer(content):
        number = int(match.group(1))
        if number > 13:
            break
        labels = [
            label.strip().strip("`")
            for label in match.group(3).split(",")
            if label.strip()
        ]
        body = (
            match.group(4).strip()
            + "\n\n---\n\n**Durum:** Tamamlandı (M0 setup).\n"
            + f"**Plan dokümanı referansı:** Issue #{number}\n"
        )
        issues.append(
            {
                "doc_number": number,
                "title": match.group(2).strip(),
                "labels": labels,
                "body": body,
            }
        )
    return issues


def create_closed_issue(issue: dict) -> int:
    search = run(
        [
            "gh",
            "issue",
            "list",
            "--repo",
            REPO,
            "--search",
            f'in:title "{issue["title"]}"',
            "--state",
            "all",
            "--json",
            "number,state",
            "--limit",
            "1",
        ]
    )
    existing = json.loads(search.stdout)
    if existing:
        number = existing[0]["number"]
        if existing[0]["state"] == "OPEN":
            run(["gh", "issue", "close", str(number), "--repo", REPO])
        print(f"Setup issue #{number} already exists: {issue['title']}")
        return number

    cmd = [
        "gh",
        "issue",
        "create",
        "--repo",
        REPO,
        "--title",
        issue["title"],
        "--body",
        issue["body"],
    ]
    for label in issue["labels"]:
        cmd.extend(["--label", label])
    result = run(cmd)
    url = result.stdout.strip()
    number = int(url.rsplit("/", 1)[-1])
    run(["gh", "issue", "close", str(number), "--repo", REPO])
    print(f"Closed setup issue #{number}: {issue['title']} (doc #{issue['doc_number']})")
    time.sleep(0.3)
    return number


def get_or_create_milestone(title: str, description: str) -> int:
    result = run(["gh", "api", f"repos/{REPO}/milestones", "--paginate"])
    for item in json.loads(result.stdout):
        if item["title"] == title:
            return item["number"]
    result = run(
        [
            "gh",
            "api",
            f"repos/{REPO}/milestones",
            "-f",
            f"title={title}",
            "-f",
            f"description={description}",
            "-f",
            "state=open",
        ]
    )
    return json.loads(result.stdout)["number"]


def assign_milestone(issue_number: int, milestone_number: int) -> None:
    run(
        [
            "gh",
            "api",
            f"repos/{REPO}/issues/{issue_number}",
            "-X",
            "PATCH",
            "-f",
            f"milestone={milestone_number}",
        ]
    )


def main() -> None:
    content = MARKDOWN.read_text(encoding="utf-8")
    setup_issues = parse_setup_issues(content)

    print("Creating closed setup issues (doc #1-13)...")
    created_numbers = []
    for issue in setup_issues:
        num = create_closed_issue(issue)
        created_numbers.append(num)

    print(f"Created closed issues: {created_numbers}")

    print("Creating milestones and assigning issues...")
    for title, description, issue_ref in MILESTONES_TEMPLATE:
        issue_numbers = created_numbers if issue_ref == "m0" else issue_ref
        milestone_number = get_or_create_milestone(title, description)
        print(f"Milestone #{milestone_number}: {title}")
        for issue_number in issue_numbers:
            try:
                assign_milestone(issue_number, milestone_number)
            except subprocess.CalledProcessError as exc:
                print(f"  Warning: could not assign #{issue_number}: {exc.stderr.strip()}")
        time.sleep(0.2)

    print("Done.")


if __name__ == "__main__":
    main()
