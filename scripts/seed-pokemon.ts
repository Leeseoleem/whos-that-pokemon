import { createClient } from "@supabase/supabase-js";
import { TYPE_KO } from "@/constants/pokemon";
import type {
  PokemonResponse,
  SpeciesResponse,
  AbilityResponse,
} from "@/types/pokemon";

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.SUPABASE_SECRET_KEY!,
);

const delay = (ms: number) => new Promise((res) => setTimeout(res, ms));

async function fetchJSON(url: string): Promise<unknown> {
  const res = await fetch(url);
  if (!res.ok) throw new Error(`fetch 실패: ${url}`);
  return res.json();
}

const abilityNameKoCache = new Map<string, Promise<string>>();

async function getAbilityNameKo(url: string): Promise<string> {
  const cached = abilityNameKoCache.get(url);
  if (cached) return cached;

  const request = (async () => {
    const data = (await fetchJSON(url)) as AbilityResponse;
    const ko = data.names.find((n) => n.language.name === "ko");
    return ko?.name ?? data.name;
  })().catch((error) => {
    abilityNameKoCache.delete(url);
    throw error;
  });

  abilityNameKoCache.set(url, request);
  return request;
}

async function seedPokemon(id: number): Promise<boolean> {
  try {
    const [pokemon, species] = (await Promise.all([
      fetchJSON(`https://pokeapi.co/api/v2/pokemon/${id}`),
      fetchJSON(`https://pokeapi.co/api/v2/pokemon-species/${id}`),
    ])) as [PokemonResponse, SpeciesResponse];

    const name_ko = species.names.find((n) => n.language.name === "ko")?.name;
    if (!name_ko) {
      console.log(`#${id} 한국어 이름 없음 - 스킵`);
      return true;
    }

    const flavor_text_ko =
      species.flavor_text_entries
        .find((f) => f.language.name === "ko")
        ?.flavor_text.replace(/\f|\n/g, " ") ?? null;

    const category_ko =
      species.genera.find((g) => g.language.name === "ko")?.genus ?? null;

    const genUrl = species.generation.url;
    const generation = parseInt(
      genUrl.split("/").filter(Boolean).pop() ?? "1",
      10,
    );

    const type1_ko =
      TYPE_KO[pokemon.types[0]?.type.name] ?? pokemon.types[0]?.type.name;
    const type2_ko = pokemon.types[1]
      ? (TYPE_KO[pokemon.types[1].type.name] ?? pokemon.types[1].type.name)
      : null;

    const height_m = pokemon.height / 10;
    const weight_kg = pokemon.weight / 10;
    const image_url = pokemon.sprites.front_default ?? null;
    const gender_rate = species.gender_rate;

    const ability1 = pokemon.abilities.find((a) => a.slot === 1);
    const ability2 = pokemon.abilities.find((a) => a.slot === 2);
    const abilityH = pokemon.abilities.find((a) => a.is_hidden);

    const [ability1_ko, ability2_ko, ability_hidden_ko] = await Promise.all([
      ability1 ? getAbilityNameKo(ability1.ability.url) : Promise.resolve(null),
      ability2 ? getAbilityNameKo(ability2.ability.url) : Promise.resolve(null),
      abilityH ? getAbilityNameKo(abilityH.ability.url) : Promise.resolve(null),
    ]);

    const { error } = await supabase.from("pokemons").upsert({
      id,
      name_ko,
      type1_ko,
      type2_ko,
      generation,
      image_url,
      height_m,
      weight_kg,
      flavor_text_ko,
      category_ko,
      gender_rate,
      ability1_ko,
      ability2_ko,
      ability_hidden_ko,
    });

    if (error) throw error;
    console.log(`#${id} ${name_ko} 완료`);
    return true;
  } catch (e) {
    console.error(`#${id} 실패:`, e);
    return false;
  }
}

async function main() {
  console.log("포켓몬 데이터 수집 시작 (1~1025)");
  let failed = 0;
  for (let id = 1; id <= 1025; id++) {
    const ok = await seedPokemon(id);
    if (!ok) failed += 1;
    await delay(200);
  }
  if (failed > 0) {
    console.error(`완료: ${failed}건 실패`);
    process.exitCode = 1;
    return;
  }
  console.log("완료!");
}

main();
