#!/bin/bash
# 📊 Weekly Learning Summary Generator

WEEK_START=$(date -d "last monday" +"%Y-%m-%d")
WEEK_END=$(date +"%Y-%m-%d")

cat > "docs/weekly-summaries/week-$WEEK_END.md" << EOF
# 📊 Weekly Summary: $WEEK_START to $WEEK_END

## 🎯 Key Achievements This Week
- Infrastructure improvements and optimizations
- Learning progress in cloud-native technologies
- Community contributions and networking

## 📈 Metrics
- Commits this week: $(git log --since="$WEEK_START" --oneline | wc -l)
- Files modified: $(git log --since="$WEEK_START" --name-only --pretty=format: | sort | uniq | wc -l)
- Learning entries: $(grep -c "^## 📅" docs/learning/daily-log.md | tail -7 | wc -l)

## 🚀 Next Week Goals
- Continue building cloud-native expertise
- Enhance automation and infrastructure patterns
- Contribute to open source projects

---
Generated automatically on $WEEK_END
EOF

