-- English alphabet table with a vowel indicator
drop table if exists public.alphabet;
create table public.alphabet (letter varchar(1), vowel int);
insert into public.alphabet values
('a', 1), ('b', 0), ('c', 0), ('d', 0), ('e', 1), ('f', 0), ('g', 0), ('h', 0),
('i', 1), ('j', 0), ('k', 0), ('l', 0), ('m', 0), ('n', 0), ('o', 1), ('p', 0),
('q', 0), ('r', 0), ('s', 0), ('t', 0), ('u', 1), ('v', 0), ('w', 0), ('x', 0),
('y', 0), ('z', 0)
;

-- Create a view with duplicates
drop view if exists public.alphabet_dups;
create view public.alphabet_dups as 
select *, 1 as original from public.alphabet 
union 
select *, 0 as original from public.alphabet where letter in ('a', 'g', 'o', 't')
;

-- Create a view for pivoting
create view public.alphabet_type as 
select *, case when vowel = 1 then 0 else 1 end as consonant 
from alphabet 
;
