# Presentation Demo Data

## Overview

This dataset contains 20 journal entries spanning September-October 2025 from a 35-year-old software engineer with a wife (Sarah) and two children (Emma and Jake). The entries are written in English and cover both work and family life.

## Character Profile

**Narrator**: 35-year-old software engineer
- **Job**: Backend engineer working on microservices architecture
- **Manager**: Mike (supportive, understanding)
- **Colleagues**: Tom (product team), Alex (junior dev)
- **Family**:
  - Wife: Sarah (stay-at-home mom, supportive)
  - Daughter: Emma (school age, learning math and reading)
  - Son: Jake (younger, energetic)
- **Workplace**: Tech company with sprints, standups, code reviews

## Story Arc (20 entries across Sep-Oct 2025)

**September 2-8**: Back-to-school season, new authentication microservice launch (crisis → recovery), farmers market, Emma's new teacher
**September 12-24**: New payment service project begins, Emma starts soccer, Jake gets sick, team retrospective, pottery class for Sarah
**September 28 - October 2**: Fall activities, Emma's confidence growing, event sourcing implementation, mentoring Alex
**October 5-13**: Date night with Sarah, Emma's field trip (volunteered as chaperone), pumpkin patch family outing
**October 16-22**: Payment service deployment success, pumpkin carving, stretched thin at work, homework with Emma
**October 25-31**: Jake's checkup, Sarah's pottery workshop, Halloween prep and celebration, code review marathon

**Key Themes**: Work-life balance, parenting milestones, marriage support, technical challenges, mentorship, seasonal family traditions

## Expected AI Extractions

### Entities (50+)

**People (9)**:
- Sarah (wife) - appears in 20 entries
- Emma (daughter) - appears in 19 entries
- Jake (son) - appears in 19 entries
- Mike (manager) - appears in 6 entries
- Alex (junior dev) - appears in 3 entries
- Tom (product team) - appears in 1 entry
- Mrs. Anderson (Emma's teacher) - appears in 1 entry
- Rachel (Sarah's friend) - appears in 1 entry
- Mom & Dad (narrator's parents) - appears in 2 entries

**Places (12)**:
- Home - appears in all entries
- Work/Office - appears in 14 entries
- Farmers market - Sep 8
- Park - Sep 8, Sep 28
- Ice cream place - Sep 17
- Italian restaurant - Oct 5
- Farm (field trip) - Oct 9
- Pumpkin patch - Oct 13
- Children's museum - Oct 27
- Pottery workshop - Sep 24, Oct 27
- Garage/pottery studio - Oct 19
- Neighborhood (trick-or-treating) - Oct 29, 31

**Events (15)**:
- Authentication microservice launch - Sep 2
- Back to school - Sep 2
- Farmers market visit - Sep 8
- Emma's first soccer game - Sep 17
- Jake's fever - Sep 21
- Team retrospective - Sep 24
- Sarah's pottery class start - Sep 24
- Date night - Oct 5
- Emma's field trip - Oct 9
- Pumpkin patch outing - Oct 13
- Payment service deployment - Oct 16
- Pumpkin carving - Oct 19
- Jake's 4-year checkup - Oct 25
- Halloween prep - Oct 29
- Halloween - Oct 31

**Emotions (20+)**:
- stressed (Sep 2)
- guilty (Sep 2)
- grateful (Sep 5, Oct 16, Oct 31)
- content (Sep 5)
- excited (Sep 12, Oct 29)
- proud (Sep 17, Oct 2, Oct 30)
- drained (Sep 21)
- energized (Sep 24)
- relaxed (Sep 8, Oct 13)
- happy (Sep 28, Oct 27)
- balanced (Oct 2)
- fulfilled (Oct 2, Oct 30)
- anxious (Sep 2)
- exhausted (Sep 21)
- blessed (Oct 19)
- accomplished (Oct 16)
- nervous (Sep 17, Oct 25)
- cherish (Sep 17)
- relieved (Oct 22)
- chaotic (Sep 5, Oct 27)

**Topics (15+)**:
- Work-life balance
- Microservices architecture
- Event sourcing
- Database connection pooling
- Authentication service
- Payment service
- Parenting
- Marriage/Relationships
- Career/Mentorship
- Family traditions
- Soccer
- Pottery/Hobbies
- School activities
- Halloween
- Fall season activities

### Relationships (Expected)

**Social Relationships**:
- Narrator → Sarah (married_to, emotional_support)
- Narrator → Emma (parent_of)
- Narrator → Jake (parent_of)
- Narrator → Mike (reports_to, supported_by)
- Narrator → Alex (mentors)

**Emotional Relationships**:
- stressed → deployment failure (triggered_by)
- grateful → family time (felt_during)
- relaxed → playing with Jake (felt_during)
- anxious → parenting concerns (triggered_by)
- fulfilled → mentoring (felt_during)

**Location Relationships**:
- Work → stressed (felt_at)
- Home → grateful (felt_at)
- Park → happy (felt_at)
- Starbucks → quality time (met_at)

### Insights (Expected)

**Weekly Insights**:
1. "Work stress correlates with late arrival home (3 out of 10 days)"
2. "Quality time with Sarah mentioned 5 times - high priority for narrator"
3. "Parenting moments (playing, reading) associated with relaxed/happy emotions"
4. "Manager Mike provides consistent support - positive work relationship"
5. "Balance between work and family is recurring theme"

**Emotional Patterns**:
1. "Stressful work days (Jan 15, 21) followed by recovery days (Jan 16, 22)"
2. "Family activities (weekend hiking, pizza night) consistently trigger positive emotions"
3. "Mentoring others (Alex, Emma's reading) creates sense of fulfillment"

**Social Patterns**:
1. "Sarah appears in 80% of entries - most important relationship"
2. "Kids (Emma, Jake) appear in 70% of entries - central to life"
3. "Mike (manager) mentioned in context of support and understanding"

## Demo Scenarios

### Scenario 1: Entity Extraction Demo

**Action**: Import data → Navigate to Graph view
**Expected**: See 50+ entities with color coding:
- 9 green nodes (People): Sarah, Emma, Jake, Mike, Alex, Tom, Mrs. Anderson, Rachel, Mom & Dad
- 12 blue nodes (Places): Home, Work, Farmers market, Park, Ice cream place, Italian restaurant, Farm, Pumpkin patch, etc.
- 15 orange nodes (Events): Authentication launch, Soccer game, Field trip, Pumpkin carving, Halloween, etc.
- 20+ pink nodes (Emotions): stressed, grateful, anxious, fulfilled, proud, happy, nervous, etc.

**Highlight**: "AI extracted 50+ entities from 20 entries - 9 people, 12 places, 15 events, 20+ emotions, 15+ topics"

### Scenario 2: Relationship Discovery Demo

**Action**: Tap on "Sarah" entity in Graph view
**Expected**: See relationships:
- Sarah → Home (associated_with)
- Sarah → Narrator (married_to)
- Sarah → Date night (participated_in)
- Sarah → Emotional support (provides)

**Highlight**: "Sarah appears in all 20 entries - AI recognized she's the most important person in this journal"

### Scenario 3: Emotional Insights Demo

**Action**: Navigate to Insights tab
**Expected Insights**:
1. "You feel stressed when work has production issues (Sep 2, Oct 16)"
2. "Family time with Sarah and kids consistently triggers grateful/happy emotions"
3. "Work-life balance is your top concern - mentioned in 70% of entries"
4. "Sarah's pottery hobby correlates with her happiness - mentioned Sep 24, 28, Oct 19, 27"
5. "Emma's milestones (soccer, field trip, school) trigger pride emotions"
6. "Fall traditions (pumpkin patch, Halloween) create joyful family memories"

**Highlight**: "AI discovered patterns across 2 months: family time = positive emotions, work crises = stress, fall traditions = happiness. Actionable insight: prioritize family moments and seasonal traditions to maintain balance"

### Scenario 4: Context-Aware Chat Demo

**Action**: Open Oct 5 entry → Tap "Chat with AI"
**User Question**: "When was the last time I spent quality time alone with Sarah?"

**Expected AI Response**:
"The last time you spent quality time alone with Sarah was on October 5th, when you went on a date night to a new Italian restaurant downtown. Your mom watched the kids, and you two talked about everything - her pottery class, your work projects, the kids, and your dreams for the future. You mentioned it was your first real date in almost 2 months, and walking back to the car holding hands felt like dating again. You even discussed planning a weekend away together in spring."

**Context Loaded** (check logs):
- Current entry: Oct 5 (date night)
- Recent entries: Oct 2-4 (past 3 days)
- Historical entries: Sep 5 (1 month prior, similar family dinner theme)
- Related via KG: Sep 8 (talked with Sarah at farmers market), Sep 24 (Sarah's pottery class enrollment)
- Entities: Sarah (20 mentions), Italian restaurant (1 mention), Mom (2 mentions)
- Insights: "Date nights and quality time important for relationship" (inferred)

**Highlight**: "AI read 14+ entries in context (current + historical + recent + 5 KG-related), found exact answer with date, location, and emotional context across 2-month span"

### Scenario 5: Multi-Turn Conversation Demo

**First Question**: "How do I feel about work?"
**Expected Response**: "Your feelings about work are mixed. You experience stress during production issues (Sep 2 with authentication service, Oct 16 payment service deployment) but also feel accomplished when resolving them successfully. You feel excited about technical challenges like event sourcing and payment processing (Sep 12, Oct 2), energized by productive coding sessions, and deeply fulfilled by mentoring junior developers like Alex (Oct 2, Oct 30). You appreciate Mike's support and leadership. Overall, you love the work itself - especially the technical challenges and mentorship aspects - but struggle with work-life balance, particularly when deployments force late nights."

**Follow-up Question**: "What can I do to reduce work stress?"
**Expected Response**: "Based on your journal over Sep-Oct, here are some strategies:
1. Communicate concerns to Mike early - your honest conversation on Oct 22 about feeling stretched thin led to getting help with a senior engineer
2. Set clear boundaries on late work - you felt guilty on Sep 2 for coming home at 8pm
3. Prioritize family time - you consistently feel better after quality time with Sarah and the kids (farmers market, pumpkin patch, date nights)
4. Support Sarah's independence - her pottery class makes her happier, which improves the whole family dynamic
5. Remember why you work - you mentioned on Oct 31 'nights like this remind me what matters most'
6. Celebrate wins with team - the celebratory drinks after Oct 16 deployment helped you feel accomplished"

**Highlight**: "AI remembered previous conversation context AND analyzed patterns across 20 entries spanning 2 months to give personalized advice based on what actually worked for you in the past"

## Import Instructions

### Option 1: Manual Import via App

1. Open Kioku app
2. Settings → Data Management → Import from JSON
3. Select `presentation_demo.json`
4. Wait for import completion
5. Navigate to Insights → Trigger entity extraction
6. Wait 5-7 minutes for AI processing (20 entries)
7. Verify: Graph view shows 50+ entities

### Option 2: Clear & Import (Fresh Start)

1. Settings → Data Management → Clear All Data & Restart
2. App exits
3. Reopen app
4. Settings → Data Management → Import from JSON
5. Select `presentation_demo.json`
6. Insights → Extract entities for all entries
7. Wait 5-7 minutes for processing (20 entries)

### Option 3: Debug Export (Fastest for Testing)

1. Copy `presentation_demo.json` to project root
2. Build & run app in Xcode
3. Settings → Data Management → Export to Project Folder (DEBUG)
4. Settings → Clear All Data & Restart
5. Settings → Import from JSON → Select exported file
6. Verify import success

## Verification Checklist

After import, verify:
- [ ] 20 entries visible in Calendar view (Sep 2 - Oct 31, 2025)
- [ ] Entry content displays correctly (English text)
- [ ] Entity extraction triggered (check Settings → Entity Extraction)
- [ ] Graph view shows 50+ entities (9 people, 12 places, 15 events, 20+ emotions)
- [ ] Insights generated (at least 5-6 insights visible)
- [ ] Chat context includes related entries (test with a question)
- [ ] Relationships visible when tapping entity (e.g., Sarah has 10+ relationships)

## Demo Script for Presentation

**Total Time**: 3 minutes

**0:00 - 0:30 (Calendar View)**
"Here's my demo journal - 2 months (September-October) of a software engineer's life. 20 entries about work challenges, family moments, emotional ups and downs, fall traditions. Just raw text, like any normal journal."

**0:30 - 1:00 (Graph View)**
"But look what AI extracted: 50+ entities automatically from 20 entries. 9 people (Sarah is his wife, Emma and Jake are kids, Mike is manager), 12 places (farmers market, pumpkin patch, Italian restaurant), 15 events (soccer games, Halloween, deployments), and 20+ emotions. Color-coded: green for people, blue for places, pink for emotions. No manual tagging - AI did this."

**1:00 - 1:30 (Tap Sarah Entity)**
"Tap on Sarah. AI discovered she appears in ALL 20 entries - most important person in his life. Relationships shown: married_to, provides emotional support, pottery hobby, date nights. Knowledge graph built automatically across 2 months of data."

**1:30 - 2:00 (Insights Tab)**
"AI-generated insights spanning 2 months: 'You feel stressed when work has production issues' - pattern discovered from Sep 2 and Oct 16. 'Family time consistently triggers grateful emotions' - found across multiple entries. 'Sarah's pottery hobby correlates with her happiness' - noticed Sep 24, 28, Oct 19, 27. Actionable patterns from your own data."

**2:00 - 3:00 (Chat Demo)**
"Now the powerful part. Open Oct 5 entry, ask AI: 'When was the last time I spent quality time alone with Sarah?' AI reads 14+ entries in context - current entry, historical entries from 1 month prior, recent entries from past week, and 5 related entries via knowledge graph relationships.

Response: 'October 5th, date night at Italian restaurant downtown, first real date in 2 months, talked about pottery class and future dreams, felt like dating again...' Exact answer with date, location, emotional context. Not guessing - citing real data across 2-month span.

Follow-up: 'What can I do to reduce work stress?' AI analyzes patterns across 20 entries, gives personalized advice based on what worked: communicate with Mike (Oct 22), support Sarah's independence (pottery class), prioritize family traditions (pumpkin patch, Halloween), celebrate wins with team (Oct 16). Context-aware conversation with memory."

**Conclusion**: "That's AI-powered journaling with knowledge graph. Entity extraction, relationship discovery across 2 months, emotional insights, and context-aware chat with full conversation history - all from plain text entries."

## File Location

- **Source**: `/Users/phucnt/Workspace/kioku_ios/raw_data/presentation_demo.json`
- **Backup**: Commit to git for version control
- **Format**: Minimal JSON (only date + content per entry)

## Notes for Presenter

- This dataset tells a coherent 2-month story (Sep-Oct 2025: back-to-school → fall traditions → Halloween)
- Emotions are authentic and varied (20+ different emotions)
- Relationships are realistic and evolving (family dynamics, work challenges, mentorship growth)
- English content is natural and detailed (200-300 words per entry)
- Entities span all 5 types (People, Places, Events, Emotions, Topics)
- Seasonal progression (back-to-school → fall activities → Halloween) provides natural story arc
- Sarah's pottery hobby arc shows character development and relationship support
- Emma's milestones (soccer, field trip, school progress) show parenting journey
- Work projects (authentication → payment service) show technical progression
- Perfect for demonstrating all 4 core features (extraction, relationships, insights, chat)
- 20 entries provide richer data for entity co-occurrence and relationship strength
- 2-month timespan demonstrates temporal context and historical entry features

Good luck with your presentation! 🚀
