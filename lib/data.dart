// Sources: BLS Occupational Outlook Handbook (pay May 2025, how to become), BLS Career Outlook
// (apprenticeship hours), NCCER craft catalog, OSHA Outreach Training Program, AWS certification pages.

class Req {
  final String key, label, detail;
  final String? url;
  const Req(this.key, this.label, this.detail, [this.url]);
}

class Stage {
  final String title, time, summary;
  final List<Req> reqs;
  const Stage(this.title, this.time, this.summary, this.reqs);
}

class Trade {
  final String name, emoji, blsUrl, blsName;
  final int p10, median, p90;
  final List<Stage> stages;
  const Trade(this.name, this.emoji, this.blsName, this.blsUrl, this.p10, this.median, this.p90, this.stages);
}

const apprenticeshipFinder = 'https://www.apprenticeship.gov/apprenticeship-job-finder';
const osha = 'https://www.osha.gov/training/outreach';
const oshaTrainers = 'https://www.osha.gov/training/outreach';
const nccerElectrical = 'https://www.nccer.org/craft-catalog/electrical/';

const hsReq = Req('hs', 'High school diploma or equivalent', 'BLS lists this as the usual entry requirement for all four trades.');
const osha10 = Req('osha10', 'OSHA 10-hour card', 'Basic safety training. OSHA issues a 10-hour or 30-hour course completion card after the class.', osha);
const osha30 = Req('osha30', 'OSHA 30-hour card', 'OSHA describes the 30-hour class as more advanced training than the 10-hour.', osha);
const apprenticeReq = Req('apprentice', 'Enrolled in an apprenticeship', 'Paid on-the-job learning plus classroom instruction. Search programs near you.', apprenticeshipFinder);
const hoursReq = Req('hours', 'About 2,000 on-the-job hours a year', 'BLS Career Outlook: apprentices usually get about 2,000 hours of paid on-the-job training and at least 144 hours of related instruction each year.', 'https://www.bls.gov/careeroutlook/2013/summer/art01.pdf');

const trades = <Trade>[
  Trade('Electrician', '⚡', 'Electricians', 'https://www.bls.gov/ooh/construction-and-extraction/electricians.htm', 42640, 63190, 108510, [
    Stage('Helper / starter', 'Start here', 'Carry, pull, label and learn the tools while you look for an apprenticeship.', [hsReq, osha10]),
    Stage('Apprentice', 'About 4 to 5 years', 'Most electricians learn through an apprenticeship. Work and class at the same time.', [
      apprenticeReq, hoursReq,
      Req('nccerE', 'NCCER Electrical, levels 1-4 (optional)', 'Four-level curriculum, 672.5 hours in total including Core. NCCER says it meets U.S. Department of Labor apprenticeship standards.', nccerElectrical),
    ]),
    Stage('Journeyman electrician', 'After the apprenticeship', 'Most states require electricians to be licensed. Rules differ by state, so check your state board.', [
      Req('license', 'State electrical license', 'BLS: most states require electricians to be licensed. Contact your local or state electrical licensing board.', 'https://www.bls.gov/ooh/construction-and-extraction/electricians.htm'),
    ]),
    Stage('Foreman / lead', 'Years on the job', 'Run a crew. No national credential, so what counts is your record of jobs and who vouches for it.', [osha30]),
    Stage('Master or contractor', 'Varies by state', 'About 10 percent of electricians become contractors and open their own business (BLS, 2014 article). Master and contractor licences are set state by state.', [
      Req('master', 'Master or contractor licence (if your state has one)', 'Ask your state electrical licensing board what it needs.'),
    ]),
  ]),
  Trade('Carpenter', '🪚', 'Carpenters', 'https://www.bls.gov/ooh/construction-and-extraction/carpenters.htm', 40410, 60580, 99910, [
    Stage('Laborer / helper', 'Start here', 'BLS: some carpenters start as construction laborers or helpers. The tasks are similar.', [hsReq, osha10]),
    Stage('Apprentice carpenter', 'Programs differ by region', 'Apprentices learn blueprint reading, math, building code and safety, and complete set hours of training each year. BLS says all carpenters must pass the OSHA 10-hour course.', [apprenticeReq, osha10]),
    Stage('Journey carpenter', 'After training', 'Do the full range of carpentry. Optional specialty certifications can open more work.', [
      Req('spec', 'Specialty certification (optional)', 'BLS: optional programs certify carpenters by specialty. CareerOneStop lists them.', 'https://www.careeronestop.org/Toolkit/Training/find-certifications.aspx'),
    ]),
    Stage('Lead carpenter / supervisor', 'Years on the job', 'BLS lists first-line supervisor and lead carpenter as advancement paths.', [osha30]),
    Stage('Contractor / general supervisor', 'Varies', 'BLS lists independent contractor and general construction supervisor as other paths. Licensing for contractors is set by state.', []),
  ]),
  Trade('Plumber / Pipefitter', '🔧', 'Plumbers, Pipefitters, and Steamfitters', 'https://www.bls.gov/ooh/Construction-and-Extraction/Plumbers-pipefitters-and-steamfitters.htm', 44150, 63800, 108420, [
    Stage('Helper / starter', 'Start here', 'Vocational schools teach pipe system design, safety and tool use. Some pipefitter programs also require a welding course.', [hsReq, osha10]),
    Stage('Apprentice', '4 to 5 years', 'BLS: most learn through a 4- or 5-year apprenticeship, about 2,000 paid hours a year plus technical instruction.', [apprenticeReq, hoursReq]),
    Stage('Journeyman plumber', 'After the apprenticeship', 'Most states and some localities require plumbers to be licensed.', [
      Req('license', 'State or local plumbing license', 'BLS: most states and some localities require plumbers to be licensed. Check with your state or local board.', 'https://www.bls.gov/ooh/Construction-and-Extraction/Plumbers-pipefitters-and-steamfitters.htm'),
    ]),
    Stage('Foreman / lead', 'Years on the job', 'Lead a crew on larger jobs. The record of jobs you have run is what counts.', [osha30]),
    Stage('Master plumber or contractor', 'Varies by state', 'Requirements are set by your state or locality.', [
      Req('master', 'Master or contractor licence (if your state has one)', 'Ask your state or local licensing board what it needs.'),
    ]),
  ]),
  Trade('Welder', '🔥', 'Welders, Cutters, Solderers, and Brazers', 'https://www.bls.gov/ooh/production/welders-cutters-solderers-and-brazers.htm', 39240, 53750, 77530, [
    Stage('Entry level', 'Start here', 'BLS: a high school diploma plus technical training. Many employers prefer welders who finished a training or credential program. Some apprenticeships take people with no experience.', [hsReq]),
    Stage('Trained welder', 'Several months of on-the-job training', 'Even with school training you still get several months of on-the-job training. OSHA requires electrical safety training for welders.', [
      Req('school', 'Welding training program (vocational school, community college or apprenticeship)', 'BLS lists these routes. The U.S. Armed Forces also offer welding training.'),
      osha10,
    ]),
    Stage('Certified welder', 'Test when ready', 'Employers may require a general or specific certification for a job. Some pay for the training and test.', [
      Req('awscw', 'AWS Certified Welder test', 'Tested in person at an AWS Accredited Test Facility. You book an appointment.', 'https://www.aws.org/certification-and-education/professional-certification/certified-welder-program/'),
    ]),
    Stage('Welding inspector', 'Needs experience', 'AWS Certified Welding Inspector needs a vision test and a mix of education and welding work experience, documented.', [
      Req('cwi', 'AWS Certified Welding Inspector (CWI)', 'Candidates need qualifying education plus work experience. For example, one year of welding work with a bachelor degree in welding engineering technology.', 'https://www.aws.org/certification-and-education/professional-certification/certified-welding-inspector/'),
    ]),
  ]),
];
