export type Category = {
  id: string;
  slug: string;
  name: string;
  name_ta: string | null;
  name_hi: string | null;
  icon: string | null;
  description: string | null;
};

export type Scheme = {
  id: string;
  title: string;
  title_ta: string | null;
  title_hi: string | null;
  category_id: string | null;
  state: string;
  ministry: string | null;
  overview: string;
  benefits: string;
  eligibility: string;
  eligibility_rules: Record<string, unknown>;
  documents: string;
  process: string;
  last_date: string | null;
  official_url: string | null;
  pdf_url: string | null;
  simple_explanation: string;
  simple_explanation_ta: string | null;
  languages: string[];
  tags: string[];
  featured: boolean;
  categories?: Category | null;
};

export type Job = { id: string; title: string; organization: string; state: string; description: string | null; eligibility: string | null; last_date: string | null; official_url: string | null };
export type Internship = { id: string; title: string; organization: string; description: string | null; eligibility: string | null; duration: string | null; last_date: string | null; official_url: string | null };
export type Scholarship = { id: string; title: string; provider: string; amount: string | null; eligibility: string | null; last_date: string | null; official_url: string | null };
