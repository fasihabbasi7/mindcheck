import 'package:flutter/material.dart';

import '../models/assessment_model.dart';

/// The eleven MindCheck assessments.
///
/// Licensing was checked before choosing each source (November 2026):
/// * IPIP items are public domain, free for any use, commercial included.
/// * Rosenberg Self-Esteem Scale: public domain (University of Maryland).
/// * GAD-7: no permission required to reproduce, display or distribute.
///   (Self-Esteem and Anxiety add MindCheck questions to Rosenberg and GAD-7
///   and score them together, so they are labelled "Adapted questionnaire".)
/// * ASRS v1.1 6-question screener: free, including commercial use, with
///   attribution and the copyright notice; the wording must not be changed.
/// * The Autism Spectrum Quotient (AQ) may not be used commercially and the
///   Narcissistic Personality Inventory (NPI) has no clear free licence, so
///   MindCheck uses its own clearly labelled self-reflection questions for
///   those two topics.
/// * Self-Compassion Scale (Neff, 2003): free for research or any other use.
/// * IPIP Optimism scale: public domain. MindCheck adds 10 of its own
///   "bouncing back" questions, so it is labelled "Adapted questionnaire".
/// * Copenhagen Burnout Inventory: freely available from the NFA (Denmark)
///   with attribution. MindCheck uses the personal and work-related scales.
/// * PHQ-9: no permission required to reproduce, translate, display or
///   distribute. Question 9 triggers support information when answered.
///
/// The order here is the order shown in the app.
const List<AssessmentModel> assessmentCatalog = <AssessmentModel>[
  AssessmentModel(
    id: 'big_five',
    title: 'Big Five Personality',
    tagline: 'Your profile across five core personality traits',
    description:
        'The Big Five is the most widely researched model of personality. '
        'This questionnaire describes where you sit on five broad '
        'dimensions. Every position on each dimension has its own strengths, '
        'and none of them is better or worse than another.',
    explores: <String>[
      'Openness',
      'Conscientiousness',
      'Extraversion',
      'Agreeableness',
      'Emotional stability',
    ],
    category: AssessmentCategory.personality,
    icon: Icons.hub_outlined,
    colors: <Color>[Color(0xFFB9ACF7), Color(0xFF7565D8)],
    questionCount: 50,
    estimatedMinutes: 7,
    answerFormat: '5 options, from Very inaccurate to Very accurate',
    resultLabel: 'Five-dimension personality profile',
    sourceType: SourceType.researchQuestionnaire,
    sourceName: 'IPIP Big-Five Factor Markers (50 items)',
    citation:
        'Goldberg, L. R. (1992). The development of markers for the Big-Five '
        'factor structure. Psychological Assessment, 4, 26–42. Items from the '
        'International Personality Item Pool (ipip.ori.org), public domain.',
    keywords: <String>['ocean', 'personality', 'traits', 'neuroticism'],
  ),
  AssessmentModel(
    id: 'introversion',
    title: 'Introversion & Extroversion',
    tagline: 'Where you sit on the social-energy spectrum',
    description:
        'Some people recharge in company, others in quiet time, and most of '
        'us sit somewhere in between. This questionnaire shows where your '
        'answers place you on the introversion–extroversion spectrum. '
        'Neither end is better; each comes with its own strengths.',
    explores: <String>[
      'Social energy',
      'Communication',
      'Group activities',
      'Comfort in social settings',
      'Need for solitude',
    ],
    category: AssessmentCategory.personality,
    icon: Icons.groups_outlined,
    colors: <Color>[Color(0xFFA5B8FA), Color(0xFF5F6FD6)],
    questionCount: 20,
    estimatedMinutes: 3,
    answerFormat: '5 options, from Very inaccurate to Very accurate',
    resultLabel: 'Introversion–extroversion spectrum',
    sourceType: SourceType.researchQuestionnaire,
    sourceName: 'IPIP Big-Five Factor Markers – Extraversion scale (20 items)',
    citation:
        'Goldberg, L. R. (1992). The development of markers for the Big-Five '
        'factor structure. Psychological Assessment, 4, 26–42. Items from the '
        'International Personality Item Pool (ipip.ori.org), public domain.',
    keywords: <String>['introvert', 'extrovert', 'extravert', 'social'],
  ),
  AssessmentModel(
    id: 'self_esteem',
    title: 'Self-Esteem',
    tagline: 'How you see and value yourself',
    description:
        'Self-esteem is your overall sense of your own worth. This '
        'assessment combines the classic Rosenberg Self-Esteem Scale with '
        'extra MindCheck questions on confidence, boundaries and your inner '
        'voice. Self-esteem naturally changes over time, so treat the result '
        'as a snapshot of right now.',
    explores: <String>[
      'Self-worth',
      'Self-acceptance',
      'Self-respect',
      'Confidence',
      'Self-perception',
      'Inner voice',
    ],
    category: AssessmentCategory.wellbeing,
    icon: Icons.self_improvement_rounded,
    colors: <Color>[Color(0xFFF2C1EE), Color(0xFFB36BD4)],
    questionCount: 25,
    estimatedMinutes: 4,
    answerFormat: '4 options, from Strongly agree to Strongly disagree',
    resultLabel: 'Self-esteem profile across six areas',
    sourceType: SourceType.adaptedQuestionnaire,
    sourceName: 'Rosenberg Self-Esteem Scale + MindCheck questions',
    citation:
        'Questions 1–10: Rosenberg, M. (1965). Society and the Adolescent '
        'Self-Image. Princeton University Press. Public domain. '
        'Questions 11–25: written for MindCheck. Because the questions are '
        'scored together, the result is not a Rosenberg scale score.',
    keywords: <String>['confidence', 'self worth', 'rosenberg', 'boundaries'],
  ),
  AssessmentModel(
    id: 'anxiety',
    title: 'Anxiety',
    tagline: 'How often worry and nervousness affect you',
    description:
        'This assessment asks how often you have been bothered by common '
        'anxiety-related experiences, such as worry, overthinking, physical '
        'tension and difficulty relaxing. It combines the GAD-7 questions '
        'with extra MindCheck questions, so the result describes your '
        'experiences and cannot screen for or diagnose an anxiety disorder.',
    explores: <String>[
      'Worry & overthinking',
      'Nervousness',
      'Physical tension',
      'Difficulty relaxing',
      'Fear & apprehension',
      'Stress response',
    ],
    category: AssessmentCategory.wellbeing,
    icon: Icons.air_rounded,
    colors: <Color>[Color(0xFFB9D3FA), Color(0xFF6A8FE0)],
    questionCount: 25,
    estimatedMinutes: 4,
    answerFormat: '4 options, from Not at all to Nearly every day',
    resultLabel: 'Anxiety-related profile across six areas',
    sourceType: SourceType.adaptedQuestionnaire,
    sourceName: 'GAD-7 + MindCheck questions',
    citation:
        'Questions 1–7: GAD-7. Spitzer, R. L., Kroenke, K., Williams, '
        'J. B. W., & Löwe, B. (2006). Archives of Internal Medicine, 166, '
        '1092–1097. Developed with an educational grant from Pfizer Inc. No '
        'permission required to reproduce, translate, display or distribute. '
        'Questions 8–25: written for MindCheck. Because the questions are '
        'scored together, the result is not a GAD-7 score.',
    timeframe: 'Over the last 2 weeks',
    keywords: <String>['gad', 'gad-7', 'stress', 'worry', 'overthinking'],
  ),
  AssessmentModel(
    id: 'adhd',
    title: 'ADHD-Related Traits',
    tagline: 'Attention, focus and restlessness in daily life',
    description:
        'Part 1 is a short screener developed with the World Health '
        'Organization that asks about attention, organisation and '
        'restlessness in adults. A higher score means some experiences may '
        'be worth discussing with a qualified professional; it cannot tell '
        'you whether you have ADHD. Part 2 adds MindCheck questions about '
        'everyday patterns such as focus, time management and impulsivity. '
        'They give you a separate profile and never change the screener score.',
    explores: <String>[
      'Attention',
      'Organisation',
      'Task completion',
      'Time management',
      'Impulsivity',
      'Restlessness',
    ],
    category: AssessmentCategory.neurodiversity,
    icon: Icons.bolt_rounded,
    colors: <Color>[Color(0xFFD5B8FA), Color(0xFF9358D8)],
    questionCount: 20,
    estimatedMinutes: 3,
    answerFormat: '5 options, from Never to Very often',
    resultLabel: 'ASRS screening insight + everyday patterns profile',
    sourceType: SourceType.validatedScreener,
    sourceName: 'Adult ADHD Self-Report Scale (ASRS v1.1) Screener '
        '+ MindCheck everyday patterns',
    citation:
        'Questions 1–6: Kessler, R. C., Adler, L., Ames, M., et al. (2005). '
        'The World Health Organization Adult ADHD Self-Report Scale (ASRS): '
        'a short screening scale for use in the general population. '
        'Psychological Medicine, 35(2), 245–256. Used unaltered, with the '
        'official scoring. Questions 7–20: written for MindCheck, scored '
        'separately and not validated.',
    copyrightNotice:
        'ASRS v1.1 Screener © New York University and President and Fellows '
        'of Harvard College. All rights reserved.',
    officialUrl: 'https://www.hcp.med.harvard.edu/ncs/asrs.php',
    timeframe: 'Over the past 6 months',
    audienceNote: 'Designed for adults aged 18 and over',
    keywords: <String>['adhd', 'add', 'focus', 'concentration', 'asrs'],
  ),
  AssessmentModel(
    id: 'autism',
    title: 'Autism-Related Traits',
    tagline: 'Social, sensory and routine preferences',
    description:
        'A gentle self-reflection on experiences that some autistic people '
        'describe, such as sensory sensitivity, a preference for routine and '
        'deep interests. Many people relate to some of these. Your result '
        'describes self-reported traits only and is not an autism screening '
        'or diagnosis.',
    explores: <String>[
      'Social communication',
      'Social interaction',
      'Sensory experiences',
      'Routines',
      'Repetitive patterns',
      'Special interests',
      'Communication preferences',
    ],
    category: AssessmentCategory.neurodiversity,
    icon: Icons.extension_outlined,
    colors: <Color>[Color(0xFFA8D8F5), Color(0xFF5E9BD8)],
    questionCount: 35,
    estimatedMinutes: 5,
    answerFormat: '5 options, from Strongly disagree to Strongly agree',
    resultLabel: 'Self-reported trait profile',
    sourceType: SourceType.selfReflection,
    sourceName: 'MindCheck Autism-Related Traits Self-Reflection',
    citation:
        'Original questions written for MindCheck. Not adapted from, and not '
        'equivalent to, any validated autism screening instrument.',
    keywords: <String>['autism', 'asd', 'sensory', 'routine', 'aspergers'],
  ),
  AssessmentModel(
    id: 'narcissism',
    title: 'Narcissistic Traits',
    tagline: 'Recognition, competition and empathy',
    description:
        'Everyone has some narcissistic traits, such as wanting recognition '
        'or feeling stung by criticism, and in balance some of them can even '
        'be useful. This self-reflection shows which of these traits stand '
        'out in your answers. It does not assess Narcissistic Personality '
        'Disorder.',
    explores: <String>[
      'Self-importance',
      'Need for admiration',
      'Attention-seeking',
      'Entitlement',
      'Sensitivity to criticism',
      'Empathy',
      'Competition',
      'Recognition-seeking',
    ],
    category: AssessmentCategory.personality,
    icon: Icons.person_search_outlined,
    colors: <Color>[Color(0xFFF5BDD9), Color(0xFFC9659C)],
    questionCount: 40,
    estimatedMinutes: 6,
    answerFormat: '5 options, from Strongly disagree to Strongly agree',
    resultLabel: 'Narcissistic trait profile',
    sourceType: SourceType.selfReflection,
    sourceName: 'MindCheck Narcissistic Traits Self-Reflection',
    citation:
        'Original questions written for MindCheck. Not adapted from, and not '
        'equivalent to, the Narcissistic Personality Inventory or any other '
        'validated instrument.',
    keywords: <String>['narcissism', 'narcissist', 'ego', 'empathy'],
  ),
  AssessmentModel(
    id: 'self_compassion',
    title: 'Self-Compassion',
    tagline: 'How you treat yourself when things get hard',
    description:
        'Self-compassion means meeting your own mistakes and hard moments '
        'with the same kindness you would offer a friend. This questionnaire '
        'looks at six sides of how you relate to yourself, three kind and '
        'three harsh, so you can see where you are gentle with yourself and '
        'where your inner critic is loudest.',
    explores: <String>[
      'Self-kindness',
      'Self-judgment',
      'Common humanity',
      'Isolation',
      'Mindfulness',
      'Over-identification',
    ],
    category: AssessmentCategory.wellbeing,
    icon: Icons.volunteer_activism_outlined,
    colors: <Color>[Color(0xFFF9C9D4), Color(0xFFD9708E)],
    questionCount: 26,
    estimatedMinutes: 4,
    answerFormat: '5 options, from Almost never to Almost always',
    resultLabel: 'Self-compassion score + six-area profile',
    sourceType: SourceType.researchQuestionnaire,
    sourceName: 'Self-Compassion Scale (SCS, 26 items)',
    citation:
        'Neff, K. D. (2003). The development and validation of a scale to '
        'measure self-compassion. Self and Identity, 2, 223–250. Used '
        'unaltered with the author\'s general permission for any use.',
    officialUrl: 'https://self-compassion.org',
    keywords: <String>['compassion', 'kindness', 'self-criticism', 'neff'],
  ),
  AssessmentModel(
    id: 'optimism',
    title: 'Optimism & Resilience',
    tagline: 'Your outlook and how you bounce back',
    description:
        'Optimism is the general expectation that things will work out. '
        'Resilience is how you recover when they do not. This questionnaire '
        'combines a public-domain optimism scale with MindCheck questions '
        'about bouncing back, so you can see what supports you and what '
        'could use some care.',
    explores: <String>[
      'Positive outlook',
      'Mood steadiness',
      'Bouncing back',
      'Coping resources',
    ],
    category: AssessmentCategory.wellbeing,
    icon: Icons.wb_sunny_outlined,
    colors: <Color>[Color(0xFFFFDDA6), Color(0xFFE59A3C)],
    questionCount: 20,
    estimatedMinutes: 3,
    answerFormat: '5 options, from Very inaccurate to Very accurate',
    resultLabel: 'Optimism & resilience score + four-area profile',
    sourceType: SourceType.adaptedQuestionnaire,
    sourceName: 'IPIP Optimism scale (10 items) + MindCheck bouncing back',
    citation:
        'Questions 1–10: International Personality Item Pool (ipip.ori.org) '
        'Optimism scale, keyed to Scheier, Carver & Bridges (1994). Public '
        'domain. Questions 11–20: written for MindCheck and not validated.',
    keywords: <String>['optimism', 'resilience', 'hope', 'outlook'],
  ),
  AssessmentModel(
    id: 'burnout',
    title: 'Burnout',
    tagline: 'Exhaustion in daily life and at work or study',
    description:
        'Burnout is a state of long-lasting physical and emotional '
        'exhaustion. This questionnaire uses two scales of the Copenhagen '
        'Burnout Inventory: one about exhaustion in general and one about '
        'exhaustion linked to your work. Students can answer about their '
        'studies.',
    explores: <String>[
      'Personal burnout',
      'Work-related burnout',
    ],
    category: AssessmentCategory.wellbeing,
    icon: Icons.battery_alert_rounded,
    colors: <Color>[Color(0xFFFFC2A8), Color(0xFFE0714F)],
    questionCount: 13,
    estimatedMinutes: 2,
    answerFormat: '5 options, from Never to Always (or degree)',
    resultLabel: 'Burnout score + two scale scores (0–100)',
    sourceType: SourceType.researchQuestionnaire,
    sourceName: 'Copenhagen Burnout Inventory (CBI) – personal and '
        'work-related scales',
    citation:
        'Kristensen, T. S., Borritz, M., Villadsen, E., & Christensen, K. B. '
        '(2005). The Copenhagen Burnout Inventory: A new tool for the '
        'assessment of burnout. Work & Stress, 19(3), 192–207. Freely '
        'available from the National Research Centre for the Working '
        'Environment (NFA), Denmark.',
    keywords: <String>['burnout', 'exhaustion', 'work', 'stress', 'tired'],
  ),
  AssessmentModel(
    id: 'low_mood',
    title: 'Low Mood (PHQ-9)',
    tagline: 'A gentle check-in on how you have been feeling',
    description:
        'The PHQ-9 is a short, widely used questionnaire about common '
        'symptoms of low mood over the last two weeks. Your result shows how '
        'much these symptoms have been bothering you. It is a screening '
        'check-in, not a diagnosis of depression.',
    explores: <String>[
      'Interest and enjoyment',
      'Mood',
      'Sleep and energy',
      'Appetite',
      'Self-worth',
      'Concentration',
    ],
    category: AssessmentCategory.wellbeing,
    icon: Icons.cloud_outlined,
    colors: <Color>[Color(0xFFB6D3F2), Color(0xFF5B87C7)],
    questionCount: 9,
    estimatedMinutes: 2,
    answerFormat: '4 options, from Not at all to Nearly every day',
    resultLabel: 'PHQ-9 score (0–27)',
    sourceType: SourceType.validatedScreener,
    sourceName: 'Patient Health Questionnaire (PHQ-9)',
    citation:
        'Kroenke, K., Spitzer, R. L., & Williams, J. B. (2001). The PHQ-9: '
        'validity of a brief depression severity measure. Journal of General '
        'Internal Medicine, 16(9), 606–613. Used unaltered.',
    copyrightNotice:
        'PHQ-9 developed by Drs. Robert L. Spitzer, Janet B. W. Williams, '
        'Kurt Kroenke and colleagues, with an educational grant from Pfizer '
        'Inc. No permission required to reproduce, translate, display or '
        'distribute.',
    officialUrl: 'https://www.phqscreeners.com',
    timeframe: 'Over the last 2 weeks',
    audienceNote: 'Designed for adults aged 18 and over',
    keywords: <String>['depression', 'mood', 'sad', 'phq', 'phq9', 'low'],
  ),
];
