create table public.murdoku_codes (
  code text primary key,
  kind text not null check (kind in ('puzzle','board')),
  title text,
  level int,
  persons int,
  data jsonb not null,
  plays int not null default 0,
  created_at timestamptz not null default now()
);
alter table public.murdoku_codes enable row level security;
create policy "codes zijn openbaar leesbaar" on public.murdoku_codes for select using (true);

create or replace function public.publish_murdoku(p_kind text, p_title text, p_level int, p_persons int, p_data jsonb)
returns text language plpgsql security definer set search_path = public as $$
declare abc text := 'ABCDEFGHJKMNPQRSTUVWXYZ23456789'; c text;
begin
  if p_kind not in ('puzzle','board') then raise exception 'ongeldige soort'; end if;
  if octet_length(p_data::text) > 300000 then raise exception 'puzzel te groot'; end if;
  loop
    c := '';
    for i in 1..6 loop c := c || substr(abc, 1 + floor(random() * length(abc))::int, 1); end loop;
    begin
      insert into murdoku_codes(code, kind, title, level, persons, data)
      values (c, p_kind, left(coalesce(p_title, ''), 80), p_level, p_persons, p_data);
      return c;
    exception when unique_violation then
      -- code bestond al: nieuwe proberen
    end;
  end loop;
end $$;

create or replace function public.count_play(p_code text)
returns void language sql security definer set search_path = public as $$
  update murdoku_codes set plays = plays + 1 where code = upper(p_code);
$$;

grant execute on function public.publish_murdoku(text, text, int, int, jsonb) to anon, authenticated;
grant execute on function public.count_play(text) to anon, authenticated;
