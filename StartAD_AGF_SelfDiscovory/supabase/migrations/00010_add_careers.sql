-- =============== Careers Seeding (100) ===============
-- Guard: unique title
create unique index if not exists uq_careers_title on public.careers (lower(title));

-- Guard: tag → feature map used by public.tag_vector()
-- (Safe to re-run; on conflict do nothing)
create table if not exists public.tag_feature_map (
  tag text primary key,
  feature_keys text[] not null
);




insert into public.tag_feature_map(tag, feature_keys) values
  ('analytical',            array['interest_analytical','cognition_quantitative','cognition_problem_solving']),
  ('creativity',            array['trait_creativity','interest_creative','trait_openness']),
  ('communication',         array['trait_communication','cognition_verbal','trait_emotional_intelligence']),
  ('collaboration',         array['trait_collaboration']),
  ('leadership',            array['trait_leadership','interest_enterprising']),
  ('curiosity',             array['trait_curiosity']),
  ('grit',                  array['trait_grit']),
  ('conscientiousness',     array['trait_conscientiousness','interest_conventional']),
  ('openness',              array['trait_openness']),
  ('adaptability',          array['trait_adaptability']),
  ('emotional_intelligence',array['trait_emotional_intelligence']),
  ('verbal',                array['cognition_verbal']),
  ('quantitative',          array['cognition_quantitative']),
  ('spatial',               array['cognition_spatial']),
  ('memory',                array['cognition_memory']),
  ('attention',             array['cognition_attention']),
  ('problem_solving',       array['cognition_problem_solving']),
  ('social',                array['interest_social']),
  ('practical',             array['interest_practical']),
  ('enterprising',          array['interest_enterprising']),
  ('conventional',          array['interest_conventional'])
on conflict (tag) do nothing;

create or replace function public.tag_vector(p_tags text[])
returns float8[]
language plpgsql
as $$
declare
  v_vec float8[];
begin
  with normalized_tags as (
    select lower(trim(t)) as tag
    from unnest(coalesce(p_tags, array[]::text[])) as t
    where trim(t) <> ''
  ),
  -- explode tag -> feature_keys mapping only for provided tags
  tag_hits as (
    select fk as feature_key, count(*)::int as hits
    from public.tag_feature_map tf
    join normalized_tags nt on nt.tag = lower(tf.tag)
    cross join unnest(tf.feature_keys) as fk
    group by fk
  )
  select array_agg(
           least(1.0, greatest(0.05, 0.50 + coalesce(th.hits,0) * 0.20))
           order by f.id
         )
  into v_vec
  from public.features f
  left join tag_hits th
    on th.feature_key = f.key;

  return v_vec;
end;
$$;

-- 1) Add a normalized (generated) column
alter table public.careers
  add column if not exists title_ci text
  generated always as (lower(title)) stored;

-- 2) Enforce uniqueness on the normalized value
alter table public.careers
  add constraint uq_careers_title_ci unique (title_ci);
  -- 100 careers. Each row: title, cluster, tags, vector (computed), description, source
insert into public.careers (title, cluster, tags, vector, description, source)
values
  ('Software Engineer','STEM',             array['analytical','problem_solving','quantitative'],               public.tag_vector(array['analytical','problem_solving','quantitative']),               'Design, build, and maintain software systems and apps','manual'),
  ('Data Scientist','STEM',                array['analytical','quantitative','curiosity'],                    public.tag_vector(array['analytical','quantitative','curiosity']),                    'Extract insights from data using statistics and ML','manual'),
  ('UX Designer','Creative',               array['creativity','communication','emotional_intelligence'],      public.tag_vector(array['creativity','communication','emotional_intelligence']),      'Design user experiences through research and prototyping','manual'),
  ('Product Manager','Business',           array['leadership','communication','analytical'],                  public.tag_vector(array['leadership','communication','analytical']),                  'Define product vision and coordinate cross-functional delivery','manual'),
  ('Cybersecurity Analyst','STEM',         array['analytical','attention','problem_solving'],                 public.tag_vector(array['analytical','attention','problem_solving']),                 'Protect systems by monitoring, detecting, and mitigating threats','manual'),
  ('AI/ML Engineer','STEM',                array['analytical','quantitative','curiosity'],                    public.tag_vector(array['analytical','quantitative','curiosity']),                    'Build and deploy machine learning models into products','manual'),
  ('Cloud Architect','STEM',               array['analytical','problem_solving','conscientiousness'],         public.tag_vector(array['analytical','problem_solving','conscientiousness']),         'Design scalable, secure cloud architectures','manual'),
  ('DevOps Engineer','STEM',               array['problem_solving','conscientiousness','attention'],          public.tag_vector(array['problem_solving','conscientiousness','attention']),          'Automate CI/CD, reliability, and infra as code','manual'),
  ('Mobile App Developer','STEM',          array['creativity','analytical','problem_solving'],                public.tag_vector(array['creativity','analytical','problem_solving']),                'Build mobile applications for iOS/Android','manual'),
  ('Web Developer','STEM',                 array['creativity','analytical','problem_solving'],                public.tag_vector(array['creativity','analytical','problem_solving']),                'Create responsive, accessible websites and web apps','manual'),
  ('Game Developer','Creative',            array['creativity','spatial','problem_solving'],                   public.tag_vector(array['creativity','spatial','problem_solving']),                   'Develop interactive games and real-time experiences','manual'),
  ('Database Administrator','STEM',        array['conscientiousness','attention','analytical'],               public.tag_vector(array['conscientiousness','attention','analytical']),               'Manage databases for performance, availability, and security','manual'),
  ('Systems Analyst','STEM',               array['analytical','communication','problem_solving'],             public.tag_vector(array['analytical','communication','problem_solving']),             'Analyze business needs and define system requirements','manual'),
  ('QA Engineer','STEM',                   array['attention','conscientiousness','problem_solving'],          public.tag_vector(array['attention','conscientiousness','problem_solving']),          'Design and run tests to ensure software quality','manual'),
  ('Robotics Engineer','STEM',             array['spatial','analytical','problem_solving'],                   public.tag_vector(array['spatial','analytical','problem_solving']),                   'Design robots and autonomous systems','manual'),
  ('Electrical Engineer','STEM',           array['analytical','quantitative','practical'],                    public.tag_vector(array['analytical','quantitative','practical']),                    'Design and test electrical systems and devices','manual'),
  ('Mechanical Engineer','STEM',           array['spatial','analytical','practical'],                         public.tag_vector(array['spatial','analytical','practical']),                         'Design mechanical systems, machines, and components','manual'),
  ('Civil Engineer','STEM',                array['spatial','conscientiousness','practical'],                  public.tag_vector(array['spatial','conscientiousness','practical']),                  'Design and oversee infrastructure projects','manual'),
  ('Biomedical Engineer','STEM',           array['analytical','curiosity','practical'],                       public.tag_vector(array['analytical','curiosity','practical']),                       'Develop medical devices and health technologies','manual'),
  ('Chemical Engineer','STEM',             array['quantitative','analytical','problem_solving'],              public.tag_vector(array['quantitative','analytical','problem_solving']),              'Design processes for chemicals, materials, and energy','manual'),
  ('Environmental Scientist','STEM',       array['analytical','curiosity','social'],                          public.tag_vector(array['analytical','curiosity','social']),                          'Study environment and design sustainability solutions','manual'),
  ('Research Scientist','STEM',            array['curiosity','analytical','problem_solving'],                 public.tag_vector(array['curiosity','analytical','problem_solving']),                 'Conduct experiments and publish scientific findings','manual'),
  ('Statistician','STEM',                  array['quantitative','analytical','attention'],                    public.tag_vector(array['quantitative','analytical','attention']),                    'Design experiments and analyze statistical data','manual'),
  ('Economist','Business',                 array['quantitative','analytical','curiosity'],                    public.tag_vector(array['quantitative','analytical','curiosity']),                    'Model and analyze economic trends and policies','manual'),
  ('Financial Analyst','Business',         array['quantitative','analytical','conscientiousness'],            public.tag_vector(array['quantitative','analytical','conscientiousness']),            'Evaluate investments and financial performance','manual'),
  ('Accountant','Business',                array['conscientiousness','attention','conventional'],             public.tag_vector(array['conscientiousness','attention','conventional']),             'Prepare financial statements and ensure compliance','manual'),
  ('Auditor','Business',                   array['attention','conscientiousness','analytical'],               public.tag_vector(array['attention','conscientiousness','analytical']),               'Examine financial records for accuracy and control','manual'),
  ('Investment Analyst','Business',        array['quantitative','analytical','problem_solving'],              public.tag_vector(array['quantitative','analytical','problem_solving']),              'Analyze markets and evaluate investment opportunities','manual'),
  ('Marketing Specialist','Business',      array['communication','creativity','analytical'],                  public.tag_vector(array['communication','creativity','analytical']),                  'Plan and execute marketing campaigns and research','manual'),
  ('Digital Marketing Manager','Business', array['communication','analytical','creativity'],                  public.tag_vector(array['communication','analytical','creativity']),                  'Lead digital growth across channels and analytics','manual'),
  ('Content Strategist','Media',           array['communication','creativity','verbal'],                      public.tag_vector(array['communication','creativity','verbal']),                      'Plan and govern content to meet user and business goals','manual'),
  ('Social Media Manager','Media',         array['communication','creativity','attention'],                   public.tag_vector(array['communication','creativity','attention']),                   'Manage social presence, content, and engagement','manual'),
  ('Public Relations Specialist','Media',  array['communication','emotional_intelligence','leadership'],      public.tag_vector(array['communication','emotional_intelligence','leadership']),      'Build relationships and manage organizational reputation','manual'),
  ('Sales Manager','Business',             array['leadership','communication','emotional_intelligence'],      public.tag_vector(array['leadership','communication','emotional_intelligence']),      'Lead sales team, pipeline, and revenue targets','manual'),
  ('Business Analyst','Business',          array['analytical','communication','problem_solving'],             public.tag_vector(array['analytical','communication','problem_solving']),             'Analyze processes and recommend improvements','manual'),
  ('Operations Manager','Business',        array['conscientiousness','leadership','problem_solving'],         public.tag_vector(array['conscientiousness','leadership','problem_solving']),         'Oversee operations, efficiency, and quality','manual'),
  ('Supply Chain Manager','Business',      array['conscientiousness','analytical','attention'],               public.tag_vector(array['conscientiousness','analytical','attention']),               'Manage logistics, inventory, and suppliers','manual'),
  ('Project Manager','Business',           array['leadership','conscientiousness','communication'],           public.tag_vector(array['leadership','conscientiousness','communication']),           'Plan and deliver projects on time and budget','manual'),
  ('HR Specialist','Business',             array['communication','emotional_intelligence','conscientiousness'], public.tag_vector(array['communication','emotional_intelligence','conscientiousness']),'Recruit, develop, and support employees','manual'),
  ('Talent Acquisition Specialist','Business', array['communication','social','conscientiousness'],          public.tag_vector(array['communication','social','conscientiousness']),               'Source and hire top candidates','manual'),
  ('School Counselor','Education',         array['emotional_intelligence','communication','social'],          public.tag_vector(array['emotional_intelligence','communication','social']),          'Guide students in academics and wellbeing','manual'),
  ('Psychologist','Health',                array['emotional_intelligence','communication','attention'],       public.tag_vector(array['emotional_intelligence','communication','attention']),       'Assess and support mental health and behavior','manual'),
  ('Nurse','Health',                       array['emotional_intelligence','communication','conscientiousness'], public.tag_vector(array['emotional_intelligence','communication','conscientiousness']),'Provide patient care and coordination','manual'),
  ('Physician','Health',                   array['problem_solving','attention','communication'],              public.tag_vector(array['problem_solving','attention','communication']),              'Diagnose and treat medical conditions','manual'),
  ('Pharmacist','Health',                  array['conscientiousness','attention','communication'],            public.tag_vector(array['conscientiousness','attention','communication']),            'Dispense medications and counsel patients','manual'),
  ('Dentist','Health',                     array['practical','attention','communication'],                    public.tag_vector(array['practical','attention','communication']),                    'Diagnose and treat oral health issues','manual'),
  ('Physical Therapist','Health',          array['social','emotional_intelligence','conscientiousness'],      public.tag_vector(array['social','emotional_intelligence','conscientiousness']),      'Rehabilitate movement and function','manual'),
  ('Occupational Therapist','Health',      array['social','emotional_intelligence','adaptability'],           public.tag_vector(array['social','emotional_intelligence','adaptability']),           'Enable daily living and work participation','manual'),
  ('Radiologic Technologist','Health',     array['attention','conscientiousness','practical'],                public.tag_vector(array['attention','conscientiousness','practical']),                'Perform imaging exams and support diagnosis','manual'),
  ('Medical Lab Technologist','Health',    array['attention','conscientiousness','analytical'],               public.tag_vector(array['attention','conscientiousness','analytical']),               'Conduct lab tests and analyze samples','manual'),
  ('Architect','Creative',                 array['spatial','creativity','conscientiousness'],                 public.tag_vector(array['spatial','creativity','conscientiousness']),                 'Design buildings and spaces','manual'),
  ('Urban Planner','Public',               array['analytical','communication','conscientiousness'],           public.tag_vector(array['analytical','communication','conscientiousness']),           'Plan land use and community development','manual'),
  ('Interior Designer','Creative',         array['creativity','spatial','communication'],                     public.tag_vector(array['creativity','spatial','communication']),                     'Design interior spaces and experiences','manual'),
  ('Graphic Designer','Creative',          array['creativity','communication'],                               public.tag_vector(array['creativity','communication']),                               'Create visual concepts and brand assets','manual'),
  ('Fashion Designer','Creative',          array['creativity','openness','conscientiousness'],                public.tag_vector(array['creativity','openness','conscientiousness']),                'Design apparel and accessories','manual'),
  ('Industrial Designer','Creative',       array['creativity','spatial','problem_solving'],                   public.tag_vector(array['creativity','spatial','problem_solving']),                   'Design physical products and experiences','manual'),
  ('Videographer','Media',                 array['creativity','spatial','communication'],                     public.tag_vector(array['creativity','spatial','communication']),                     'Capture and edit video content','manual'),
  ('Photographer','Media',                 array['creativity','spatial','attention'],                         public.tag_vector(array['creativity','spatial','attention']),                         'Create and edit photographic content','manual'),
  ('Journalist','Media',                   array['communication','verbal','curiosity'],                       public.tag_vector(array['communication','verbal','curiosity']),                       'Report news and investigative stories','manual'),
  ('Editor','Media',                       array['verbal','attention','communication'],                       public.tag_vector(array['verbal','attention','communication']),                       'Edit and shape written content','manual'),
  ('Copywriter','Media',                   array['verbal','creativity','communication'],                      public.tag_vector(array['verbal','creativity','communication']),                      'Write persuasive and brand-aligned copy','manual'),
  ('Translator','Media',                   array['verbal','communication','attention'],                       public.tag_vector(array['verbal','communication','attention']),                       'Translate content across languages','manual'),
  ('Lawyer','Legal',                       array['verbal','analytical','communication'],                      public.tag_vector(array['verbal','analytical','communication']),                      'Advise and represent clients in legal matters','manual'),
  ('Paralegal','Legal',                    array['conscientiousness','attention','verbal'],                   public.tag_vector(array['conscientiousness','attention','verbal']),                   'Support attorneys with legal research and drafting','manual'),
  ('Policy Analyst','Public',              array['analytical','verbal','communication'],                      public.tag_vector(array['analytical','verbal','communication']),                      'Research and evaluate public policies','manual'),
  ('Diplomat','Public',                    array['communication','leadership','emotional_intelligence'],      public.tag_vector(array['communication','leadership','emotional_intelligence']),      'Represent national interests abroad','manual'),
  ('Civil Servant','Public',               array['conscientiousness','communication','social'],               public.tag_vector(array['conscientiousness','communication','social']),               'Deliver public services and administration','manual'),
  ('Police Officer','Public',              array['attention','problem_solving','social'],                     public.tag_vector(array['attention','problem_solving','social']),                     'Protect public safety and enforce laws','manual'),
  ('Firefighter','Public',                 array['grit','adaptability','practical'],                          public.tag_vector(array['grit','adaptability','practical']),                          'Respond to emergencies and rescue operations','manual'),
  ('Military Officer','Public',            array['leadership','grit','conscientiousness'],                    public.tag_vector(array['leadership','grit','conscientiousness']),                    'Lead units and manage operations','manual'),
  ('Airline Pilot','Aviation',             array['attention','problem_solving','spatial'],                    public.tag_vector(array['attention','problem_solving','spatial']),                    'Operate aircraft and ensure flight safety','manual'),
  ('Air Traffic Controller','Aviation',    array['attention','problem_solving','communication'],              public.tag_vector(array['attention','problem_solving','communication']),              'Coordinate aircraft movements and airspace','manual'),
  ('Flight Attendant','Aviation',          array['communication','social','emotional_intelligence'],          public.tag_vector(array['communication','social','emotional_intelligence']),          'Ensure passenger safety and service','manual'),
  ('Logistics Coordinator','Business',     array['conscientiousness','attention','communication'],            public.tag_vector(array['conscientiousness','attention','communication']),            'Coordinate shipments and supply flows','manual'),
  ('Data Engineer','STEM',                 array['analytical','problem_solving','conscientiousness'],         public.tag_vector(array['analytical','problem_solving','conscientiousness']),         'Build data pipelines and platforms','manual'),
  ('Product Designer','Creative',          array['creativity','communication','spatial'],                     public.tag_vector(array['creativity','communication','spatial']),                     'Design digital products and flows','manual'),
  ('Customer Success Manager','Business',  array['communication','emotional_intelligence','collaboration'],   public.tag_vector(array['communication','emotional_intelligence','collaboration']),   'Drive adoption and outcomes for customers','manual'),
  ('Customer Support Representative','Business', array['communication','attention','emotional_intelligence'], public.tag_vector(array['communication','attention','emotional_intelligence']),       'Resolve customer issues and questions','manual'),
  ('Small Business Owner','Business',      array['enterprising','leadership','conscientiousness'],            public.tag_vector(array['enterprising','leadership','conscientiousness']),            'Start and manage a small enterprise','manual'),
  ('Restaurant Manager','Hospitality',     array['leadership','communication','conscientiousness'],           public.tag_vector(array['leadership','communication','conscientiousness']),           'Oversee restaurant operations and teams','manual'),
  ('Chef','Hospitality',                   array['creativity','practical','conscientiousness'],               public.tag_vector(array['creativity','practical','conscientiousness']),               'Create menus and lead kitchen operations','manual'),
  ('Pastry Chef','Hospitality',            array['creativity','attention','conscientiousness'],               public.tag_vector(array['creativity','attention','conscientiousness']),               'Design and craft desserts and pastries','manual'),
  ('Nutritionist','Health',                array['communication','analytical','social'],                      public.tag_vector(array['communication','analytical','social']),                      'Provide dietary advice and wellness plans','manual'),
  ('Dietitian','Health',                   array['conscientiousness','communication','social'],               public.tag_vector(array['conscientiousness','communication','social']),               'Medical nutrition therapy and meal planning','manual'),
  ('Fitness Trainer','Sports',             array['social','communication','grit'],                            public.tag_vector(array['social','communication','grit']),                            'Coach clients toward fitness goals','manual'),
  ('Sports Coach','Sports',                array['leadership','communication','grit'],                        public.tag_vector(array['leadership','communication','grit']),                        'Lead teams and develop athletes','manual'),
  ('Event Planner','Hospitality',          array['conscientiousness','communication','creativity'],           public.tag_vector(array['conscientiousness','communication','creativity']),           'Plan and coordinate events and experiences','manual'),
  ('Travel Agent','Hospitality',           array['communication','conscientiousness','social'],               public.tag_vector(array['communication','conscientiousness','social']),               'Design and book travel itineraries','manual'),
  ('Tour Guide','Hospitality',             array['communication','social','emotional_intelligence'],          public.tag_vector(array['communication','social','emotional_intelligence']),          'Lead tours and share cultural insights','manual'),
  ('Real Estate Agent','Business',         array['communication','enterprising','emotional_intelligence'],    public.tag_vector(array['communication','enterprising','emotional_intelligence']),    'Broker property sales and rentals','manual'),
  ('Construction Manager','Trades',        array['leadership','conscientiousness','practical'],               public.tag_vector(array['leadership','conscientiousness','practical']),               'Oversee construction projects and crews','manual'),
  ('Electrician','Trades',                 array['practical','attention','problem_solving'],                  public.tag_vector(array['practical','attention','problem_solving']),                  'Install and repair electrical systems','manual'),
  ('Plumber','Trades',                     array['practical','conscientiousness','problem_solving'],          public.tag_vector(array['practical','conscientiousness','problem_solving']),          'Install and repair plumbing systems','manual'),
  ('Carpenter','Trades',                   array['practical','conscientiousness','spatial'],                  public.tag_vector(array['practical','conscientiousness','spatial']),                  'Construct and repair structures and fixtures','manual'),
  ('Auto Mechanic','Trades',               array['practical','problem_solving','attention'],                  public.tag_vector(array['practical','problem_solving','attention']),                  'Diagnose and repair vehicles','manual'),
  ('Agriculture Specialist','STEM',        array['practical','analytical','curiosity'],                       public.tag_vector(array['practical','analytical','curiosity']),                       'Improve agricultural productivity and sustainability','manual'),
  ('Farmer','Trades',                      array['practical','grit','conscientiousness'],                     public.tag_vector(array['practical','grit','conscientiousness']),                     'Manage crops, livestock, and farm operations','manual'),
  ('Renewable Energy Technician','STEM',   array['practical','attention','problem_solving'],                  public.tag_vector(array['practical','attention','problem_solving']),                  'Install and maintain solar/wind systems','manual'),
  ('Solar Installer','STEM',               array['practical','attention','conscientiousness'],                public.tag_vector(array['practical','attention','conscientiousness']),                'Install photovoltaic systems','manual'),
  ('Wind Turbine Technician','STEM',       array['practical','grit','problem_solving'],                       public.tag_vector(array['practical','grit','problem_solving']),                       'Maintain wind turbines and safety systems','manual'),
  ('UI Designer','Creative',               array['creativity','communication','attention'],                   public.tag_vector(array['creativity','communication','attention']),                   'Design clear, accessible user interfaces','manual'),
  ('Scrum Master','Business',              array['leadership','collaboration','communication'],               public.tag_vector(array['leadership','collaboration','communication']),               'Facilitate agile delivery and team effectiveness','manual'),
  ('Teacher','Public',                     array['communication','collaboration'],                            public.tag_vector(array['communication','collaboration']),                            'Educate and inspire students in various subjects','manual'),
  ('Entrepreneur','Business',              array['creativity','persistence','communication'],                  public.tag_vector(array['creativity','persistence','communication']),                 'Start and manage your own business ventures','manual'),
  ('Data Analyst','STEM',                  array['analytical','curiosity'],                                   public.tag_vector(array['analytical','curiosity']),                                   'Analyze data to help organizations make informed decisions','manual'),
  ('Software Developer','STEM',            array['analytical','persistence','curiosity'],                     public.tag_vector(array['analytical','persistence','curiosity']),                     'Design, develop, and maintain software applications and systems','manual'),
  ('Biostatistician','STEM',               array['quantitative','analytical','attention'],                    public.tag_vector(array['quantitative','analytical','attention']),                    'Apply statistics to biomedical research','manual'),
  ('Epidemiologist','Health',              array['analytical','curiosity','conscientiousness'],               public.tag_vector(array['analytical','curiosity','conscientiousness']),               'Study disease patterns in populations','manual'),
  ('Clinical Research Coordinator','Health', array['conscientiousness','attention','communication'],          public.tag_vector(array['conscientiousness','attention','communication']),            'Coordinate clinical trials and protocols','manual'),
  ('Bioinformatician','STEM',              array['analytical','quantitative','curiosity'],                    public.tag_vector(array['analytical','quantitative','curiosity']),                    'Analyze biological data with computation','manual'),
  ('Geospatial Analyst','STEM',            array['spatial','analytical','problem_solving'],                   public.tag_vector(array['spatial','analytical','problem_solving']),                   'Analyze spatial data and maps (GIS)','manual'),
  ('Meteorologist','STEM',                 array['analytical','quantitative','attention'],                    public.tag_vector(array['analytical','quantitative','attention']),                    'Forecast weather and study climate systems','manual'),
  ('Oceanographer','STEM',                 array['curiosity','analytical','problem_solving'],                 public.tag_vector(array['curiosity','analytical','problem_solving']),                 'Study oceans and marine environments','manual'),
  ('Museum Curator','Public',              array['conscientiousness','communication','openness'],             public.tag_vector(array['conscientiousness','communication','openness']),             'Manage collections and exhibitions','manual'),
  ('Librarian','Public',                   array['conscientiousness','communication','verbal'],               public.tag_vector(array['conscientiousness','communication','verbal']),               'Organize information services and programs','manual'),
  ('Teacher Assistant','Education',        array['collaboration','communication','social'],                   public.tag_vector(array['collaboration','communication','social']),                   'Support classroom instruction and students','manual'),
  ('Special Education Teacher','Education',array['emotional_intelligence','communication','adaptability'],    public.tag_vector(array['emotional_intelligence','communication','adaptability']),    'Teach students with special needs','manual'),
  ('Speech Therapist','Health',            array['communication','emotional_intelligence','attention'],       public.tag_vector(array['communication','emotional_intelligence','attention']),       'Treat speech and language disorders','manual'),
  ('Occupational Health & Safety Specialist','Public', array['conscientiousness','attention','communication'], public.tag_vector(array['conscientiousness','attention','communication']),           'Promote workplace safety and compliance','manual'),
  ('Quality Assurance Manager','Business', array['conscientiousness','attention','leadership'],               public.tag_vector(array['conscientiousness','attention','leadership']),               'Oversee quality systems and audits','manual'),
  ('Compliance Officer','Business',        array['conscientiousness','attention','communication'],            public.tag_vector(array['conscientiousness','attention','communication']),            'Ensure regulatory compliance and controls','manual'),
  ('Procurement Specialist','Business',    array['conscientiousness','analytical','communication'],           public.tag_vector(array['conscientiousness','analytical','communication']),           'Source goods/services and manage vendors','manual'),
  ('Product Marketing Manager','Business', array['communication','creativity','analytical'],                  public.tag_vector(array['communication','creativity','analytical']),                  'Position products and run go-to-market','manual'),
  ('SEO Specialist','Business',            array['analytical','attention','communication'],                   public.tag_vector(array['analytical','attention','communication']),                   'Optimize search visibility and performance','manual'),
  ('Business Intelligence Analyst','Business', array['analytical','quantitative','communication'],            public.tag_vector(array['analytical','quantitative','communication']),                'Build dashboards and decision intelligence','manual'),
  ('Revenue Operations Analyst','Business', array['analytical','conscientiousness','attention'],              public.tag_vector(array['analytical','conscientiousness','attention']),              'Unify GTM data/process for growth','manual'),
  ('Community Manager','Media',            array['communication','social','emotional_intelligence'],          public.tag_vector(array['communication','social','emotional_intelligence']),          'Grow and engage user communities','manual'),
  ('Animator','Creative',                  array['creativity','spatial','attention'],                         public.tag_vector(array['creativity','spatial','attention']),                         'Create animation for film, TV, and games','manual'),
  ('Sound Designer','Creative',            array['creativity','attention','communication'],                   public.tag_vector(array['creativity','attention','communication']),                   'Design and edit audio experiences','manual'),
  ('Music Producer','Creative',            array['creativity','communication','attention'],                   public.tag_vector(array['creativity','communication','attention']),                   'Produce and arrange music projects','manual'),
  ('Theater Director','Creative',          array['leadership','communication','creativity'],                  public.tag_vector(array['leadership','communication','creativity']),                  'Direct stage productions and teams','manual'),
  ('Esports Coach','Sports',               array['leadership','communication','attention'],                   public.tag_vector(array['leadership','communication','attention']),                   'Coach competitive gaming teams','manual')
on conflict on constraint uq_careers_title_ci do update
  set cluster = excluded.cluster,
      tags = excluded.tags,
      vector = excluded.vector,
      description = excluded.description,
      source = excluded.source;

is this correct?

if not just give fix the wrong arg , dont rewrite it all
