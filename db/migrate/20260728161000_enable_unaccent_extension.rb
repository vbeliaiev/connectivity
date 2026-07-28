class EnableUnaccentExtension < ActiveRecord::Migration[7.1]
  def up
    enable_extension 'unaccent'

    # unaccent(regdictionary, text) is STABLE (its by-name dictionary lookup
    # depends on search_path), so Postgres refuses to use it in an index
    # expression. Binding directly to the underlying C function bypasses the
    # by-name lookup and lets us mark the wrapper IMMUTABLE, which is
    # required to use it inside an index and safe here since we always
    # pass a fully-qualified dictionary name.
    execute <<~SQL
      CREATE OR REPLACE FUNCTION public.immutable_unaccent(regdictionary, text)
      RETURNS text LANGUAGE c IMMUTABLE PARALLEL SAFE STRICT AS
      'unaccent', 'unaccent_dict';
    SQL

    execute <<~SQL
      CREATE OR REPLACE FUNCTION public.immutable_unaccent(text)
      RETURNS text LANGUAGE sql IMMUTABLE PARALLEL SAFE STRICT AS
      $$
        SELECT public.immutable_unaccent('public.unaccent'::regdictionary, $1)
      $$;
    SQL
  end

  def down
    execute 'DROP FUNCTION IF EXISTS public.immutable_unaccent(text);'
    execute 'DROP FUNCTION IF EXISTS public.immutable_unaccent(regdictionary, text);'
    disable_extension 'unaccent'
  end
end
