UPDATE kandidat 
SET name = CONCAT(
    TRIM(SUBSTRING(name,INSTR(name,',')+1)), 
    ' ', 
    TRIM( LEFT(name, INSTR(name,',')-1))
) WHERE name LIKE '%,%' ; 
