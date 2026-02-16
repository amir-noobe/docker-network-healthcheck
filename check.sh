#!/usr/bin/env sh
set -e

TARGETS_FILE="/app/targets.txt"
REPORT_FILE="/app/report.txt"

if [ ! -f "$TARGETS_FILE" ]; then
  echo "targets file not found: $TARGETS_FILE"
  exit 2
fi

echo "Health Check - $(date -u)" | tee "$REPORT_FILE"
echo "------------------------------------------------" | tee -a "$REPORT_FILE"
echo "Format: URL|HOST|PORT" | tee -a "$REPORT_FILE"
echo "------------------------------------------------" | tee -a "$REPORT_FILE"

FAIL=0

# ✅ مهم: بدون pipe تا FAIL درست کار کند
while IFS= read -r line; do
  # رد کردن خط خالی یا کامنت
  case "$line" in
    ""|\#*) continue ;;
  esac

  url=$(echo "$line" | cut -d'|' -f1)
  host=$(echo "$line" | cut -d'|' -f2)
  port=$(echo "$line" | cut -d'|' -f3)

  # ✅ TCP check (force IPv4)
  if nc -4 -z -w 3 "$host" "$port"; then
    tcp="TCP OK"
  else
    tcp="TCP FAIL"
    FAIL=1
  fi

  # HTTP check
  code=$(curl -s -o /dev/null -w "%{http_code}" "$url" || echo "000")
  time_total=$(curl -s -o /dev/null -w "%{time_total}" "$url" || echo "0")

  if [ "$code" = "000" ] || [ "$code" -ge 400 ]; then
    http="HTTP FAIL ($code)"
    FAIL=1
  else
    http="HTTP OK ($code)"
  fi

  echo "$url -> $tcp, $http, time=${time_total}s" | tee -a "$REPORT_FILE"
done < "$TARGETS_FILE"

echo "------------------------------------------------" | tee -a "$REPORT_FILE"

if [ "$FAIL" -eq 1 ]; then
  echo "Result: FAILED" | tee -a "$REPORT_FILE"
  exit 1
else
  echo "Result: OK" | tee -a "$REPORT_FILE"
fi