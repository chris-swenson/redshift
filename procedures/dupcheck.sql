-- Check for duplicates
-- Usage: call dupcheck('table_name', 'id, columns, by, comma')

DROP PROCEDURE if exists public.dupcheck(varchar, varchar);

-- Procedure with 2 parameters (source_table, id_columns)
CREATE PROCEDURE public.dupcheck(
    source_table varchar,
    id_columns varchar,
    OUT duplicate_count int
)
AS $$
DECLARE
    counter INT;
    query VARCHAR(4096);
BEGIN
    -- Build the query
    query := '
        SELECT sum(duplicates)
        FROM (
            SELECT count(*) as duplicates
            FROM ' || source_table || '
            GROUP BY ' || id_columns || '
            HAVING COUNT(*) > 1
        ) a
    ';
    -- If duplicates are present, output different messages.
    -- A warning is issued if duplicates are present
    BEGIN
        EXECUTE query INTO counter;
        counter := COALESCE(counter, 0);
        IF counter > 0 THEN
            RAISE WARNING '% duplicates found in %!', counter, source_table;
            duplicate_count := counter;
        ELSE
            RAISE NOTICE 'No duplicates found in %.', source_table;
            duplicate_count := 0;
        END IF;
   
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Error: Table % does not exist or invalid columns.', source_table;
        duplicate_count := -1;
    end;
END;
$$ LANGUAGE plpgsql;

GRANT execute ON PROCEDURE public.dupcheck(varchar, varchar) TO PUBLIC;

-- Examples
-- call public.dupcheck('public.alphabet', 'letter');
-- call dupcheck('public.alphabet_dups', 'letter');
-- call dupcheck('doesnotexist', 'flow');
