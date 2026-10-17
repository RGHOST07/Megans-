-- Ejecutar completo en Supabase > SQL Editor
create table app_data(key text primary key, value jsonb not null, updated_at timestamptz default now());
create table app_data_history(id bigserial primary key, key text, value jsonb, saved_at timestamptz default now());

-- Cada cambio guarda automáticamente la versión anterior (red de seguridad)
create function keep_history() returns trigger language plpgsql as $$
begin insert into app_data_history(key,value) values (old.key,old.value); return new; end $$;
create trigger t_hist before update on app_data for each row
when (old.value is distinct from new.value) execute function keep_history();

alter table app_data enable row level security;
alter table app_data_history enable row level security;
-- Solo usuarios con sesión iniciada; la app NO puede borrar datos ni leer/borrar el historial
create policy "leer" on app_data for select to authenticated using (true);
create policy "crear" on app_data for insert to authenticated with check (true);
create policy "actualizar" on app_data for update to authenticated using (true) with check (true);
