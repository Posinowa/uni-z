#!/usr/bin/env python3
"""Create GitHub issues #14+ from UNIZ_MOBILE_GITHUB_ISSUES.md"""

import json
import re
import subprocess
import sys
import time
from pathlib import Path

REPO = "Posinowa/uni-z"
START_ISSUE = 14
MARKDOWN = Path(__file__).resolve().parents[2] / "UNIZ_MOBILE_GITHUB_ISSUES.md"


def run(cmd: list[str], check: bool = True) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, capture_output=True, text=True, check=check)


def parse_issues(content: str) -> list[dict]:
    pattern = re.compile(
        r"^## Issue (\d+) — (.+?)\n\n\*\*Labels:\*\* (.+?)\n\n(.*?)(?=\n---\n|\n# |\Z)",
        re.MULTILINE | re.DOTALL,
    )
    issues = []
    for match in pattern.finditer(content):
        number = int(match.group(1))
        if number < START_ISSUE:
            continue
        title = match.group(2).strip()
        labels_raw = match.group(3).strip()
        body = match.group(4).strip()
        labels = [
            label.strip().strip("`")
            for label in labels_raw.split(",")
            if label.strip()
        ]
        issues.append(
            {
                "number": number,
                "title": title,
                "labels": labels,
                "body": body,
            }
        )
    return sorted(issues, key=lambda item: item["number"])


def ensure_labels(labels: set[str]) -> None:
    existing: set[str] = set()
    page = 1
    while True:
        result = run(
            [
                "gh",
                "api",
                f"repos/{REPO}/labels?per_page=100&page={page}",
            ]
        )
        batch = json.loads(result.stdout)
        if not batch:
            break
        for item in batch:
            existing.add(item["name"])
        if len(batch) < 100:
            break
        page += 1

    for label in sorted(labels):
        if label in existing:
            continue
        color = "ededed"
        if label == "priority-high":
            color = "d73a4a"
        elif label in {"security", "moderation"}:
            color = "b60205"
        elif label in {"firebase", "firestore"}:
            color = "0075ca"
        elif label == "ui":
            color = "a2eeef"
        run(
            [
                "gh",
                "api",
                f"repos/{REPO}/labels",
                "-f",
                f"name={label}",
                "-f",
                f"color={color}",
            ],
            check=False,
        )
        print(f"Label created: {label}")


def issue_exists(title: str) -> bool:
    result = run(
        [
            "gh",
            "issue",
            "list",
            "--repo",
            REPO,
            "--search",
            f'in:title "{title}"',
            "--json",
            "title",
            "--limit",
            "5",
        ]
    )
    return title in result.stdout


def create_issue(issue: dict) -> None:
    if issue_exists(issue["title"]):
        print(f'Skip existing: #{issue["number"]} {issue["title"]}')
        return

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
    print(f'Created #{issue["number"]}: {issue["title"]} -> {url}')
    time.sleep(0.3)


def main() -> int:
    if not MARKDOWN.exists():
        print(f"Markdown file not found: {MARKDOWN}", file=sys.stderr)
        return 1

    content = MARKDOWN.read_text(encoding="utf-8")
    issues = parse_issues(content)
    if not issues:
        print("No issues parsed.", file=sys.stderr)
        return 1

    all_labels = {label for issue in issues for label in issue["labels"]}
    ensure_labels(all_labels)

    print(f"Creating {len(issues)} issues starting from #{START_ISSUE}...")
    for issue in issues:
        create_issue(issue)

    print("Done.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
