using ArchUnitNET.Domain;
using ArchUnitNET.Fluent;
using ArchUnitNET.Fluent.Slices;
using ArchUnitNET.Loader;
using ArchUnitNET.xUnitV3;
using WheelTracker.Api.Features.Projects;
using static ArchUnitNET.Fluent.ArchRuleDefinition;

namespace WheelTracker.Tests;

public class ArchitectureTest
{
    private static readonly Architecture _architecture = new ArchLoader().LoadAssemblies(
        typeof(Project).Assembly,
        typeof(Dapper.SqlMapper).Assembly
    ).Build();

    [Fact]
    public void RepositoryはEndpointsに依存しない()
    {
        IArchRule rule =
            Classes()
            .That().HaveNameEndingWith("Repository")
            .Should().NotDependOnAny(
                Types().That().HaveNameEndingWith("Endpoints")
            );

        rule.Check(_architecture);
    }

    [Fact]
    public void Features名前空間内でRepository以外はDapperに依存しない()
    {
        IArchRule rule =
            Types()
            .That().ResideInNamespaceMatching(@"WheelTracker\.Api\.Features")
            .And().DoNotHaveNameEndingWith("Repository")
            .Should().NotDependOnAny(
                Types().That().ResideInNamespaceMatching(@"Dapper")
            );

        rule.Check(_architecture);
    }

    [Fact]
    public void Features同士は依存しない()
    {
        IArchRule rule = SliceRuleDefinition
            .Slices()
            .Matching("WheelTracker.Api.Features.(*)")
            .Should().NotDependOnEachOther();

        rule.Check(_architecture);
    }
}
