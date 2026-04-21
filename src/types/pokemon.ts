// ── PokeAPI 응답 타입 ──────────────────────────

export interface LanguageName {
  language: { name: string };
  name: string;
}

export interface FlavorText {
  language: { name: string };
  flavor_text: string;
}

export interface Genus {
  language: { name: string };
  genus: string;
}

export interface PokemonType {
  slot: number;
  type: { name: string };
}

export interface PokemonAbility {
  slot: number;
  is_hidden: boolean;
  ability: { name: string; url: string };
}

export interface PokemonResponse {
  height: number;
  weight: number;
  sprites: { front_default: string | null };
  types: PokemonType[];
  abilities: PokemonAbility[];
}

export interface SpeciesResponse {
  names: LanguageName[];
  flavor_text_entries: FlavorText[];
  genera: Genus[];
  generation: { url: string };
  gender_rate: number;
}

export interface AbilityResponse {
  name: string;
  names: LanguageName[];
}

// ── DB 저장 타입 ──────────────────────────────

export interface PokemonRow {
  id: number;
  name_ko: string;
  type1_ko: string;
  type2_ko: string | null;
  generation: number;
  image_url: string;
  height_m: number;
  weight_kg: number;
  flavor_text_ko: string;
  category_ko: string;
  gender_rate: number;
  ability1_ko: string;
  ability2_ko: string | null;
  ability_hidden_ko: string | null;
  created_at: string;
}
