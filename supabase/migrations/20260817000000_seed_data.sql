/*
# GovBridge — Seed Data

## Purpose
Populate categories, schemes, jobs, internships, and scholarships with real,
well-known Indian government programs (Central + Tamil Nadu focus) so the
app has live content to browse instead of the frontend's hardcoded fallback.

## Notes
- Category slugs match the frontend's fallbackCategories in src/App.tsx exactly,
  so once this runs, `supabase.from('categories').select('*')` replaces the
  fallback seamlessly.
- eligibility_rules JSONB uses the keys the frontend's EligibilityModal reads:
  `states` (array or "all"), `student` (bool), `farmer` (bool).
- last_date values are illustrative rolling deadlines — update via admin panel
  as real cutoffs are confirmed.
*/

-- CATEGORIES
INSERT INTO categories (slug, name, name_ta, name_hi, icon, description) VALUES
  ('scholarships', 'Scholarships', 'உதவித்தொகைகள்', 'छात्रवृत्ति', 'GraduationCap', 'Financial aid for students'),
  ('farmers', 'Farmers', 'விவசாயிகள்', 'किसान', 'Leaf', 'Support for India''s farmers'),
  ('women-welfare', 'Women welfare', 'பெண்கள் நலன்', 'महिला कल्याण', 'Heart', 'Empowerment and welfare'),
  ('healthcare', 'Healthcare', 'சுகாதாரம்', 'स्वास्थ्य', 'ShieldCheck', 'Health and medical assistance'),
  ('skill-development', 'Skill development', 'திறன் மேம்பாடு', 'कौशल विकास', 'TrendingUp', 'Learn. Grow. Earn.'),
  ('government-jobs', 'Government jobs', 'அரசு வேலைகள்', 'सरकारी नौकरियाँ', 'BriefcaseBusiness', 'Your next opportunity'),
  ('housing', 'Housing', 'வீடமைப்பு', 'आवास', 'Home', 'A home for every family'),
  ('pension', 'Pension', 'ஓய்வூதியம்', 'पेंशन', 'WalletCards', 'Support for every stage of life')
ON CONFLICT (slug) DO NOTHING;

-- SCHEMES
INSERT INTO schemes (title, title_ta, category_id, state, ministry, overview, benefits, eligibility, eligibility_rules, documents, process, last_date, official_url, simple_explanation, simple_explanation_ta, languages, tags, featured)
SELECT * FROM (VALUES
  (
    'PM-KISAN Samman Nidhi',
    'பிஎம்-கிசான் சம்மான் நிதி',
    (SELECT id FROM categories WHERE slug = 'farmers'),
    'Central', 'Ministry of Agriculture & Farmers Welfare',
    'Income support scheme for landholding farmer families across India, paid directly to bank accounts in three installments.',
    'Rs. 6,000 per year paid in three equal installments of Rs. 2,000 every four months.',
    'Small and marginal landholding farmer families with cultivable land, subject to state land records.',
    '{"states":["all"],"farmer":true}'::jsonb,
    'Aadhaar card, land ownership records, bank account passbook, mobile number.',
    'Register via the PM-KISAN portal or through the local Common Service Centre (CSC); local revenue officials verify land records.',
    '2026-12-31', 'https://pmkisan.gov.in',
    'Farmers get Rs. 6,000 every year, split into three payments, directly in their bank account.',
    'விவசாயிகளுக்கு ஆண்டுக்கு ரூ.6,000 மூன்று தவணைகளாக நேரடியாக வங்கிக் கணக்கில் வழங்கப்படும்.',
    ARRAY['English','Tamil','Hindi'], ARRAY['farmer','income-support','central'], true
  ),
  (
    'Ayushman Bharat – PM Jan Arogya Yojana (PMJAY)',
    'ஆயுஷ்மான் பாரத் – பிஎம் ஜன் ஆரோக்ய யோஜனா',
    (SELECT id FROM categories WHERE slug = 'healthcare'),
    'Central', 'Ministry of Health and Family Welfare',
    'World''s largest health assurance scheme offering free secondary and tertiary hospitalisation coverage to economically vulnerable families.',
    'Health cover of Rs. 5 lakh per family per year for hospitalisation at empanelled hospitals.',
    'Families identified as deprived under SECC 2011 database; no age or family size cap.',
    '{"states":["all"]}'::jsonb,
    'Aadhaar card, ration card, income certificate (if applicable).',
    'Check eligibility on the PMJAY website, visit the nearest Ayushman Bharat kiosk or empanelled hospital to get your Ayushman card made.',
    '2026-12-31', 'https://pmjay.gov.in',
    'Eligible families get free hospital treatment worth up to Rs. 5 lakh a year.',
    'தகுதியுள்ள குடும்பங்களுக்கு ஆண்டுக்கு ரூ.5 லட்சம் வரை இலவச மருத்துவமனை சிகிச்சை.',
    ARRAY['English','Tamil','Hindi'], ARRAY['healthcare','insurance','central'], true
  ),
  (
    'National Scholarship Portal – Post-Matric Scholarship',
    'தேசிய உதவித்தொகை போர்டல் – முதுகல்வி உதவித்தொகை',
    (SELECT id FROM categories WHERE slug = 'scholarships'),
    'Central', 'Ministry of Social Justice and Empowerment',
    'Central scholarship for SC/ST/OBC and minority students studying post-matriculation (class 11 onwards, including college).',
    'Covers tuition fees, maintenance allowance, and other education-related costs depending on course and category.',
    'Students from SC/ST/OBC/minority communities enrolled in a recognised post-matric course, family income within prescribed limits.',
    '{"states":["all"],"student":true}'::jsonb,
    'Aadhaar card, caste certificate, income certificate, previous mark sheet, bank passbook, institution bonafide certificate.',
    'Apply online through the National Scholarship Portal (scholarships.gov.in) during the annual application window; institution verifies and forwards the application.',
    '2026-10-31', 'https://scholarships.gov.in',
    'Students from reserved categories can get help with tuition and living costs for college.',
    'இட ஒதுக்கீடு பிரிவைச் சேர்ந்த மாணவர்களுக்கு கல்விக் கட்டணம் மற்றும் படிப்புச் செலவுக்கு உதவி.',
    ARRAY['English','Tamil','Hindi'], ARRAY['student','scholarship','central'], true
  ),
  (
    'Kalaignar Scholarship for Higher Education (Tamil Nadu)',
    'கலைஞர் உயர்கல்வி ஊக்கத் தொகை திட்டம்',
    (SELECT id FROM categories WHERE slug = 'scholarships'),
    'Tamil Nadu', 'Department of Higher Education, Government of Tamil Nadu',
    'Tamil Nadu state scholarship supporting first-generation graduates and economically weaker students pursuing higher education in state institutions.',
    'One-time or annual financial assistance amount credited directly to the student''s bank account.',
    'Tamil Nadu domicile students admitted to government or government-aided colleges within the state, meeting income criteria.',
    '{"states":["Tamil Nadu"],"student":true}'::jsonb,
    'Aadhaar card, Tamil Nadu community/income certificate, college admission proof, bank passbook.',
    'Apply through the college''s student welfare office or the TN e-Sevai portal during the admission cycle.',
    '2026-09-30', 'https://tnschools.gov.in',
    'Tamil Nadu students in government colleges can get scholarship money to help with their studies.',
    'தமிழ்நாடு அரசு கல்லூரி மாணவர்களுக்கு படிப்புக்கு நிதி உதவி.',
    ARRAY['English','Tamil'], ARRAY['student','scholarship','tamil-nadu'], true
  ),
  (
    'Pradhan Mantri Awas Yojana – Gramin (PMAY-G)',
    'பிரதம மந்திரி ஆவாஸ் யோஜனா – கிராமீன்',
    (SELECT id FROM categories WHERE slug = 'housing'),
    'Central', 'Ministry of Rural Development',
    'Housing scheme providing financial assistance to rural households to construct a pucca house.',
    'Financial assistance of approximately Rs. 1.2 lakh (plain areas) or Rs. 1.3 lakh (hilly/difficult areas) for house construction.',
    'Houseless families or those living in kutcha/dilapidated houses in rural areas, identified via SECC data.',
    '{"states":["all"]}'::jsonb,
    'Aadhaar card, job card (if MGNREGA linked), bank passbook, land documents.',
    'Beneficiaries are shortlisted via the Gram Sabha using SECC data; approved applicants can check status on the PMAY-G portal.',
    '2026-12-31', 'https://pmayg.nic.in',
    'Rural families without a proper house get money to build one.',
    'கிராமப்புற குடும்பங்களுக்கு வீடு கட்ட நிதி உதவி.',
    ARRAY['English','Hindi'], ARRAY['housing','rural','central'], false
  ),
  (
    'Pradhan Mantri Awas Yojana – Urban (PMAY-U)',
    'பிரதம மந்திரி ஆவாஸ் யோஜனா – நகர்ப்புறம்',
    (SELECT id FROM categories WHERE slug = 'housing'),
    'Central', 'Ministry of Housing and Urban Affairs',
    'Affordable housing scheme for urban poor, offering interest subsidy on home loans and direct construction assistance.',
    'Credit-linked subsidy on home loan interest, or direct assistance for construction/enhancement of a house.',
    'Economically Weaker Section (EWS) and Low Income Group (LIG) urban households without a pucca house.',
    '{"states":["all"]}'::jsonb,
    'Aadhaar card, income certificate, property documents, bank loan sanction letter (if applicable).',
    'Apply via the PMAY-U portal or through the local Urban Local Body office; banks process the interest subsidy directly.',
    '2026-12-31', 'https://pmay-urban.gov.in',
    'City families with low income get help with a home loan or house building costs.',
    'நகர்ப்புற ஏழை குடும்பங்களுக்கு வீட்டுக் கடன் அல்லது கட்டுமான உதவி.',
    ARRAY['English','Hindi'], ARRAY['housing','urban','central'], false
  ),
  (
    'Pradhan Mantri Matru Vandana Yojana (PMMVY)',
    'பிரதம மந்திரி மாத்ரு வந்தனா யோஜனா',
    (SELECT id FROM categories WHERE slug = 'women-welfare'),
    'Central', 'Ministry of Women and Child Development',
    'Maternity benefit scheme giving cash incentives to pregnant and lactating women for the first live birth.',
    'Rs. 5,000 in three installments linked to specific conditions (registration, ante-natal checkup, child immunisation).',
    'Pregnant and lactating women aged 19 years and above, for their first living child.',
    '{"states":["all"]}'::jsonb,
    'Aadhaar card, MCP (Mother and Child Protection) card, bank passbook.',
    'Register at the nearest Anganwadi Centre or health facility; benefits released in stages after conditions are met.',
    '2026-12-31', 'https://pmmvy.wcd.gov.in',
    'New mothers get Rs. 5,000 in installments to support health and nutrition.',
    'புதிய தாய்மார்களுக்கு சுகாதாரம் மற்றும் ஊட்டச்சத்துக்காக ரூ.5,000 நிதி உதவி.',
    ARRAY['English','Tamil','Hindi'], ARRAY['women','maternity','central'], false
  ),
  (
    'Moovalur Ramamirtham Ammaiyar Ninaivu Marriage Assistance (Tamil Nadu)',
    'மூவலூர் ராமாமிர்தம் அம்மையார் நினைவு திருமண உதவித் திட்டம்',
    (SELECT id FROM categories WHERE slug = 'women-welfare'),
    'Tamil Nadu', 'Department of Social Welfare, Government of Tamil Nadu',
    'Tamil Nadu scheme providing financial assistance for marriage of orphaned or destitute women graduates.',
    'One-time cash assistance deposited to the bride''s bank account at the time of marriage.',
    'Graduate women who are orphans, destitute, or from very low-income families, resident of Tamil Nadu.',
    '{"states":["Tamil Nadu"]}'::jsonb,
    'Aadhaar card, degree certificate, marriage invitation/proof, income certificate, bank passbook.',
    'Apply through the Taluk Social Welfare Office with required certificates before the marriage date.',
    '2026-12-31', 'https://socialwelfare.tn.gov.in',
    'Tamil Nadu women graduates from poor families get money to help with wedding costs.',
    'தமிழ்நாடு பட்டதாரி பெண்களுக்கு திருமண செலவுக்கு நிதி உதவி.',
    ARRAY['English','Tamil'], ARRAY['women','marriage','tamil-nadu'], false
  ),
  (
    'Pradhan Mantri Kaushal Vikas Yojana (PMKVY)',
    'பிரதம மந்திரி கௌசல் விகாஸ் யோஜனா',
    (SELECT id FROM categories WHERE slug = 'skill-development'),
    'Central', 'Ministry of Skill Development and Entrepreneurship',
    'Flagship skill training scheme offering free short-term training and certification aligned to industry needs.',
    'Free skill training, certification, and placement assistance; a monetary reward on successful assessment for certain batches.',
    'Indian youth aged 15–45, especially school/college dropouts and unemployed individuals.',
    '{"states":["all"],"student":true}'::jsonb,
    'Aadhaar card, education certificates (if any), bank passbook.',
    'Locate a nearby PMKVY training centre via the official portal and enrol for an available course batch.',
    '2026-12-31', 'https://pmkvyofficial.org',
    'Youth get free skill training and a certificate to help them get a job.',
    'இளைஞர்களுக்கு இலவச திறன் பயிற்சி மற்றும் சான்றிதழ் வழங்கப்படும்.',
    ARRAY['English','Tamil','Hindi'], ARRAY['skill','training','central'], true
  ),
  (
    'Naan Mudhalvan Skill Development Scheme (Tamil Nadu)',
    'நான் முதல்வன் திறன் மேம்பாட்டுத் திட்டம்',
    (SELECT id FROM categories WHERE slug = 'skill-development'),
    'Tamil Nadu', 'Department of Higher Education, Government of Tamil Nadu',
    'Tamil Nadu''s flagship employability programme offering industry-aligned skill training to college students and youth.',
    'Free certified training in technical and soft skills, industry mentorship, and placement support.',
    'Tamil Nadu college students and unemployed youth interested in improving job readiness.',
    '{"states":["Tamil Nadu"],"student":true}'::jsonb,
    'Aadhaar card, college ID or education proof.',
    'Register through the Naan Mudhalvan portal; colleges also enrol students in batches directly.',
    '2026-12-31', 'https://naanmudhalvan.tn.gov.in',
    'Tamil Nadu students get free skill training to become more job-ready.',
    'தமிழ்நாடு மாணவர்களுக்கு இலவச திறன் பயிற்சி வழங்கப்படும்.',
    ARRAY['English','Tamil'], ARRAY['skill','training','tamil-nadu','student'], true
  ),
  (
    'Indira Gandhi National Old Age Pension Scheme (IGNOAPS)',
    'இந்திரா காந்தி தேசிய முதியோர் ஓய்வூதியத் திட்டம்',
    (SELECT id FROM categories WHERE slug = 'pension'),
    'Central', 'Ministry of Rural Development',
    'Monthly pension support for elderly citizens living below the poverty line.',
    'Monthly pension amount (varies by state top-up) credited directly to the beneficiary''s bank or post office account.',
    'Citizens aged 60 years and above belonging to a household below the poverty line.',
    '{"states":["all"]}'::jsonb,
    'Aadhaar card, age proof, BPL card, bank/post office passbook.',
    'Apply at the local Gram Panchayat or Municipal office with proof of age and BPL status.',
    '2026-12-31', 'https://nsap.nic.in',
    'Poor senior citizens get a monthly pension to help cover living costs.',
    'ஏழை முதியோர்களுக்கு மாதாந்திர ஓய்வூதியம் வழங்கப்படும்.',
    ARRAY['English','Hindi'], ARRAY['pension','senior-citizen','central'], false
  ),
  (
    'Tamil Nadu Old Age Pension Scheme',
    'தமிழ்நாடு முதியோர் ஓய்வூதியத் திட்டம்',
    (SELECT id FROM categories WHERE slug = 'pension'),
    'Tamil Nadu', 'Department of Social Welfare, Government of Tamil Nadu',
    'State-run monthly pension for elderly, destitute, and needy citizens of Tamil Nadu.',
    'Monthly pension credited to the beneficiary''s bank account, higher than the central IGNOAPS base amount.',
    'Tamil Nadu residents aged 60 and above with no regular means of income or family support.',
    '{"states":["Tamil Nadu"]}'::jsonb,
    'Aadhaar card, age proof, income certificate, bank passbook.',
    'Apply at the Taluk Social Welfare Office or through the e-Sevai centre.',
    '2026-12-31', 'https://socialwelfare.tn.gov.in',
    'Tamil Nadu elders without steady income get monthly pension support.',
    'நிலையான வருமானம் இல்லாத தமிழ்நாடு முதியோர்களுக்கு மாத ஓய்வூதியம்.',
    ARRAY['English','Tamil'], ARRAY['pension','senior-citizen','tamil-nadu'], false
  ),
  (
    'Pradhan Mantri Fasal Bima Yojana (PMFBY)',
    'பிரதம மந்திரி பசல் பீமா யோஜனா',
    (SELECT id FROM categories WHERE slug = 'farmers'),
    'Central', 'Ministry of Agriculture & Farmers Welfare',
    'Crop insurance scheme protecting farmers against yield losses from natural calamities, pests, and diseases.',
    'Low-premium crop insurance cover; payout based on assessed crop loss.',
    'Farmers (loanee and non-loanee) growing notified crops in notified areas.',
    '{"states":["all"],"farmer":true}'::jsonb,
    'Aadhaar card, land records, bank passbook, sowing certificate.',
    'Enrol through banks (if you have a crop loan) or via the PMFBY portal / Common Service Centre before the cut-off date for the season.',
    '2026-11-30', 'https://pmfby.gov.in',
    'Farmers pay a small premium and get compensation if their crop is damaged.',
    'விவசாயிகள் குறைந்த பிரீமியம் செலுத்தி பயிர் சேதத்திற்கு நஷ்டஈடு பெறலாம்.',
    ARRAY['English','Tamil','Hindi'], ARRAY['farmer','insurance','central'], false
  ),
  (
    'Employees'' State Insurance (ESI) Scheme',
    'ஊழியர்கள் மாநில காப்பீட்டுத் திட்டம்',
    (SELECT id FROM categories WHERE slug = 'healthcare'),
    'Central', 'Ministry of Labour and Employment',
    'Social security scheme offering medical, sickness, maternity, and disability benefits to organised sector workers.',
    'Comprehensive medical care for the worker and family, plus cash benefits during sickness, maternity, and disability.',
    'Employees earning up to the notified wage ceiling in ESI-covered establishments.',
    '{"states":["all"]}'::jsonb,
    'Aadhaar card, ESI card, employer registration proof.',
    'Enrolment is done by the employer at the time of joining; employee and employer both contribute a percentage of wages.',
    '2026-12-31', 'https://esic.gov.in',
    'Workers in covered jobs get free medical care and cash benefits during illness or maternity.',
    'ஊழியர்களுக்கு நோய், மகப்பேறு காலங்களில் இலவச மருத்துவம் மற்றும் பண உதவி.',
    ARRAY['English','Hindi'], ARRAY['healthcare','worker','central'], false
  ),
  (
    'Pradhan Mantri Mudra Yojana (PMMY)',
    'பிரதம மந்திரி முத்ரா யோஜனா',
    (SELECT id FROM categories WHERE slug = 'skill-development'),
    'Central', 'Ministry of Finance',
    'Collateral-free micro-loan scheme to support small and micro non-farm income-generating businesses.',
    'Loans up to Rs. 10 lakh under three categories — Shishu, Kishor, and Tarun — based on business stage and funding need.',
    'Non-corporate, non-farm small/micro entrepreneurs including first-time business owners.',
    '{"states":["all"]}'::jsonb,
    'Aadhaar card, business plan, address proof, bank statements.',
    'Apply at any participating bank, NBFC, or microfinance institution with a business proposal.',
    '2026-12-31', 'https://mudra.org.in',
    'Small business owners can get a loan without collateral to start or grow their business.',
    'சிறு தொழில் உரிமையாளர்கள் அடமானம் இல்லாமல் கடன் பெறலாம்.',
    ARRAY['English','Hindi'], ARRAY['entrepreneurship','loan','central'], false
  )
) AS s(title, title_ta, category_id, state, ministry, overview, benefits, eligibility, eligibility_rules, documents, process, last_date, official_url, simple_explanation, simple_explanation_ta, languages, tags, featured)
WHERE NOT EXISTS (SELECT 1 FROM schemes WHERE schemes.title = s.title);

-- JOBS
INSERT INTO jobs (title, organization, state, description, eligibility, last_date, official_url)
SELECT * FROM (VALUES
  ('Staff Selection Commission CGL 2026', 'Staff Selection Commission (SSC)', 'Central', 'Combined Graduate Level exam for various Group B and C posts in central government ministries and departments.', 'Bachelor''s degree from a recognised university; age 18–32 (relaxation as per rules).', '2026-10-15', 'https://ssc.nic.in'),
  ('IBPS Clerk Recruitment 2026', 'Institute of Banking Personnel Selection (IBPS)', 'Central', 'Common Written Examination for clerical cadre posts in participating public sector banks.', 'Graduate in any discipline; age 20–28 years.', '2026-09-30', 'https://ibps.in'),
  ('Tamil Nadu Public Service Commission – Group IV Services', 'Tamil Nadu Public Service Commission (TNPSC)', 'Tamil Nadu', 'Recruitment to various Group IV non-gazetted posts across Tamil Nadu government departments.', 'SSLC/Class 10 pass minimum, Tamil Nadu domicile preferred; age limits as per category.', '2026-11-20', 'https://tnpsc.gov.in'),
  ('Indian Railways RRB NTPC 2026', 'Railway Recruitment Board (RRB)', 'Central', 'Non-Technical Popular Categories recruitment for clerks, station masters, and related posts across Indian Railways.', '12th pass or graduate depending on post; age 18–33 (relaxation as per rules).', '2026-10-05', 'https://rrbcdg.gov.in'),
  ('Tamil Nadu Uniformed Services Recruitment Board – Police Constable', 'Tamil Nadu Uniformed Services Recruitment Board (TNUSRB)', 'Tamil Nadu', 'Direct recruitment of Grade II Police Constables across Tamil Nadu districts.', '12th pass, Tamil Nadu domicile, meeting physical eligibility standards; age 18–24.', '2026-09-25', 'https://tnusrbonline.org'),
  ('Union Public Service Commission – Civil Services Exam 2027', 'Union Public Service Commission (UPSC)', 'Central', 'Premier examination for recruitment to IAS, IPS, IFS and other central civil services.', 'Bachelor''s degree in any discipline; age 21–32 (relaxation for reserved categories).', '2027-02-14', 'https://upsc.gov.in')
) AS j(title, organization, state, description, eligibility, last_date, official_url)
WHERE NOT EXISTS (SELECT 1 FROM jobs WHERE jobs.title = j.title);

-- INTERNSHIPS
INSERT INTO internships (title, organization, description, eligibility, duration, last_date, official_url)
SELECT * FROM (VALUES
  ('PM Internship Scheme', 'Ministry of Corporate Affairs', 'Government-backed internship programme placing youth in top companies for real-world work exposure with a monthly stipend.', 'Age 21–24, not employed full-time, not enrolled in a full-time degree program.', '12 months', '2026-10-31', 'https://pminternship.mca.gov.in'),
  ('NITI Aayog Internship Programme', 'NITI Aayog', 'Research and policy internship exposing students to national policy-making processes.', 'Undergraduate/postgraduate students in relevant fields, minimum academic standing as specified.', '6–8 weeks', '2026-12-31', 'https://niti.gov.in'),
  ('Startup India Internship', 'Department for Promotion of Industry and Internal Trade (DPIIT)', 'Internship opportunities with recognised startups across India through the Startup India portal.', 'Students and recent graduates registered on the Startup India portal.', 'Varies by startup', '2026-12-31', 'https://startupindia.gov.in'),
  ('Tamil Nadu Skill Development Corporation – Industry Internship', 'Tamil Nadu Skill Development Corporation (TNSDC)', 'Structured on-the-job internship connecting Tamil Nadu ITI/polytechnic students with local industries.', 'ITI/polytechnic/diploma students enrolled in Tamil Nadu institutions.', '3–6 months', '2026-11-15', 'https://tnsdc.tn.gov.in')
) AS i(title, organization, description, eligibility, duration, last_date, official_url)
WHERE NOT EXISTS (SELECT 1 FROM internships WHERE internships.title = i.title);

-- SCHOLARSHIPS
INSERT INTO scholarships (title, provider, amount, eligibility, last_date, official_url)
SELECT * FROM (VALUES
  ('Central Sector Scheme of Scholarship for College and University Students', 'Ministry of Education', 'Rs. 10,000–20,000 per year', 'Top-performing Class 12 students (above 80th percentile) continuing to undergraduate studies, family income below prescribed limit.', '2026-10-31', 'https://scholarships.gov.in'),
  ('Kalvi Kanavu Scholarship (Tamil Nadu)', 'Department of Higher Education, Tamil Nadu', 'Up to Rs. 50,000 per year', 'Tamil Nadu students pursuing professional courses (engineering, medicine) from economically weaker families.', '2026-09-30', 'https://tnschools.gov.in'),
  ('AICTE Pragati Scholarship for Girl Students', 'All India Council for Technical Education (AICTE)', 'Rs. 50,000 per year', 'Girl students admitted to AICTE-approved technical diploma or degree courses, family income within limit.', '2026-10-15', 'https://aicte-pragati-saksham-gov.in'),
  ('AICTE Saksham Scholarship for Specially Abled Students', 'All India Council for Technical Education (AICTE)', 'Rs. 50,000 per year', 'Specially-abled students (40% or more disability) admitted to AICTE-approved technical courses.', '2026-10-15', 'https://aicte-pragati-saksham-gov.in'),
  ('National Means-cum-Merit Scholarship (NMMS)', 'Ministry of Education', 'Rs. 12,000 per year', 'Class 9–12 students from economically weaker sections who clear the state-level NMMS selection test.', '2026-08-31', 'https://scholarships.gov.in'),
  ('Ishan Uday Special Scholarship Scheme (North Eastern Region)', 'Ministry of Education', 'Up to Rs. 30,800 per year', 'Students from the North Eastern Region admitted to general degree courses in recognised institutions.', '2026-10-31', 'https://scholarships.gov.in')
) AS sc(title, provider, amount, eligibility, last_date, official_url)
WHERE NOT EXISTS (SELECT 1 FROM scholarships WHERE scholarships.title = sc.title);