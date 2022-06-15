using Test, SQLFluff, SQLStrings

@testset "sql_cmd" begin
	@test sql"Select  *, 1, blah as  fOO  from mySchema.myTable;" isa  SQLStrings.Sql
	@test_throws SQLParseError sql"SLEct  *, 1, blah as  fOO  from mySchema.myTable;"
end

@testset "dialect!" begin
	@test_throws ErrorException dialect!("as")
end