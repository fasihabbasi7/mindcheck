# MindCheck – Testing Checklist

Work through this list on a real phone before every release.
Tick each box. If something fails, note the screen and what happened.

## 0. Automatic checks

Run in the project folder:

```
flutter pub get
flutter analyze        # should report: No issues found
flutter test           # all tests should pass
```

The tests check every question file, the scoring for all 7 assessments,
and that results, unfinished assessments and journal entries save and load
correctly.

## 1. First launch

- [ ] Uninstall the app, then install and open it.
- [ ] Splash shows the floating brain, then onboarding opens.
- [ ] Page 1: type a first name. Page 2: chips show all 7 assessments.
- [ ] "Skip" jumps to page 3 (it does not skip the disclaimer).
- [ ] "Get started" stays disabled until the disclaimer box is ticked.
- [ ] Home greets you by name ("Hello, Sara 👋").
- [ ] Close and reopen the app: it goes straight to Home.

## 2. Home

- [ ] Brain animates; stat cards show "7 tests" and the real completed count.
- [ ] Search bar opens Explore with the keyboard ready.
- [ ] Featured card and the sideways list open the details screen.
- [ ] Today's reflection opens the journal editor; saved text shows on the card.
- [ ] With an unfinished assessment, a "Continue where you left off" card shows.

## 3. Explore

- [ ] Search "focus" shows ADHD; "worry" shows Anxiety; nonsense shows "No matches".
- [ ] Filters: All, Saved, Personality, Wellbeing, Neurodiversity.
- [ ] Bookmark an assessment; it appears under "Saved"; un-bookmark removes it.

## 4. Taking each assessment (repeat for all 7)

| Assessment | Questions | Done |
|---|---|---|
| Big Five | 50 | [ ] |
| Introversion & Extroversion | 20 | [ ] |
| Self-Esteem | 25 | [ ] |
| Anxiety | 25 | [ ] |
| ADHD-Related Traits | 6 (shaded answers visible) | [ ] |
| Autism-Related Traits | 35 | [ ] |
| Narcissistic Traits | 40 | [ ] |

For each:
- [ ] Details → Start → Instructions show the correct count and time.
- [ ] "Next" is disabled until an answer is chosen.
- [ ] "Back" keeps earlier answers; changing one keeps you on that question.
- [ ] "Auto" toggle on: moves on after answering; off: waits for Next.
- [ ] On the last question, Review lists any unanswered questions; tapping one jumps there.
- [ ] Submit is only possible when everything is answered.
- [ ] Completion → View my results opens the report.

## 5. Reports

- [ ] Big Five: radar chart + five bars, no single total.
- [ ] Introversion: spectrum bar with marker and strengths chips.
- [ ] ADHD: gauge "x out of 24" and the shaded-boxes card.
- [ ] Others: gauge out of 100, highlighted traits, suggestions.
- [ ] Support message appears for high anxiety / low self-esteem / positive ADHD screen.
- [ ] "See detailed breakdown" shows every trait with reflect + tip.
- [ ] "Share as PDF" asks first, then opens the share sheet; open the PDF and check it.
- [ ] Wording never says "you have", "you are autistic", etc.

## 6. Resume unfinished

- [ ] Answer a few questions, press ✕, choose "Save & exit".
- [ ] Fully close the app (swipe it away), reopen: Home shows "Continue".
- [ ] Continue resumes at the same question with answers kept.
- [ ] Instructions screen offers Continue / Start over; Start over asks to confirm.
- [ ] "Discard" removes the saved progress.

## 7. History & comparisons

- [ ] Results tab lists reports, newest first, with scores.
- [ ] Filter by assessment works; deleting asks to confirm and removes it.
- [ ] Take the same assessment twice: report shows "Compared with your last attempt".
- [ ] Three or more attempts: the trend chart appears.
- [ ] Journal tab lists entries; tap to edit; delete asks to confirm.

## 8. Settings & privacy

- [ ] Change name; Home greeting updates.
- [ ] Auto-next switch matches the "Auto" pill on the question screen.
- [ ] System / Light / Dark all work, and the choice survives a restart.
- [ ] Privacy information and About & disclaimer pages open.
- [ ] Delete assessment history / journal / all data each ask to confirm and work.
- [ ] After "Delete all my data": no results, no journal, no bookmarks, no name.

## 9. Offline, dark mode, screens

- [ ] Turn on airplane mode, force-close, reopen: everything works, PDF still shares.
- [ ] Repeat sections 2–5 quickly in dark mode; all text is readable.
- [ ] Try a small phone (or Display size: Largest + Font size: Largest): nothing overlaps or is cut off.
- [ ] Rotate the phone on the question screen: answers are kept.
- [ ] Turn on "Remove animations" (Accessibility): the brain and orb stop moving.

## 10. Midnight

- [ ] Write today's reflection, change the phone's date to tomorrow, return to the app:
      a new question appears and the old entry is in the Journal under yesterday.

## 11. New assessments

- [ ] Explore shows 11 assessments; Wellbeing filter includes Self-Compassion, Optimism & Resilience, Burnout and Low Mood (PHQ-9).
- [ ] Burnout: questions 7–9 show "To a very low degree … To a very high degree"; the others show "Never / almost never … Always".
- [ ] Low Mood: on question 9, choose "Several days". The support card appears at once under the answers, and Auto-next does NOT move on.
- [ ] Finish Low Mood with question 9 above "Not at all": the support card is at the top of the report and in the PDF, and there is no celebration.
- [ ] Low Mood with every answer "More than half the days" shows 18 out of 27, "Moderately severe symptoms".

## 12. Motion and haptics

- [ ] Choosing an answer gives a light tick; Submit gives a firmer tap (needs a real phone, with touch vibration on).
- [ ] A fresh report: the score counts up, then bars fill one by one, then a small sparkle burst with a light tap.
- [ ] Opening an old report from History shows the count-up but no sparkle burst.
- [ ] Press and hold a card on Home or Explore: it tilts towards your finger and springs back on release. Scrolling still works normally.
- [ ] Scroll Home slowly: the brain moves more slowly than the cards.
- [ ] Soft specks drift on Home, onboarding, completion and reports.
- [ ] With "Remove animations" on: no tilt, parallax, specks, count-up or sparkles; everything still appears.
