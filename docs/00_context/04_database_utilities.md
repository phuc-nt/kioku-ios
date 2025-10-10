# Database Utilities & Scripts

**Purpose**: Collection of useful database queries and scripts for debugging, data inspection, and maintenance.

**Last Updated**: October 10, 2025

---

## Database Location

Find the current database path (changes when app reinstalls):

```bash
DB_PATH=$(find /Users/phucnt/Library/Developer/CoreSimulator/Devices/1E2BA38B-3BA0-48FB-AE8C-6009C2A3A4A7/data/Containers/Data/Application -name "default.store" 2>/dev/null | head -1)
echo "📁 Database: $DB_PATH"
```

**Note**: Replace simulator UUID `1E2BA38B-3BA0-48FB-AE8C-6009C2A3A4A7` with your iPhone 16 simulator UUID from `xcrun simctl list devices`.

---

## Entity Inspection

### Check Entity Deduplication

**Purpose**: Verify entities are being reused across entries (not duplicated).

```bash
DB_PATH="<path-to-default.store>"

sqlite3 "$DB_PATH" << 'EOF'
SELECT
    e.Z_PK as EntityID,
    e.ZVALUE as Name,
    e.ZTYPE as Type,
    ROUND(e.ZCONFIDENCE, 2) as Conf,
    COUNT(DISTINCT j.Z_6ENTRIES) as NumEntries,
    GROUP_CONCAT(DISTINCT j.Z_6ENTRIES) as EntryIDs
FROM ZENTITY e
LEFT JOIN Z_4ENTRIES j ON e.Z_PK = j.Z_4ENTITIES
WHERE e.ZVALUE IN ('Minh', 'Hằng')
GROUP BY e.Z_PK
ORDER BY e.ZVALUE, e.Z_PK;
EOF
```

**Expected**: Each entity value should appear only once with `NumEntries > 1`.

### Count Entities by Type

**Purpose**: Get overview of entity distribution.

```bash
sqlite3 "$DB_PATH" << 'EOF'
SELECT
    CASE ZTYPE
        WHEN 0 THEN 'People'
        WHEN 1 THEN 'Places'
        WHEN 2 THEN 'Events'
        WHEN 3 THEN 'Emotions'
        WHEN 4 THEN 'Topics'
        ELSE 'Unknown'
    END as Type,
    COUNT(*) as Count
FROM ZENTITY
GROUP BY ZTYPE
ORDER BY ZTYPE;
EOF
```

### List All People Entities

**Purpose**: See all extracted people entities with their entry counts.

```bash
sqlite3 "$DB_PATH" << 'EOF'
SELECT
    e.Z_PK as ID,
    e.ZVALUE as Name,
    ROUND(e.ZCONFIDENCE, 2) as Confidence,
    COUNT(DISTINCT j.Z_6ENTRIES) as NumEntries
FROM ZENTITY e
LEFT JOIN Z_4ENTRIES j ON e.Z_PK = j.Z_4ENTITIES
WHERE e.ZTYPE = 0
GROUP BY e.Z_PK
ORDER BY NumEntries DESC, e.ZVALUE;
EOF
```

---

## Relationship Inspection

### Count Relationships

**Purpose**: Check how many relationships have been discovered.

```bash
sqlite3 "$DB_PATH" << 'EOF'
SELECT COUNT(*) as TotalRelationships FROM ZENTITYRELATIONSHIP;
EOF
```

### List Relationships for an Entity

**Purpose**: See all relationships connected to a specific entity.

```bash
sqlite3 "$DB_PATH" << 'EOF'
SELECT
    r.Z_PK as RelID,
    e1.ZVALUE as FromEntity,
    e2.ZVALUE as ToEntity,
    CASE r.ZTYPE
        WHEN 0 THEN 'Temporal'
        WHEN 1 THEN 'Causal'
        WHEN 2 THEN 'Emotional'
        WHEN 3 THEN 'Topical'
        ELSE 'Unknown'
    END as RelType,
    ROUND(r.ZCONFIDENCE, 2) as Confidence
FROM ZENTITYRELATIONSHIP r
JOIN ZENTITY e1 ON r.ZFROMENTITY = e1.Z_PK
JOIN ZENTITY e2 ON r.ZTOENTITY = e2.Z_PK
WHERE e1.ZVALUE = 'Minh' OR e2.ZVALUE = 'Minh'
ORDER BY r.ZCONFIDENCE DESC;
EOF
```

---

## Entry Inspection

### Check Extraction Status

**Purpose**: See which entries have been processed for entity extraction and relationship discovery.

```bash
sqlite3 "$DB_PATH" << 'EOF'
SELECT
    Z_PK as EntryID,
    datetime(ZDATE, 'unixepoch', '+31 years') as Date,
    ZISENTITIESEXTRACTED as EntitiesExtracted,
    ZISRELATIONSHIPSDISCOVERED as RelationshipsDiscovered,
    datetime(ZENTITIESEXTRACTEDAT, 'unixepoch', '+31 years') as ExtractedAt
FROM ZENTRY
ORDER BY ZDATE DESC
LIMIT 10;
EOF
```

### View Entry Schema

**Purpose**: Understand the Entry table structure.

```bash
sqlite3 "$DB_PATH" "PRAGMA table_info(ZENTRY);"
```

---

## Data Cleanup & Reset

### Reset Extraction Flags

**Purpose**: Allow re-extraction of entities and relationships (without deleting existing data).

```bash
sqlite3 "$DB_PATH" << 'EOF'
UPDATE ZENTRY SET ZISENTITIESEXTRACTED = 0;
UPDATE ZENTRY SET ZISRELATIONSHIPSDISCOVERED = 0;
UPDATE ZENTRY SET ZENTITIESEXTRACTEDAT = NULL;
UPDATE ZENTRY SET ZRELATIONSHIPSDISCOVEREDAT = NULL;

SELECT 'Entries ready for re-extraction: ' || COUNT(*)
FROM ZENTRY
WHERE ZISENTITIESEXTRACTED = 0;
EOF
```

**When to use**: After fixing entity extraction bugs, to re-process all entries.

### Complete Database Reset

**Purpose**: Delete all entities, relationships, and reset extraction flags for clean re-extraction.

```bash
# IMPORTANT: Close app first to unlock database
sqlite3 "$DB_PATH" << 'EOF'
-- Delete all entity-entry relationships
DELETE FROM Z_4ENTRIES;

-- Delete all entity relationships
DELETE FROM ZENTITYRELATIONSHIP;

-- Delete all entities
DELETE FROM ZENTITY;

-- Reset extraction flags
UPDATE ZENTRY SET ZISENTITIESEXTRACTED = 0;
UPDATE ZENTRY SET ZISRELATIONSHIPSDISCOVERED = 0;
UPDATE ZENTRY SET ZENTITIESEXTRACTEDAT = NULL;
UPDATE ZENTRY SET ZRELATIONSHIPSDISCOVEREDAT = NULL;

-- Verify
SELECT 'Entities: ' || COUNT(*) FROM ZENTITY;
SELECT 'Relationships: ' || COUNT(*) FROM ZENTITYRELATIONSHIP;
SELECT 'Entries to extract: ' || COUNT(*) FROM ZENTRY WHERE ZISENTITIESEXTRACTED = 0;
EOF
```

**When to use**:
- After major entity extraction algorithm changes
- When entity deduplication is broken
- For testing from clean state

**⚠️ Warning**: This deletes all extracted knowledge graph data. Journal entries themselves are NOT deleted.

---

## Insight Inspection

### Count Insights by Type

**Purpose**: See how many insights have been generated.

```bash
sqlite3 "$DB_PATH" << 'EOF'
SELECT
    CASE ZTYPE
        WHEN 0 THEN 'Temporal'
        WHEN 1 THEN 'Frequency'
        WHEN 2 THEN 'Social'
        WHEN 3 THEN 'Emotional'
        WHEN 4 THEN 'Suggestion'
        ELSE 'Unknown'
    END as Type,
    COUNT(*) as Count
FROM ZINSIGHT
GROUP BY ZTYPE
ORDER BY ZTYPE;
EOF
```

### List Recent Insights

**Purpose**: See latest generated insights.

```bash
sqlite3 "$DB_PATH" << 'EOF'
SELECT
    Z_PK as ID,
    ZTITLE as Title,
    ROUND(ZCONFIDENCE, 2) as Confidence,
    CASE ZTIMEFRAME
        WHEN 0 THEN 'Daily'
        WHEN 1 THEN 'Weekly'
        WHEN 2 THEN 'Monthly'
        ELSE 'Unknown'
    END as Timeframe
FROM ZINSIGHT
ORDER BY ZCREATEDAT DESC
LIMIT 10;
EOF
```

---

## Quick Reference Commands

### Stop App and Access Database

```bash
# Stop app
xcrun simctl terminate 1E2BA38B-3BA0-48FB-AE8C-6009C2A3A4A7 com.phucnt.kioku

# Wait for locks to clear
sleep 2

# Access database
DB_PATH=$(find /Users/phucnt/Library/Developer/CoreSimulator/Devices/1E2BA38B-3BA0-48FB-AE8C-6009C2A3A4A7/data/Containers/Data/Application -name "default.store" 2>/dev/null | head -1)
sqlite3 "$DB_PATH"
```

### Launch App

```bash
xcrun simctl launch 1E2BA38B-3BA0-48FB-AE8C-6009C2A3A4A7 com.phucnt.kioku
```

---

## Troubleshooting

### Database Locked Error

**Symptom**: `Error: unable to open database file`

**Solution**:
1. Close the app completely
2. Wait 2-3 seconds for file locks to release
3. Try query again
4. If still locked, restart simulator

### Database Path Changed

**Symptom**: Queries fail with "no such file"

**Solution**:
- App reinstalls create new container with new path
- Use the "Find Database Location" command to get current path
- Database path format: `/Users/.../Application/<UUID>/Library/Application Support/default.store`

### Empty Query Results

**Symptom**: Queries return no data

**Solution**:
1. Check if entities have been extracted: `SELECT COUNT(*) FROM ZENTITY`
2. Check extraction flags: See "Check Extraction Status" query
3. Run Entity Extraction from Settings if needed

---

## Entity Type Reference

| ZTYPE | Entity Type |
|-------|-------------|
| 0     | People      |
| 1     | Places      |
| 2     | Events      |
| 3     | Emotions    |
| 4     | Topics      |

## Relationship Type Reference

| ZTYPE | Relationship Type |
|-------|-------------------|
| 0     | Temporal          |
| 1     | Causal            |
| 2     | Emotional         |
| 3     | Topical           |

## Insight Type Reference

| ZTYPE | Insight Type |
|-------|--------------|
| 0     | Temporal     |
| 1     | Frequency    |
| 2     | Social       |
| 3     | Emotional    |
| 4     | Suggestion   |

## Timeframe Reference

| ZTIMEFRAME | Timeframe |
|------------|-----------|
| 0          | Daily     |
| 1          | Weekly    |
| 2          | Monthly   |
