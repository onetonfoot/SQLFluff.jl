using Test, SQLFluff, SQLStrings
using SQLFluff: joinsql, dialect!, ansi, formatter
using SQLStrings: Sql

@testset "sql_cmd" begin
	@test sql"Select  *, 1, blah as  fOO  from mySchema.myTable;" isa  SQLStrings.Sql
	@test_throws SQLParseError sql"SLEct  *, 1, blah as  fOO  from mySchema.myTable;"
end

@testset "general" begin
	x = "hello"
	@test formatter(Val{:ansi}(), x)(x) == "'hello'"
end

@testset "interpolations" begin
	x = 20
	y = 10
	and_clause = sql`AND y=$y`
	@test sql"SELECT * FROM table WHERE x=$x $and_clause" isa Sql

	x = "20"
	y = "10"
	and_clause = sql`AND y=$y`
	@test sql"SELECT * FROM table WHERE x=$x $and_clause" isa Sql
end

@testset "dialect!" begin
	@test_nowarn dialect!(:ansi)
	@test_nowarn dialect!(Val(:ansi))
	@test_throws ErrorException dialect!("as")
end

@testset "postgres" begin
	dialect!(:postgres)
	l = ["a", "b", "c"]
	SQLFluff.postgres_array(l)
	@test_nowarn sql"INSERT INTO table VALUES ($l)"
end