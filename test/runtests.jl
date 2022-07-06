using Test, SQLFluff, SQLStrings

@testset "sql_cmd" begin
	@test sql"Select  *, 1, blah as  fOO  from mySchema.myTable;" isa  SQLStrings.Sql
	@test_throws SQLParseError sql"SLEct  *, 1, blah as  fOO  from mySchema.myTable;"
end

@testset "interpolations" begin
	x = 20
	y = 10
	and_clause = sql`AND y=$y`
	# how to make this pass sqlfluff.lint?
	@test_skip sql"SELECT * FROM table WHERE x=$x $and_clause"
end

@testset "dialect!" begin
	@test_throws ErrorException dialect!("as")
end