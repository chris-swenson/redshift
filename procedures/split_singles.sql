-- Split singles from a table into a temporary table
-- Common Usage: select split_singles('table_name', 'id, columns, by, comman', 'output_table_name')
-- Note: Use 'schema.table_name' for permanent tables in a specific schema

drop procedure public.split_singles(text, text, text);

CREATE procedure public.plit_singles(
    source_table VARCHAR,
    id_columns VARCHAR, -- Specify the columns that are supposed to identify unique rows
    output_table VARCHAR, -- Specify temporary table name that the results should be returned to
    OUT output_row_count INT
)
AS $$
DECLARE
    query1 VARCHAR(4096);
    query2 VARCHAR(4096);
    query3 VARCHAR(4096);
    counter INT;
BEGIN
    -- Query to create the table
    query1 := '
        create temporary table ' || output_table || ' as
        select *
        from ' || source_table || '
        where 1=0;
    ';
    -- Build the main query
    query2 := '
        INSERT INTO ' || output_table || '
        SELECT a.*
        FROM ' || source_table || ' a
        INNER JOIN (
            SELECT ' || id_columns || '
            FROM ' || source_table || '
            GROUP BY ' || id_columns || '
            HAVING count(*) = 1
        ) as b
        USING (' || id_columns || ')
        ORDER BY ' || id_columns || '
    ';
    query3 := 'drop table ' || output_table || ';';
    -- If duplicates are present, output different messages.
    -- A war-ning is issued if duplicates are present
    begin
        EXECUTE query1;
        EXECUTE query2;
        GET DIAGNOSTICS counter = ROW_COUNT;
        IF counter = 0 THEN
            EXECUTE query3;
            RAISE NOTICE 'No records found.';
            output_row_count := 0;
        ELSE
            RAISE NOTICE 'Output % rows to %.', counter, output_table;
            output_row_count := counter;
        END IF;
    EXCEPTION WHEN OTHERS THEN
        RAISE NOTICE 'Error: %', SQLERRM;
        output_row_count := -1;
    end;
END;
$$ LANGUAGE plpgsql;

GRANT execute ON PROCEDURE public.split_singles(text, text, text) TO PUBLIC;

-- Examples

--drop table if exists alphabet_split;
--call public.split_singles('public.alphabet', 'letter', 'alphabet_split');
--select * from alphabet_split;

--drop table if exists alphabet_split;
--call public.split_singles('public.alphabet_dups', 'letter', 'alphabet_split');
--select * from alphabet_split;
